package Autosite::Param::Field;

use strict;
use warnings;
use autodie;
use Carp;
use HTML::Entities qw();
use HTML::Scrubber;
use Scalar::Util qw(looks_like_number);
use Email::Valid;
use feature qw(switch);
use 5.012_001;

use overload
  '""'     => 'stringify',
  '!='     => \&_not_equals,
  'ne'     => \&_not_equals,
  '=='     => \&_equals_than,
  'eq'     => \&_equals_than,
  fallback => 1;

sub new {

    my $classname  = shift;
    my @args       = @_;
    my $class      = ref($classname) || $classname;
    my $ref        = ref( $args[0] );
    my $args_count = scalar(@args);

    if ( $args_count == 1 and not $ref ) {

        # single argument asume is the value :)
        @args = ( value => $args[0] );
    }
    elsif ( $args_count == 1 and $ref eq 'ARRAY' ) {
        given ( scalar @{ $args[0] } ) {
            when (1) { @args = ( value => shift $args[0] ) }
            default  { @args = ( multi => \@{$args[0]}, value => $args[0][-1] ) };
        }
    }
    elsif ( $args_count == 1 and $ref eq __PACKAGE__ ) {
        my $cloned = $args[0]->value;
        @args = ( value => $cloned );
    }
    elsif ( ( $args_count % 2 ) == 1 ) {
        croak 'pass arguments as pairs of keys => values';
    }

    my $self   = {@args};
    my @fields = keys %{$self};

    return bless $self, $class;

}

sub stringify {

    return shift->value;

}

sub is_blank {

    my $self   = shift;
    my $string = $self->value;

    $string =~ s/^\s+//g;
    $string =~ s/\s+$//g;

    return !$string ? 1 : undef;

}

sub is_null {

    return shift->length ? undef : 1;

}

sub length {

    return length shift->value;

}

sub is_like_number {

    return looks_like_number( shift->value );

}

sub is_like_email {

    return Email::Valid->address( shift->value ) ? 1 : 0;
}

sub trim {

    my $self = shift;
    my $string = $self->value || '';

    $string =~ s/^\s+//g;
    $string =~ s/\s+$//g;

    $self->{value} = $string;

    return $string;

}

sub value_trimmed {

    my $self   = shift;
    my $string = $self->value;

    $string =~ s/^\s+//g;
    $string =~ s/\s+$//g;

    return $string;

}

sub is_multiple {
    my $self = shift;
    return (exists $self->{multi}) ? 1 : 0;
}

sub at {
    my $self = shift;
    my $index = shift;
    
    if ( $self->is_multiple ) {
        return $self->{multi}->[$index];
    }
    return $self->value;
}

sub value {
    
    my $self = shift;
    my $val = $self->{value};
    
    if ( $self->is_multiple ) {
        return wantarray ? @{ $self->{multi} } : $val; 
    }
    
    return $val;

}

sub html_stripped {

    return HTML::Scrubber->new->scrub( shift->value );

}

sub strip_html {

    my $self = shift;

    $self->{value} = HTML::Scrubber->new->scrub( $self->{value} );

    return $self->value;

}

sub encoded {

    return HTML::Entities::encode_entities( shift->value );

}

sub decoded {

    return HTML::Entities::decode_entities( shift->value );

}

sub _equals_than {
    my ( $self, $another_param ) = @_;
    return ( $self->value eq $another_param->value ) || 0;
}

sub _not_equals {
    my ( $self, $another_param ) = @_;
    return ( $self->value eq $another_param->value ) || 1;
}

1;
