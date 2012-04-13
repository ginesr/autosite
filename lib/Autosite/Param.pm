
package Autosite::Param;

use strict;
use warnings;
use Carp;
use base qw(Class::Accessor::Fast);
use Autosite::Param::Field;
use 5.012_001;

sub new {

    my $classname = shift;
    my @args      = @_;
    my $class     = ref($classname) || $classname;

    if ( ( scalar(@args) % 2 ) == 1 ) {
        croak 'pass arguments as pairs of keys => values';
    }

    my $self   = {@args};
    my @fields = sort keys %{$self};

    __PACKAGE__->mk_accessors(@fields);

    $self->{'_fields'} = \@fields;

    bless $self, $class;

    foreach (@fields) {
        $self->{$_} = Autosite::Param::Field->new( $self->$_ );
    }

    return $self;

}

sub from_plack_new {

    my $classname     = shift;
    my $plack_request = shift;

    my @param = $plack_request->param;
    my %hash  = ();

    foreach (@param) {
        $hash{$_} = [ $plack_request->param($_) ];
    }

    return $classname->new(%hash);

}

sub as_hash {

    my $self = shift;
    return map { $_, $self->$_->value } @{ $self->{'_fields'} };

}

sub as_hash_ref {

    my $self = shift;
    my %hash = $self->as_hash;
    return \%hash;

}

sub is_empty {

    return shift->size ? undef : 1;

}

sub size {

    return scalar( @{ shift->{'_fields'} } );

}

sub all_fields {

    my $self = shift;

    return wantarray
      ? sort @{ $self->{'_fields'} }
      : join( ',', sort @{ $self->{'_fields'} } );

}

sub param {

    my $self  = shift;
    my $param = shift;

    if ( $self->detect($param) ) {
        return $self->$param->value;
    }

    return undef;

}

sub detect {

    my $self  = shift;
    my $param = shift;

    my @defined = grep { /^$param$/ } @{ $self->{'_fields'} };

    return scalar(@defined) >= 1 ? 1 : 0;

}

sub is_multiple {

    my $self  = shift;
    my $param = shift;

    return $self->$param->is_multiple;

}

sub set {

    my $self  = shift;
    my $param = shift;

    # forget it!
    # params are readonly ok?
    carp 'somebody tried to set `' . $param . "' readonly parameter";
}

1;
