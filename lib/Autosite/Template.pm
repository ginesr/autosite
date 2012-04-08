package Autosite::Template;

use strict;
use warnings;
use autodie;
use Moose;
use Try::Tiny;
use Autosite::Error;

has 'cache' => ( is => 'rw' );

sub render {

	my $self        = shift;
	my $template    = shift;    # file handle or string
	my $namespace   = shift;
	my $export_vars = shift;
	my $remove_tags = shift;
	my $output_to   = shift;    # file handle, string
	
	if (not $template) {
		Autosite::Error->throw('missing template parameter');
	}
	if ($template and ref($template) and ref($template) ne 'IO::File' ) {
		Autosite::Error->throw('invalid template ref');
	}
	
	return 1;

}

1;
