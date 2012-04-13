package Website::Session;

use strict;
use warnings;
use autodie;
use Try::Tiny;
use Crypt::CBC;
use String::CRC32;
use Storable qw();
use MIME::Base64 qw();
use Class::Accessor::Fast qw(antlers);
use 5.012_001;

has 'id'   => ( is => 'rw' );
has 'key'  => ( is => 'rw' );
has 'data' => ( is => 'rw' );

use constant KEY => 'z6g@AJoIi$LfasQg*QD3rk#sUbST/8JISPxuXW&sgmXrNFq4%xy0wzQbe'; # must be configurable

sub new {
    my ($class) = @_;
    return bless( { id => '', key => undef, data => {} }, $class );
}

sub create {

    my $self = shift;
    my $id   = shift || die 'Can\'t work with empty string';

    $self->id($id);    # usually the cookie name for your site

    return $self->_encrypt( Storable::freeze($self) );

}

sub validate {

    my $self  = shift;
    my $crypt = shift;
    my $ses   = undef;
    
    try {

        # decrypt and deserialize
        $ses = Storable::thaw( $self->_decrypt($crypt) );

    };

    return $ses;

}

sub cipher {

    my $self = shift;
    my $key  = KEY;

    $key = $self->key if defined $self->key;

    return Crypt::CBC->new(
        -key    => $key,
        -cipher => 'Blowfish',
    );

}

sub _encrypt {

    my $self       = shift;
    my $plain_text = shift;

    my $crc32 = String::CRC32::crc32($plain_text);

    my $res = MIME::Base64::encode(
        $self->cipher->encrypt( pack( 'La*', $crc32, $plain_text ) ), "" );

    $res =~ tr{=+/}{_*-};

    return $res;
}

sub _decrypt {

    my $self   = shift;
    my $cookie = shift;

    $cookie =~ tr{_*-}{=+/};

    my ( $crc32, $plain_text ) = unpack "La*",
      $self->cipher->decrypt( MIME::Base64::decode($cookie) );
      
    return $crc32 == String::CRC32::crc32($plain_text) ? $plain_text : undef;
}

1;
