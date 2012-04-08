#!perl

use strict;
use warnings;
use autodie;
use Autosite::Template;
use Test::More tests => 1;
use Test::Exception;

my $template = Autosite::Template->new;

$template->file('templates/foo.htm');
$template->cache->{'templates/foo.htm'} = qq~<html>

Replace \$TEST

</html>~;

my $output = $template->render( { TEST => 'some text' } );

like( $output, qr/Replace some text/, 'Replace one var cached' );
