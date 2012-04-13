#perl

use strict;
use warnings;
use Test::More tests => 11;
use Test::Exception;
use Autosite::Param;

my $params = Autosite::Param->new(
    email    => 'mail@test.com',
    name     => 'Foo',
    lastname => 'Bar'
);

is( $params->size,            3,     'Three params' );
is( $params->is_empty,        undef, 'Not empty' );
is( $params->detect('email'), 1,     'Param exists' );
is( $params->detect('blah'),  0,     'Param not exists' );
is( $params->param('name'),   'Foo', 'Param like CGI' );
is( $params->email->value, 'mail@test.com', 'Access field with accessor' );

my %FORM = $params->as_hash;

is( $FORM{name}, 'Foo', 'Convert params to hash' );

my $form = $params->as_hash_ref;

is( $form->{lastname}, 'Bar', 'Convert params to hash ref' );

my @fields = $params->all_fields;

is( $fields[0], 'email',    'Field list sorted 1' );
is( $fields[2], 'name',     'Field list sorted 2' );
is( $fields[1], 'lastname', 'Field list sorted 3' );

