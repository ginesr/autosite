#!perl

use strict;
use warnings;
use autodie;
use Autosite::Template;
use Test::More tests => 2;
use Test::Exception;

my $template = Autosite::Template->new;

$template->file('templates/test4.htm');
$template->read_block('block');
$template->file('templates/test5.htm');

my $output_block_mem = $template->render(
    {
        THAT  => 'that',
    }
);

like( $output_block_mem, qr/this is a block with that/, 'Read and replace block with memory' );

my $template2 = Autosite::Template->new;
$template2->_block_cache->{'test'} = <<HTML;
<html>
Is cached
</html>
HTML

my $block = $template2->read_block('test');

like($block, qr/Is cached/, 'Block is cached');
