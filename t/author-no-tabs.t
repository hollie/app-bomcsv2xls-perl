
BEGIN {
  unless ($ENV{AUTHOR_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for testing by the author');
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.15

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'bin/bom-csv2xls.pl',
    'lib/App/BomCsv2Xls.pm',
    't/01-basic.t',
    't/02-testpoints.t',
    't/author-critic.t',
    't/author-eol.t',
    't/author-no-tabs.t',
    't/author-pod-coverage.t',
    't/author-pod-syntax.t',
    't/release-common_spelling.t',
    't/release-kwalitee.t',
    't/release-pod-linkcheck.t',
    't/release-pod-no404s.t',
    't/release-synopsis.t',
    't/stim/example.csv',
    't/stim/testpoints.csv'
);

notabs_ok($_) foreach @files;
done_testing;
