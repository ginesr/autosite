#!perl

use strict;
use warnings;
use autodie;
use Autosite::Template;
use Autosite::Config;
use Test::More tests => 2;
use Test::Exception;

my $template = Autosite::Template->new;
my $config   = Autosite::Config->new;
$config->templates_dir('templates');
$config->templates_cache(1);

$template->config($config);
$template->file('test2.htm');

my $output =
  $template->render( { THAT => 'to be replaced', THIS => 'not this' } );

like( $output, qr/Replace to be replaced/, 'Replace var in template' );
like(
    $output,
    qr/This file was included and also to be replaced\nnot this/,
    'Replace var in include'
);
