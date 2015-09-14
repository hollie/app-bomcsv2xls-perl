# Basic test for the csv 2 xls convertor for BOMs

use strict;
use Test::More;
use lib './lib';
use lib '../lib';

use App::BomCsv2Xls;

my $inFile = './t/stim/example.csv';
my $outFile = './t/stim/output.xlsx';

# Check default functions
can_ok ('App::BomCsv2Xls', qw(write_xls report));

my $dut = App::BomCsv2Xls->new(inputFile => $inFile, outputFile => $outFile);
ok $dut, 'object created';

my ($mount, $nomount, $testpoint) = $dut->report();

is $mount, 8, "Nr of components to be mounted parsed";
is $nomount, 6, "Nr of components not to be mounted parsed";
is $testpoint, 7, "Nr of testpoints parsed";


# Remove the outputfile if it exists
unlink $outFile;

$dut->write_xls();
ok -e $outFile, 'output file created';

done_testing();

