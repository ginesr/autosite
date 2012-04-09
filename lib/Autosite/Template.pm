package Autosite::Template;

use strict;
use warnings;
use autodie;
use Moose;
use Try::Tiny;
use Autosite::Error;
use Autosite::String::Trim;
use IO::File;
use Data::Dumper qw(Dumper);
use 5.012_001;

our $VERSION = '0.01';

has 'cache' => ( is => 'rw', default => sub { return {} }, lazy => 1 );
has 'stash' => (
    is      => 'rw',
    isa     => 'Maybe[ArrayRef]',
    default => sub { return [] },
    lazy    => 1
);
has 'file' => ( is => 'rw', isa => 'Str' );
has 'config' => ( is => 'rw', isa => 'Autosite::Config', required => 0 );
has '_block_cache' => ( is => 'rw', default => sub { return {} }, lazy => 1 );

sub render {

    my $self         = shift;
    my $namespace    = shift;
    my $export_stash = shift || [];
    my $block_tags   = shift;
    my $write_to     = shift;         # file handle, string

    if ( not $namespace ) {
        Autosite::Error->throw('missing namespace parameter');
    }
    if ( $namespace and ref($namespace) ne 'HASH' ) {
        Autosite::Error->throw('invalid ref type in namespace');
    }
    if ( $export_stash and ref($export_stash) ne 'ARRAY' ) {
        Autosite::Error->throw('invalid ref type in export_stash');
    }

    my $output = $self->get_template_contents();

    $namespace = $self->process_namespace($namespace);
    $namespace = $self->process_stash( $namespace, $export_stash );

    $output = $self->process_include($output);
    $output = $self->process_blocks( $output, $namespace, $block_tags );

    return $self->replace_in_template($output,$namespace);

}

sub replace_in_template {
    
    my $self      = shift;
    my $output    = shift || '';
    my $namespace = shift || {};
    my %replace   = ();

    while ($output =~ /\$([A-Z_0-9\.]+)/gsm) {
        $replace{$1} = $namespace->{$1} || '';
    }
    
    $output =~ s/\$([A-Z_0-9\.]+)/$replace{$1}/g;
    
    return $output;
    
}

sub read_block {

    my $self = shift;
    my $block = shift || '';
    
    if (my $block_cached = $self->_block_is_cached($block) ) {
        return $block_cached;
    }

    my $template_output = $self->get_template_contents();
    $template_output =~
      s/(.*)(<!--.*(<$block>).-->)(.*)(<!--.*(<\/$block>).-->)(.*)/$4/sm;
    
    $self->_block_cache->{$block} = $template_output;
    
    return $template_output;

}

sub process_blocks {

    my $self            = shift;
    my $template_output = shift;
    my $namespace       = shift;
    my $blocks          = shift;

    if (not defined $blocks and not defined $self->_block_cache) { 
        return $template_output;
    }

    my @blocks = ();
    
    if (defined $blocks) {
        @blocks = split( ',', $blocks )
    }

    foreach my $n ( keys %{ $self->_block_cache } ) {
        if (not exists $namespace->{ uc($n) } ) {
            $namespace->{ uc($n) } = $self->_block_cache->{$n};
            push @blocks, $n;
        }
    }

    foreach my $t (@blocks) {
        next unless $t;
        $namespace->{ uc($t) } =~ s/\$([A-Z_0-9\.]+)/$namespace->{$1}/g;
        $template_output =~
s/(.*)(<!--.*(<$t>))(.*)((<\/$t>).-->)(.*)/$1 $namespace->{uc($t)} $7/sm;
    }

    return $template_output;
}

sub process_namespace {

    my $self      = shift;
    my $namespace = shift;

    foreach ( keys %{$namespace} ) {
        $namespace->{ uc($_) } =~ s/\$([A-Z_0-9\.]+)/$namespace->{$1}/g;
    }

    return $namespace;
}

sub process_stash {

    my $self         = shift;
    my $namespace    = shift;
    my $export_stash = shift;

    foreach my $exp ( @{$export_stash} ) {
        foreach my $stashed ( @{ $self->stash } ) {
            foreach my $key ( keys %{$stashed} ) {
                if ( $exp eq $key ) {
                    $namespace->{ uc($exp) } = $stashed->{$key};
                }
            }
        }
    }

    return $namespace;
}

sub process_include {

    my $self     = shift;
    my $template = shift;
    my $includes = {};

    while ( $template =~ m/<!--\s*?{\s*?include:(.*?)}\s*?-->/g ) {

        my $variable = $1;

        # is it a var or a file?
        if ( $variable =~ /^\$/ ) {

            # look file name in DB
        }

        $variable = $variable->trim;

        my $include = $self->get_template_contents($variable);
        $includes->{$variable} =
          $self->_include_comments( $include, $variable );

    }

    foreach ( keys %{$includes} ) {
        $template =~
          s/<!--\s*?{\s*?include:\s*?$_\s*?}\s*?-->/$includes->{$_}/gsm;
    }

    return $template;
}

sub get_template_contents {

    my $self = shift;
    my $file = shift || $self->file;

    if ( not $file ) {
        Autosite::Error->throw('missing file parameter');
    }

    $file = $file->trim;
    
    return $self->_open_template($file);

}

# private

sub _include_comments {

    my $self     = shift;
    my $include  = shift;
    my $variable = shift;

    return qq~<!-- include from $variable -->
<!-- <$variable> -->
$include
<!-- </$variable> -->
<!-- end include $variable -->
~;

}

sub _from_cache {

    my $self = shift;
    my $file = shift || $self->file;

    if (    $self->_with_cache
        and defined $self->cache->{$file}
        and $self->cache->{$file} )
    {
        return $self->cache->{$file};
    }

    return;

}

sub _open_template {

    my $self = shift;
    my $file = shift || $self->file;

    if ( my $dir = $self->_template_dir ) {
        $dir =~ s/\/$//g;
        $file = $dir . '/' . $file;
    }

    if ( my $content = $self->_from_cache($file) ) {
        return $content;
    }

    my $template = IO::File->new();

    if ( not $template->open( $file, 'r' ) ) {
        Autosite::Error->throw( 'Can\'t open file ' . $file );
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

        $self->cache->{$file} = $contents;

    }

    return $contents;

}

sub _template_dir {
    my $self = shift;

    if ( defined $self->config and $self->config->templates_dir ) {
        return $self->config->templates_dir;
    }
    return;
}

sub _with_cache {

    my $self = shift;

    if ( not $self->config
        or ( $self->config and $self->config->templates_cache ) )
    {
        return 1;
    }

    return 0;
}

sub _block_is_cached {
    
    my $self = shift;
    my $block = shift;
    
    if (exists $self->_block_cache->{$block}) {
        return $self->_block_cache->{$block};
    }
    
    return;    
}

1;
