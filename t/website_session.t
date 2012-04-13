#!perl

use strict;
use warnings;
use Website::Session;
use Test::More tests => 4;
use Test::Exception;

my $session = Website::Session->new;
$session->data->{username} = 'anonymous';
$session->key('super secret key');

my $for_cookie = $session->create('my_site_session_id');

ok( $for_cookie, 'Returned encrypted string to use as session value' );

my $session_check = Website::Session->new;
$session_check->key('super secret key');

my $obj = $session_check->validate($for_cookie);

is( $obj->{id}, 'my_site_session_id',
    'Session passes verification after decrypt' );

my $session_other = Website::Session->new;
my $invalid       = $session_other->validate('will fail is not valid');

is( $invalid, undef, 'Not a valid session' );

my $session_diff = Website::Session->new;
$session_diff->key('if you change the key it wont work');

my $invalid_key = $session_diff->validate($for_cookie);
is( $invalid_key, undef, 'Not a valid key used when decrypt' );
