package String::Trim;

use strict;
use base qw(autobox);

sub import {
    my $class = shift;
    $class->SUPER::import( STRING => 'String::Trim::Scalar' );
}

package String::Trim::Scalar;

use strict;

sub trim {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    $string;
}

1;