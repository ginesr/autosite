#!perl

use strict;
use warnings;
use Autosite::Template;
use Test::More tests => 3;
use Test::Exception;

my $template = Autosite::Template->new;

throws_ok( sub { $template->render() },
    'Autosite::Error', 'Missing parameters' );

my $string = <<HTML;
<html>
<head></head>
<body>
[%- items = ( 'one','two','three' ) %]
<body>
</html>
HTML

$template->tmpl( \$string );

throws_ok(
    sub {
        my $output =
          $template->render( { TEST => 'some text', FOO => 'you are' } );
    },
    'Autosite::Error',
    'TT syntax error'
);

throws_ok(
    sub {
        my $output =
          $template->render( { TEST => 'some text', FOO => 'you are' } );
    },
    qr/input text line 4: unexpected token/,
    'TT syntax error message'
);

