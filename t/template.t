#!perl

use strict;
use warnings;
use autodie;
use Autosite::Template;
use Test::More tests => 2;
use Test::Exception;

my $template = Autosite::Template->new;

throws_ok( sub { $template->render() },
    'Autosite::Error', 'Missing parameters' );

$template->file('templates/test1.htm');

my $output = $template->render( { TEST => 'some text' } );

like( $output, qr/Replace some text/, 'Replace one var' );
