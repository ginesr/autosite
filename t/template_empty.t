#!perl

use strict;
use warnings;
use autodie;
use Autosite::Template;
use Test::More tests => 2;
use Test::Exception;

my $template = Autosite::Template->new;

$template->file('templates/test_empty.htm');

my $output = $template->render( {} );

like( $output, qr/Nothing to replace/, 'Nothing to replace' );

$template->file('templates/test_empty2.htm');

my $output2 = $template->render( {} );

like( $output2, qr/Var  not replaced/, 'Not replaced' );
