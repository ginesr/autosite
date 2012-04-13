#!perl

use strict;
use warnings;
use Autosite::Template;
use Test::More tests => 7;
use Test::Exception;

my $template = Autosite::Template->new;

throws_ok( sub { $template->render() },
    'Autosite::Error', 'Missing parameters' );

my $string = <<HTML;
<html>
<head></head>
<body>
<p>Replace \$TEST</p>
<div>Awesome \$FOO</div>
[%- items = [ 'one','two','three' ] %]
[%- FOREACH i = items %]
    <li>[% i %]</li>    
[%- END %]
<div>[% FOO %]</div>
<body>
</html>
HTML

$template->tmpl( \$string );

my $output = $template->render( { TEST => 'some text', FOO => 'you are' } );

like( $output, qr/Replace some text/,   'Template is a string' );
like( $output, qr/Awesome you are/,     'Template is a string 2' );
like( $output, qr/<li>one<\/li>/,       'Template toolkit loop 1' );
like( $output, qr/<li>two<\/li>/,       'Template toolkit loop 2' );
like( $output, qr/<li>three<\/li>/,     'Template toolkit loop 3' );
like( $output, qr/<div>you are<\/div>/, 'Template toolkit var' );
