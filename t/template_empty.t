#!perl

use strict;
use warnings;
use autodie;
use Autosite::Template;
use Test::More tests => 1;
use Test::Exception;

my $template = Autosite::Template->new;

$template->file('templates/test_empty.htm');

my $output = $template->render( {} );

like( $output, qr/Nothing to replace/, 'Nothing to replace' );
