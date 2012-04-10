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
$template->file('test7.htm');
$template->maps( { HEADER => 'include2.htm' } );

my $vars = { THAT => 'to be replaced' };
my $output = $template->render($vars);

like( $output, qr/Replace to be replaced/, 'Replace var in template' );
like(
    $output,
    qr/This file was included using mapping/,
    'Replace var in include with maps'
);
