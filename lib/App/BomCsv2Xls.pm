use strict;
use warnings;
package App::BomCsv2Xls;

use Moose;
use namespace::autoclean;
use 5.018;
use autodie;

use Carp qw/croak carp/;

use Text::CSV;
use Excel::Writer::XLSX;


my $db; # Database to sort/store the conents of the CSV before writing it to xls

# Field indexes in the CSV file
use constant NAME  => 0;
use constant VALUE => 6;
use constant OPT   => 20;

has inputFile => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has outputFile => (
	is => 'ro',
	isa => 'Str',
	required => 1,
);

# Actions that need to be run after the constructor
sub BUILD {
    my $self = shift;
    # Add stuff here
    
    my $csv = Text::CSV->new({ sep_char => ',' });
 
	open(my $data, '<', $self->inputFile()) or die "Could not open '$self->inputFile' $!\n";

	my $line_count = 0;
	
	# Prepare the headers that wil be written to the xls file for the sorted content
	$db->{'header'}->{'no_mount'}[0] = "Components that should not be mounted";
	$db->{'header'}->{'test_points'}[0] = "Test points";
		
	while (my $line = <$data>) {
  		chomp $line;
		$line_count++;
	
		if ($csv->parse($line)) {
       		my @fields = $csv->fields();
       		
       		# First line is the header of the CSV
       		if ($line_count == 1) {
       			$db->{'header'}->{'main'} = \@fields;
       			next;
       		}
       		
       		# If the value of the device is set to NC -> move it to no_mount
       		# If the DO_NOT_MOUNT option is set -> move it to no_mount
       		if (($fields[VALUE] eq 'NC') || ($fields[OPT] eq 'DO_NOT_MOUNT')) {
       			$db->{'data'}->{'no_mount'}->{$fields[NAME]} = \@fields;
       			next;
       		}
       		       		
			# If the component is a test point -> move it to test points
			if ($fields[VALUE] =~ /^PTR1B/) {
				$db->{'data'}->{'test_points'}->{$fields[NAME]} = \@fields;
				next;
			}       
			
			# If we arrive here this line is a regular component -> store it under main
			$db->{'data'}->{'main'}->{$fields[NAME]} = \@fields;

		} else {
      		warn "Line $line_count from the CSV file could not be parsed: $line\n";
 	 	}
	}

}

sub write_xls {
	
	my $self = shift();
	
	my $workbook  = Excel::Writer::XLSX->new( $self->outputFile() );

	my $ws = $workbook->add_worksheet();
 
 	my $line = 0;
 	
 	# Headers should be bold
 	my $format = $workbook->add_format();
    $format->set_bold();
    
 	## Write regular header and list of components to be mounted;
	$self->_write_line($ws, $line, $db->{'header'}->{'main'}, $format);
	$line++;
	
	foreach my $entry (sort keys %{$db->{'data'}->{'main'}}) {
		$self->_write_line($ws, $line, $db->{'data'}->{'main'}->{$entry});
		$line++		
	}
	
	$line++;
	
	## Write not to be mounted components
	$self->_write_line($ws, $line, $db->{'header'}->{'no_mount'}, $format);
	$line++;
	
	foreach my $entry (sort keys %{$db->{'data'}->{'no_mount'}}) {
		$self->_write_line($ws, $line, $db->{'data'}->{'no_mount'}->{$entry});
		$line++		
	}
	
	$line++;
	
	## Write test points
	$self->_write_line($ws, $line, $db->{'header'}->{'test_points'}, $format);
	$line++;
	
	foreach my $entry (sort keys %{$db->{'data'}->{'test_points'}}) {
		$self->_write_line($ws, $line, $db->{'data'}->{'test_points'}->{$entry});
		$line++		
	}
	
	
	
	
	
 
	$workbook->close;

	return;
}

sub _write_line {
	
	my $self = shift();
	my $sheet = shift();
	my $row = shift();
	my $data = shift();
	my $format = shift();
	
	my $colcount = 0;
	foreach my $col (@{$data}) {
		$sheet->write_string($row, $colcount, $col, $format);
		$colcount++;
	}
	
	
}

# Speed up the Moose object construction
__PACKAGE__->meta->make_immutable;
no Moose;
1;

# ABSTRACT: add description

=head1 SYNOPSIS

my $object = App::BomCsv2Xls->new(inputFile => 'input.csv');

=head1 DESCRIPTION

This module converts and sorts an outputfile from the fullBOMmount Eagle script into a file ready for sending into production.
It will list all components on the board and it will filter out:

=over

=item Test points (are recognized based on their name starting with PTR1B)

=item Components that have their value set to 'NC'

=item Components that have their 'OPT' attribute set to "DO_NOT_MOUNT"

=back

The result will be an Excel file with three output sections: the regular components, the components that do not need to be mounted, and the test points.

=head1 METHODS

=head2 C<new(%parameters)>

This constructor returns a new App::BomCsv2Xls object. Supported parameters are listed below

=over

=item inputFile

The name of the input file

=item outputFile

The name of the output file to write to

=back

=head2 C<write_xls()>

Writes the Excel file

=head2 BUILD

Helper function to run custome code after the object has been created by Moose.

=cut

