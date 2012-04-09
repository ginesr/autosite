package Autosite::String::Trim;

use base qw(autobox);

sub import {
    my $class = shift;
    $class->SUPER::import( STRING => 'Autosite::String::Trim::Scalar' );
}

package Autosite::String::Trim::Scalar;

sub trim {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    $string;
}

1;