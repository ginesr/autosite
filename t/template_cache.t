#!perl

use strict;
use warnings;
use autodie;
use Autosite::Template;
use Autosite::Config;
use Test::More tests => 3;
use Test::Exception;

my $template = Autosite::Template->new;

$template->file('templates/foo.htm');
$template->cache->{'templates/foo.htm'} = <<TEMPLATE;
<html>

Replace \$TEST

</html>
TEMPLATE

my $output = $template->render( { TEST => 'some text' } );

like( $output, qr/Replace some text/, 'Replace one var cached' );

my $template2 = Autosite::Template->new;
my $config    = Autosite::Config->new;
$config->templates_cache(0);
$template2->config($config);

$template2->file('templates/foo.htm');
$template2->cache->{'templates/foo.htm'} = <<TEMPLATE;
<html>

Replace \$TEST

</html>
TEMPLATE

throws_ok( sub { $template2->render( {} ) },
    'Autosite::Error', 'Not using cache' );

    
my $template_prfx = Autosite::Template->new;
my $config_prfx = Autosite::Config->new;
$config_prfx->site_prefix('mysite');
$config_prfx->templates_cache(1);

$template_prfx->config($config_prfx);
$template_prfx->file('templates/foo_bar.htm');
$template_prfx->cache->{'mysite_templates/foo_bar.htm'} = <<TEMPLATE;
<html>

Replace prefix \$TEST

</html>
TEMPLATE

my $output_prfx = $template_prfx->render( { TEST => 'some text' } );

like( $output_prfx, qr/Replace prefix some text/, 'Cache with prefix' );
