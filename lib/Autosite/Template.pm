package Autosite::Template;

use strict;
use warnings;
use autodie;
use Moose;
use Try::Tiny;
use Autosite::Error;
use IO::File;
use 5.012_001;

our $VERSION = '0.01';

has 'cache' => ( is => 'rw', default => sub { return {} }, lazy => 1 );
has 'file' => ( is => 'rw', isa => 'Str' );
has 'config' => (is => 'rw', isa => 'Autosite::Config', required => 0);

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

    return $self->_open_template;

}

# private 

sub _from_cache {
    
    my $self = shift;
    
    if ( $self->_with_cache and defined $self->cache->{ $self->file }
        and $self->cache->{ $self->file } )
    {
        return $self->cache->{ $self->file };
    }
    
    return;
    
}

sub _open_template {

    my $self = shift;

    if ( my $content = $self->_from_cache ) {
        return $content;
    }

    my $template = IO::File->new();

    if ( not $template->open( $self->file, 'r' ) ) {
        Autosite::Error->throw( 'Can\'t open file ' . $self->file );
    }
    if ( not $template ) {
        Autosite::Error->throw('IO error');
    }
    if ( $template and ref($template) and ref($template) ne 'IO::File' ) {
        Autosite::Error->throw('invalid template ref');
    }

    local ($/) = undef;
    my $contents = <$template>;
    
    if ( $self->_with_cache ) { 

        $self->cache->{ $self->file } = $contents;
    
    }

    return $contents;

}

sub _with_cache {
    
    my $self = shift;
    
    if ( not $self->config or ( $self->config and $self->config->templates_cache ) ) {
        return 1;
    }
    
    return 0;
}

1;
