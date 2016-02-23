# Added this test as the script failed to detect testpoints

use strict;
use Test::More;
use lib './lib';
use lib '../lib';

use App::BomCsv2Xls;

my $inFile = './t/stim/testpoints.csv';
my $outFile = './t/stim/output.xlsx';

my $dut = App::BomCsv2Xls->new(inputFile => $inFile, outputFile => $outFile);
ok $dut, 'object created';

my ($mount, $nomount, $testpoint) = $dut->report();

is $mount, 2, "Nr of components to be mounted parsed";
is $nomount, 1, "Nr of components not to be mounted parsed";
is $testpoint, 4, "Nr of testpoints parsed";

done_testing();

