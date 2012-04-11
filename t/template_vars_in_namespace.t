#!perl

use strict;
use warnings;
use autodie;
use Autosite::Template;
use Test::More tests => 1;
use Test::Exception;

my $template = Autosite::Template->new;

$template->file('templates/test1.htm');

my $output = $template->render( { TEST => "some text \$WOOT", WOOT => 'woot!' } );

like( $output, qr/Replace some text woot!/, 'Replace on namespace' );
