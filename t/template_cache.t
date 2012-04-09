#!perl

use strict;
use warnings;
use autodie;
use Autosite::Template;
use Autosite::Config;
use Test::More tests => 2;
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
