#!perl

use strict;
use warnings;
use autodie;
use Autosite::Template;
use Autosite::Config;
use Test::More tests => 11;
use Test::Exception;

my $config = Autosite::Config->new;
$config->persistent_cache(1);
$config->templates_cache(1);

my $template = Autosite::Template->new;
$template->config($config);
$template->file('templates/test1.htm');

is( $template->persistent->store_count, 0, 'Store cache hits before process' );

my $output = $template->render( { TEST => 'some text' } );

like( $output, qr/some text/, 'Persistent cache' );
is( $template->persistent->store_count, 1, 'Store cache hits' );

my $template_new = Autosite::Template->new;
$template_new->config($config);
$template_new->file('templates/test1.htm');

is( $template_new->persistent->store_count,
    1, 'Store cache hits from new instance before process' );

my $output2 = $template_new->render( { TEST => 'some text' } );

like( $output2, qr/some text/, 'Persistent cache read' );

is( $template_new->persistent->store_count,
    1, 'Store cache hits from new instance after' );

$template->file('templates/test5.htm');

my $output_again = $template->render( { BLOCK => 'reuse first instance' } );

like( $output_again, qr/reuse/, 'Reusing first intance' );

is( Autosite::Persistent::Cache->store_count, 2, 'Total in cache' );

is( Autosite::Persistent::Cache->detect('templates/test1.htm'),
    1, 'First template is cached' );
is( Autosite::Persistent::Cache->detect('templates/test5.htm'),
    1, 'Second template is cached' );
is( Autosite::Persistent::Cache->detect('templates/blah.htm'),
    0, 'Not used is not cached' );
        