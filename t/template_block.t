#!perl

use strict;
use warnings;
use autodie;
use Autosite::Template;
use Test::More tests => 3;
use Test::Exception;

my $template = Autosite::Template->new;

$template->file('templates/test4.htm');

my $output = $template->render( { BLOCK => 'gone' }, [], 'block' );

like( $output, qr/gone/, 'Replace block' );

my $block = $template->read_block('block');

like( $block, qr/^\nthis is a block with \$THAT\n$/, 'Read block' );

my $output_block = $template->render(
    {
        THAT  => 'that',
        BLOCK => $template->read_block('block')
    },
    [],
    'block'
);
like( $output_block, qr/this is a block with that/, 'Read and replace block' );
