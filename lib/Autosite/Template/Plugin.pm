package Autosite::Template::Plugin;

use strict;
use warnings;
use autodie;
use Mouse;
use Try::Tiny;
use Autosite::Error;
use 5.012_001;

our $VERSION = '0.01';

has 'active' => (is => 'rw', isa => 'Bool', default => 0, lazy => 1);
has 'variable' => (is => 'rw', isa => 'Str', default => '' );
has 'content' => (is => 'rw', isa => 'Str', default => '' );

__PACKAGE__->meta->make_immutable();

1;