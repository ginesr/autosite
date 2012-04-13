#perl

use strict;
use warnings;
use Test::More tests => 19;
use Test::Exception;
use Autosite::Param::Field;

my $text = Autosite::Param::Field->new( value => 'Just text' );

is( $text->value(),  'Just text', 'Text param value' );
is( "$text",         'Just text', 'Text param stringified' );
is( $text->is_blank, undef,       'Not blank' );

my $spaces = Autosite::Param::Field->new( value => '   ' );

is( $spaces->value,    '   ', 'Spaces' );
is( $spaces->is_blank, 1,     'Is blank' );
is( $spaces->is_null,  undef, 'Is not null' );

$spaces->trim();

is( $spaces->value, '', 'After trim' );

my $trimmed = Autosite::Param::Field->new('that ');

is( $trimmed->value_trimmed, 'that',  'Return trimmed' );
is( $trimmed->value,         'that ', 'Not changed' );

$trimmed->trim();

is( $trimmed->value,          'that', 'After trim changed' );
is( $trimmed->is_like_number, 0,      'Not a number' );
is( $trimmed->is_like_email,  0,      'Is not an email' );

my $snip = <<HTML;
<title>This sucks</title>
HTML

my $html = Autosite::Param::Field->new($snip);
is( $html->html_stripped, "This sucks\n", 'No html' );
$html->strip_html();
is( "$html", "This sucks\n", 'Removed html' );

my $html_enc = Autosite::Param::Field->new($snip);
is( $html_enc->encoded, "&lt;title&gt;This sucks&lt;/title&gt;\n",
    'HTML encoded' );

my $html_dec = Autosite::Param::Field->new($html_enc);
is( $html_dec->decoded, "<title>This sucks</title>\n", 'Decode HTML' );

my $email       = 'test@server.com';
my $email_field = Autosite::Param::Field->new($email);

is( $email_field->is_like_email, 1, 'Is an email' );

my $one_param   = Autosite::Param::Field->new('same thing');
my $other_param = Autosite::Param::Field->new('same thing');
my $third_param = Autosite::Param::Field->new('not same thing');

cmp_ok( $one_param, 'eq', $other_param, 'Same content' );
cmp_ok( $one_param, 'ne', $third_param, 'Not same instance' )
  ;
