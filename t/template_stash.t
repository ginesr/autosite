#!perl

use strict;
use warnings;
use autodie;
use Autosite::Template;
use Test::More tests => 2;
use Test::Exception;
use Data::Dumper qw(Dumper);

my $template = Autosite::Template->new;

$template->file('templates/test3.htm');

push @{ $template->stash }, \%ENV;

my $output =
  $template->render( { TEST => 'some text' }, [ 'PWD', 'HOME' ] );

like( $output, qr/$ENV{PWD}/, 'From stash 1' );
like( $output, qr/$ENV{HOME}/, 'From stash 2' );
