#!perl

use strict;
use warnings;
use Autosite::Template;
use Test::More tests => 2;
use Test::Exception;

my $template = Autosite::Template->new;

throws_ok( sub { $template->render() },
    'Autosite::Error', 'Missing parameters' );
    
my $string = <<HTML;
<html>
<head></head>
<body>
<p>Replace \$TEST</p>
<body>
</html>
HTML

$template->tmpl(\$string);

my $output = $template->render( { TEST => 'some text' } );

like( $output, qr/Replace some text/, 'Template is a string' );
