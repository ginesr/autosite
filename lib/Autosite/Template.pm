package Autosite::Template;

use strict;
use warnings;
use autodie;
use Moose;
use Try::Tiny;
use Autosite::Error;
use IO::File;

has 'cache' => ( is => 'rw', default => sub { return {} }, lazy => 1 );
has 'file'  => ( is => 'rw', isa => 'Str' );

sub render {

    my $self        = shift;
    my $namespace   = shift;
    my $export_vars = shift;
    my $remove_tags = shift;
    my $output_to   = shift;    # file handle, string

    my $template_output = $self->get_template_contents();

    if ( not $namespace ) {
        Autosite::Error->throw('missing namespace parameter');
    }
    if ( $namespace and ref($namespace) ne 'HASH' ) {
        Autosite::Error->throw('invalid ref type in namespace');
    }

    foreach ( keys %{$namespace} ) {
        $namespace->{ uc($_) } =~ s/\$([A-Z_0-9\.]+)/$namespace->{$1}/g;
    }

    $template_output =~ s/\$([A-Z_0-9\.]+)/$namespace->{$1}/g;

    return $template_output;

}

sub get_template_contents {

    my $self = shift;

    if ( not $self->file ) {
        Autosite::Error->throw('missing file parameter');
    }

    my $template = IO::File->new();
    $template->open( $self->file, 'r' );

    if ( not $template ) {
        Autosite::Error->throw('IO error');
    }
    if ( $template and ref($template) and ref($template) ne 'IO::File' ) {
        Autosite::Error->throw('invalid template ref');
    }

    local ($/) = undef;
    my $template_output = <$template>;
    
    $self->cache->{$self->file} = $template_output;

    return $template_output;

}

1;