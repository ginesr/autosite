#!perl

use strict;
use warnings;
use Website::Session;
use Test::More tests => 3;
use Test::Exception;

my $cookie_value =
'U2FsdGVkX18-MZsoClIu4b9SGKl7BuiYcNVnmPnBQRFKT4TYG3ExyoCovKXHZqtep*acaOWYgwhfjPohFvDW3bdHeLg1H3bZXVIHnwwU14APUZBSsWZSjE1XhxcFAF5ardWqRnuQoYv0LD2cM2VtqInPujo-BbPT*gVYIj9B40Hh8uS*aAHwEcIeba8fwzof';

my $session_check = Website::Session->new;
my $obj           = $session_check->validate($cookie_value);

is( $obj->id, 'my_site_session_id',
    'Session valid' );

is( $obj->data->{'username'}, 'anonymous', 'Recover data from session' );
is( $obj->data->{'foo'}, 'bar', 'More data from session' );

