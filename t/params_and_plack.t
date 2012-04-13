#perl

use strict;
use warnings;
use Test::More tests => 8;
use Test::Exception;
use Forms::Param;
use Plack::Request;

my $env = {
    'REQUEST_URI'          => '/~chines/env.pl?test=1&foo=bar&multi=2&multi=2',
    'QUERY_STRING'         => 'test=1&foo=bar&multi=1&multi=duh',
    'HTTP_ACCEPT_CHARSET'  => 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
    'GATEWAY_INTERFACE'    => 'CGI/1.1',
    'HTTP_ACCEPT_ENCODING' => 'gzip,deflate,sdch',
    'HTTP_CONNECTION'      => 'keep-alive',
    'REQUEST_METHOD'       => 'GET',
    'HTTP_ACCEPT_LANGUAGE' => 'en-US,en;q=0.8',
    'REMOTE_ADDR'          => '127.0.0.1',
    'SERVER_PROTOCOL'      => 'HTTP/1.1',
    'PATH'                 => '/usr/local/bin:/usr/bin:/bin',
};
my $req = Plack::Request->new($env);

is( $req->param('foo'), 'bar', 'Param exists in plack' );

my $params = Forms::Param->from_plack_new($req);

is( $params->size,           3,     'Two params' );
is( $params->is_empty,       undef, 'Not empty' );
is( $params->detect('foo'),  1,     'Param exists' );
is( $params->detect('blah'), 0,     'Param not exists' );
is( $params->foo->value,     'bar', 'Access field with accessor' );

is( $params->is_multiple('multi'), 1,     'Two parameters with same name' );
is( $params->multi->value,         'duh', 'Multi uses last value given' );
