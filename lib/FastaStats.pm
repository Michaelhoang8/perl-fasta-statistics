package FastaStats;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw(read_fasta summarize);

sub read_fasta {
    my ($handle) = @_;
    my (@records, %seen, $current);
    my $line_number = 0;
    while (my $line = <$handle>) {
        $line_number++;
        $line =~ s/\r?\n\z//;
        next if $line =~ /^\s*$/;
        if ($line =~ /^>(\S+)(?:\s+(.*))?$/) {
            my ($id, $description) = ($1, $2 // '');
            die "line $line_number: duplicate identifier $id\n" if $seen{$id}++;
            die "empty sequence: $current->{id}\n" if $current && !$current->{length};
            $current = {id => $id, description => $description, length => 0,
                        canonical => 0, gc => 0, ambiguous => 0};
            push @records, $current;
        } else {
            die "line $line_number: sequence before header or malformed header\n" unless $current;
            $line =~ s/[ \t]//g;
            $line = uc $line;
            die "line $line_number: invalid DNA symbol\n" if $line =~ /[^ACGTRYSWKMBDHVN]/;
            $current->{length} += length $line;
            $current->{canonical} += ($line =~ tr/ACGT/ACGT/);
            $current->{gc} += ($line =~ tr/GC/GC/);
            $current->{ambiguous} += ($line =~ tr/RYSWKMBDHVN/RYSWKMBDHVN/);
        }
    }
    die "empty sequence: $current->{id}\n" if $current && !$current->{length};
    for my $record (@records) {
        $record->{canonical_gc_percent} = $record->{canonical}
            ? 100 * $record->{gc} / $record->{canonical} : undef;
    }
    return \@records;
}

sub summarize {
    my ($all, $minimum) = @_;
    $minimum //= 1;
    die "minimum length must be a positive integer\n" unless $minimum =~ /^\d+$/ && $minimum > 0;
    my @selected = grep { $_->{length} >= $minimum } @$all;
    my ($length, $gc, $canonical, $ambiguous) = (0, 0, 0, 0);
    for my $record (@selected) {
        $length += $record->{length};
        $gc += $record->{gc};
        $canonical += $record->{canonical};
        $ambiguous += $record->{ambiguous};
    }
    my ($cumulative, $n50) = (0, undef);
    for my $record (sort { $b->{length} <=> $a->{length} } @selected) {
        $cumulative += $record->{length};
        if ($cumulative >= $length / 2) { $n50 = $record->{length}; last; }
    }
    return {input_records => scalar @$all, selected_records => scalar @selected,
            minimum_length => 0 + $minimum, total_length => $length,
            canonical_bases => $canonical, ambiguous_bases => $ambiguous,
            canonical_gc_percent => $canonical ? 100 * $gc / $canonical : undef,
            n50 => $n50, records => \@selected};
}
1;
