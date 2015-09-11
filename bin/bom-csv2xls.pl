#! /usr/bin/env perl

# PODNAME: bom-csv2xls.pl
# ABSTRACT: Convertor for the output of of the Eagle full BOM mount script into an xls file

use strict;
use warnings;

use 5.018;

use App::BomCsv2Xls;

use Getopt::Long;
use Pod::Usage;

my ($help, $man);

# Get the command line options
GetOptions(
    'file=s'     => \$file,
    'help|?|h'   => \$help,
    'man'        => \$man,
) or pod2usage(2);

pod2usage(1) if ( $help || !defined($file) || @ARGV == 0);
pod2usage( -exitstatus => 0, -verbose => 2 ) if ($man);

my $inFile = $ARGV[0];
my $outFile = ($inFile =~ s/csv/xlsx/);

# Create the convertor object
my $conv = new App::BomCsv2Xls(inputFile => $inFile, outputFile => $outFile);
# Convert
$conv->write_xls();

say "Csv file converted and written to $outFile";


=head1 NAME

bom-csv2xls - Convert an Eagle design BOM file from the fullBOMmount script into an Excel file ready to send to the manufacturing

=head1 SYNOPSIS

    ./bom-csv2xls bom_file.csv 
    
=head1 DESCRIPTION

This program converts and sorts an outputfile from the fullBOMmount Eagle script into a file ready for sending into production.
It will list all components on the board and it will filter out:

=over

=item Test points (are recognized based on their name starting with PTR1B)

=item Components that have their value set to 'NC'

=item Components that have their 'OPT' attribute set to "DO_NOT_MOUNT"

=back

The result will be an Excel file with three output sections: the regular components, the components that do not need to be mounted, and the test points.
The file will have the same name as the input csv file, but with xlsx as extention.

=head1 AUTHOR

Lieven Hollevoet <lieven@quicksand.be>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Lieven Hollevoet.

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.

=cut
