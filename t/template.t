#!perl

use Autosite::Template;
use Test::More tests => 1;
use Test::Exception;

my $template = Autosite::Template->new;
throws_ok( sub { $template->render() },
 'Autosite::Error', 'Missing parameters' );
