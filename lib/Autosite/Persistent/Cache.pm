
package Autosite::Persistent::Cache;

use strict;
use warnings;
use autodie;
use 5.012_001;

our $_cache = {};

sub get {
    my $self = shift;
    my $key  = shift;
    return $_cache->{$key};
}

sub set {
    my $self     = shift;
    my $key      = shift;
    my $contents = shift;
    $_cache->{$key} = $contents;
    return;
}

sub store_count {
    my $self = shift;
    return scalar keys %{$_cache};
}

sub detect {
    my $self = shift;
    my $key  = shift;
    return exists $_cache->{$key} ? 1 : 0;
}

1;
