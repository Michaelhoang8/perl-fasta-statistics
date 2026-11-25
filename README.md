# FASTA sequence statistics

Read DNA FASTA records and report sequence lengths, canonical GC percentage, ambiguous-base counts and length-weighted N50 as JSON.

```sh
prove -v t
perl bin/fasta_stats.pl fixtures/sequences.fasta
perl bin/fasta_stats.pl --min-length 9 fixtures/sequences.fasta
```

The parser accepts multiline records, lowercase DNA, spaces/tabs within sequence lines and IUPAC ambiguity codes. Identifiers must be unique. Sequence data before a header, empty records, malformed headers and unsupported symbols such as alignment gaps are rejected.

Length includes ambiguous symbols. **Canonical GC percentage uses G+C divided by A+C+G+T**; ambiguous symbols do not enter that denominator. An all-ambiguous record returns JSON null for GC percentage. N50 is the sequence length at which the cumulative length, sorted largest first, reaches half the selected total. Empty selections have null N50.

Filtering affects the summary and returned records, while input record count remains visible. The entire file is validated before filtering. Sequence strings are counted and discarded line by line, although per-record metadata and statistics remain in memory.

All 18 native assertions passed locally with Perl 5.38.2. Ubuntu CI repeats them and executes the CLI. Only core modules are used: JSON::PP, Getopt::Long and Test::More. The fixture contains short illustrative sequences, not biological research data.
