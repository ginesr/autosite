package Autosite::Config;

use strict;
use warnings;
use autodie;
use Mouse;
use Try::Tiny;
use Autosite::Error;
use 5.012_001;

our $VERSION = '0.01';

has 'site_prefix' => (is => 'rw', isa => 'Str', default => '' );
has 'templates_cache' => (is => 'rw', isa => 'Bool', default => 0, lazy => 1);
has 'templates_dir' => (is => 'rw', isa => 'Str', default => '' );
has 'plugins_compile' => (is => 'rw', isa => 'Bool', default => 0, lazy => 1);
has 'plugins_list' => (is => 'rw', isa => 'Str', default => '' );
has 'plugins_folder' => (is => 'rw', isa => 'Str', default => '' );
has 'persistent_cache' => (is => 'rw', isa => 'Bool', default => 0, lazy => 1);

1;