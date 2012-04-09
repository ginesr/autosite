package Autosite::Config;

use strict;
use warnings;
use autodie;
use Moose;
use Try::Tiny;
use Autosite::Error;
use 5.012_001;

our $VERSION = '0.01';

has 'templates_cache' => (is => 'rw', isa => 'Bool', default => 0, lazy => 1);
has 'templates_dir' => (is => 'rw', isa => 'Str', default => '' );

1;