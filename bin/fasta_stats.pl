use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Getopt::Long qw(GetOptions);
use JSON::PP;
use FastaStats qw(read_fasta summarize);

my $minimum = 1;
Getopt::Long::Configure('no_auto_abbrev');
GetOptions('min-length=i' => \$minimum) or die "usage: perl bin/fasta_stats.pl [--min-length N] input.fasta\n";
@ARGV == 1 or die "usage: perl bin/fasta_stats.pl [--min-length N] input.fasta\n";
open my $input, '<', $ARGV[0] or die "cannot open input: $!\n";
my $records = read_fasta($input);
close $input or die "cannot close input: $!\n";
print JSON::PP->new->canonical->pretty->encode(summarize($records, $minimum));
