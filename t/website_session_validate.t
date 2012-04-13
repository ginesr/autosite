#!perl

use strict;
use warnings;
use Website::Session;
use Test::More tests => 2;
use Test::Exception;

my $cookie_value =
'U2FsdGVkX1-1IDY8SOiImCmzxWHgoAC6qMHV-dbempYply6VNotxWnwQo0TNWtZ4CVhw*61GCTcEyaeSipxE4LXc-MKKKBu6xWFZhz9j7KvbCoObKihc7aSG1pl5vsAc9HQ*V6-gUHzuVuQgaGr2ZIFXc2C5SSPJYk6KSWfENcFFQ-Ches-mbQ__';

my $session_check = Website::Session->new;
my $obj           = $session_check->validate($cookie_value);

is( $obj->id, 'my_site_session_id',
    'Session valid' );

is( $obj->data->{'username'}, 'anonymous', 'Recover data from session' );
