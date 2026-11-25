use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use FastaStats qw(read_fasta summarize);

open my $file, '<', "$FindBin::Bin/../fixtures/sequences.fasta" or die $!;
my $records = read_fasta($file);
is scalar(@$records), 3, 'multiline and lowercase records';
is_deeply [map { $_->{length} } @$records], [12, 8, 4], 'lengths include ambiguous symbols';
is $records->[0]{gc}, 4, 'unambiguous GC count';
is $records->[0]{ambiguous}, 4, 'ambiguity count';
is $records->[0]{canonical_gc_percent}, 50, 'GC denominator excludes ambiguous symbols';
ok !defined $records->[2]{canonical_gc_percent}, 'all ambiguous GC remains missing';
my $summary = summarize($records);
is $summary->{total_length}, 24, 'total length';
is $summary->{n50}, 12, 'N50 weighted by bases, exact halfway';
is summarize($records, 9)->{selected_records}, 1, 'minimum-length filter';
is summarize($records, 100)->{total_length}, 0, 'empty selection length';
ok !defined summarize($records, 100)->{n50}, 'empty selection N50 missing';
for my $bad ("ACGT\n", ">a\nACGT\n>a\nA\n", ">a\n", ">a\nAC-T\n", ">\nA\n") {
    open my $handle, '<', \$bad or die $!;
    my $ok = eval { read_fasta($handle); 1 };
    ok !$ok, 'malformed FASTA rejected';
}
my $empty = '';
open my $handle, '<', \$empty or die $!;
is_deeply read_fasta($handle), [], 'empty input supported';
my $invalid_minimum = eval { summarize($records, 0); 1 };
ok !$invalid_minimum, 'zero minimum rejected';
done_testing;
