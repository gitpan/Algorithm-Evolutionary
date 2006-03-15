use strict;
use warnings;

=head1 NAME

    Algorithm::Evolutionary::Individual::String - A character string to be evolved. Useful mainly in word games

=head1 SYNOPSIS

    use Algorithm::Evolutionary::Individual::String;

    my $indi = new Algorithm::Evolutionary::Individual::String ['a'..'z'], 10;
                                   # Build random bitstring with length 10

    my $indi3 = new Algorithm::Evolutionary::Individual::String;
    $indi3->set( { length => 20, 
		   chars => ['A'..'Z'] } );   #Sets values, but does not build the string
    $indi3->randomize(); #Creates a random bitstring with length as above
    print $indi3->Atom( 7 );       #Returns the value of the 7th character
    $indi3->Atom( 3, 'Q' );       #Sets the value

    $indi3->addAtom( 'K' ); #Adds a new character to the bitstring at the end

    my $indi4 = Algorithm::Evolutionary::Individual::String->fromString( 'esto es un string');   #Creates an individual from that string

    my $indi5 = $indi4->clone(); #Creates a copy of the individual

    my @array = qw( a x q W z �); #Tie a String individual
    tie my @vector, 'Algorithm::Evolutionary::Individual::String', @array;
    print tied( @vector )->asXML();
    
    print $indi3->asString(); #Prints the individual
    print $indi3->asXML(); #Prints it as XML. See 

    my $xml=<<EOC;
<indi type='String'>
    <atom>a</atom><atom>z</atom><atom>q</atom><atom>i</atom><atom>h</atom>
</indi>
EOC
    $indi4=  Algorithm::Evolutionary::Individual::String->fromXML( $xml );

=head1 Base Class

L<Algorithm::Evolutionary::Individual::Base>

=head1 DESCRIPTION

String Individual for a evolutionary algorithm. Contains methods to handle strings 
easily. It is also TIEd so that strings can be handled as arrays.

=head1 METHODS

=cut

package Algorithm::Evolutionary::Individual::String;
use Carp;
use Exporter;

our ($VERSION) = ( '$Revision: 1.7 $ ' =~ /(\d+\.\d+)/ );
use Algorithm::Evolutionary::Individual::Base;
our @ISA = qw ( Algorithm::Evolutionary::Individual::Base );

=head2 new

Creates a new random string, with fixed initial length, and uniform
distribution of characters along the character class that is
defined. However, this character class is just used to generate new
individuals and in mutation operators, and the validity is not
enforced unless the client class does it

=cut

sub new {
  my $class = shift; 
  my $self = Algorithm::Evolutionary::Individual::Base::new( $class );
  $self->{_chars} = shift || ['a'..'z'];
  $self->{_length} = shift || 10;
  $self->randomize();
  return $self;
}

sub TIEARRAY {
  my $class = shift; 
  my $self = { _str => join("",@_),
               _length => scalar( @_ ),
               _fitness => undef };
  bless $self, $class;
  return $self;
}

=head2 randomize

Assigns random values to the elements

=cut

sub randomize {
  my $self = shift; 
  $self->{_str} = ''; # Reset string
  for ( my $i = 0; $i <  $self->{_length}; $i ++ ) {
	$self->{_str} .= $self->{_chars}[ rand( @{$self->{_chars}} ) ];
  }
}

=head2 addAtom

Adds an atom at the end

=cut

sub addAtom{
  my $self = shift;
  my $atom = shift;
  $self->{_str}.= $atom;
}

=head2 fromString

Similar to a copy ctor; creates a bitstring individual from a string

=cut

sub fromString  {
  my $class = shift; 
  my $str = shift;
  my $self = Algorithm::Evolutionary::Individual::Base::new( $class );
  $self->{_str} =  $str;
  $self->{_length} = length( $str  );
  return $self;
}

=head2 clone

Similar to a copy ctor: creates a new individual from another one

=cut

sub clone {
  my $indi = shift || croak "Indi to clone missing ";
  my $self = Algorithm::Evolutionary::Individual::Base::new( ref $indi );
  for ( keys %$indi ) {
	$self->{ $_ } = $indi->{$_};
  }
  $self->{_fitness} = undef;
  return $self;
}


=head2 asString

Prints it

=cut

sub asString {
  my $self = shift;
  my $str = $self->{_str} . " -> ";
  if ( defined $self->{_fitness} ) {
	$str .=$self->{_fitness};
  }
  return $str;
}

=head2 Atom

Sets or gets the value of the n-th character in the string. Counting
starts at 0, as usual in Perl arrays.

=cut

sub Atom {
  my $self = shift;
  my $index = shift;
  if ( @_ ) {
    substr( $self->{_str}, $index, 1 ) = substr(shift,0,1);
  } else {
    substr( $self->{_str}, $index, 1 );
  }
}

=head2 TIE methods

String implements FETCH, STORE, PUSH and the rest, so an String
can be tied to an array and used as such.

=cut

sub FETCH {
  my $self = shift;
  return $self->Atom( @_ );
}

sub STORE {
  my $self = shift;
  $self->Atom( @_ );
}

sub PUSH {
  my $self = shift;
  $self->{_str}.= join("", @_ );
}

sub UNSHIFT {
  my $self = shift;
  $self->{_str} = join("", @_ ).$self->{_str} ;
}

sub POP {
  my $self = shift;
  my $pop = substr( $self->{_str}, length( $self->{_str} )-1, 1 );
  substr( $self->{_str}, length( $self->{_str} ) -1, 1 ) = ''; 
  return $pop;
}

sub SHIFT {
  my $self = shift;
  my $shift = substr( $self->{_str}, 0, 1 );
  substr( $self->{_str}, 0, 1 ) = ''; 
}

sub SPLICE {
  my $self = shift;
  substr( $self->{_str}, shift, shift ) = join("", @_ );
}

sub FETCHSIZE {
  my $self = shift;
  return length( $self->{_str} );
}

=head2 length

Returns length of the string that stores the info.

=cut 

sub length {
  my $self = shift;
  return length $self->{_str};
}

=head2 asXML

Prints it as XML. See L<Algorithm::Evolutionary::XML> for more info on this

=cut

sub asXML {
  my $self = shift;
  my $str = $self->SUPER::asXML();
  my $str2 = "> " .join( "", map( "<atom>$_</atom> ", split( "", $self->{_str} )));
  $str =~ s/\/>/$str2/e ;
  return $str."\n</indi>";
}


=head2 Chrom

Sets or gets the variable that holds the chromosome. Not very nice, and
I would never ever do this in C++

=cut

sub Chrom {
  my $self = shift;
  if ( defined $_[0] ) {
	$self->{_str} = shift;
  }
  return $self->{_str}
}

=head1 Known subclasses

=over 4

=item * 

L<Algorithm::Evolutionary::Individual::BitString|Algorithm::Evolutionary::Individual::BitString>

=back

=head2 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2006/03/15 08:51:22 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/Evolutionary/Individual/String.pm,v 1.7 2006/03/15 08:51:22 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.7 $
  $Name $

=cut
