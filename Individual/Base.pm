use strict;
use warnings;

=head1 NAME

    Algorithm::Evolutionary::Individual::Base - Base class for chromosomes that knows how to build them, and has
               some helper methods.
                 
=head1 SYNOPSIS

  use  Algorithm::Evolutionary::Individual::Base;
  my $xmlStr="<indi type='BinaryIndi'><atom>1</atom><atom>0</atom><atom>1</atom><atom>0</atom></indi>";
  my $ref = XMLin($xmlStr);

  my $binIndi2 = Algorithm::Evolutionary::Individual::Base->fromXML( $ref ); #From XML fragment
  print $binIndi2->asXML();

  my $indi = Algorithm::Evolutionary::Individual::Base->fromParam( $ref->{initial}{section}{indi}{param} ); #From parametric description

  $binIndi2->Fitness( 3.5 ); #Sets or gets fitness
  print $binIndi2->Fitness();

  my $emptyIndi = new Algorithm::Evolutionary::Individual::Base;

=head1 DESCRIPTION

Base class for individuals in evolutionary computation algorithms

=cut

package Algorithm::Evolutionary::Individual::Base;

use Carp;
use XML::Simple;

our ($VERSION) = ( '$Revision: 1.7 $ ' =~ /(\d+\.\d+)/ );


=head1 METHODS 

=head2 new

Creates a new Base individual of the required class, with a fitness, and sets fitnes to undef.
Takes no params.

=cut

sub new {
  my $class = shift;
  if ( $class !~ /Algorithm::Evolutionary/ ) {
	$class = "Algorithm::Evolutionary::Individual::$class";
  }
  my $options = shift;
  no strict qw(refs);
  my $self = { _fitness => undef }; # Avoid error
  bless $self, $class; # And bless it

  #If the class is not loaded, we load it. The 
  if ( !$INC{"$class\.pm"} ) {
    eval "require $class" || croak "Can't find $class Module";
  }
  if ( $options ) {
	$self->set( $options );
  }

  return $self;
}

=head2 set

Sets values of an individual; takes a hash as input. Keys are prepended an
underscore and turn into instance variables

=cut

sub set {
  my $self = shift; 
  my $hash = shift || croak "No params here";
  for ( keys %{$hash} ) {
    $self->{"_$_"} = $hash->{$_};
  }
}

=head2 fromXML

Takes a definition in the shape <indi><atom>....</indi><fitness></fitness></indi> and turns it into a bitstring, 
if it knows how to do it. The definition must have been processed using XML::Simple. It forwards stuff it does 
not know about to the corresponding subclass, which should implement the C<set> method. The class it refers
about is C<require>d in runtime.

=cut

sub fromXML {
  my $class = shift;
  my $xml = shift || croak "XML fragment missing ";
  if ( (ref $xml) ne "HASH" ) { #We are receiving a string
    $xml = XMLin($xml);
  }
  if ( $class eq __PACKAGE__ ) { #Deduct class from the XML
    $class = "Algorithm::Evolutionary::Individual::$xml->{type}";
  }
  carp "XML type does not correspond to class type" if "Algorithm::Evolutionary::Individual::$xml->{type}" ne $class;
  my $self = Algorithm::Evolutionary::Individual::Base::new( $class );
  
  if ( !$INC{"$class\.pm"} ) {
	eval "require $class"  || croak "Can't find $class\.pm Module";
  }
  no strict qw(refs); # To be able to check if a ref exists or not
  for (@{$xml->{atom}} ) {
    if ( defined(  $_->{content} ) ) { 
	  $self->addAtom($_->{content});
    } else {
      $self->addAtom( $_ );
    }
  }
  ($self->Fitness( $xml->{fitness} ) )if defined $xml->{fitness};
  return $self;
}

=head2 fromParam

Takes an array of params that describe the individual, and build it, with
random initial values.

Params have this shape:
 <param name='type' value='Vector' /> 
 <param name='length' value='2' />
 <param name='range' start='0' end='1' />

The 'type' will show the class of the individuals that are going to
be created, and the rest will be type-specific, and left to the particular
object to interpret.

=cut

sub fromParam {
  my $class = shift;
  my $xml = shift || croak "XML fragment missing ";
  if ( defined $xml->{type}{value} ) {
    $class = "Algorithm::Evolutionary::Individual::$xml->{type}{value}";
  } elsif ( defined $xml->{param}{type}{value} ) {
	$class = "Algorithm::Evolutionary::Individual::$xml->{param}{type}{value}";
  } else {
    $class = "Algorithm::Evolutionary::Individual::$xml->{type}";
  }

  if ( !$INC{"$class\.pm"} ) {
	eval "require $class" || croak "Can't find $class\.pm Module";
  }
  my $self = $class->new();
  my %params;
  if ( defined $xml->{param} ) {
	for (keys %{$xml->{param}} ) {
	  if ( defined  $xml->{param}{$_}{value} ) {
        $params{$_} = $xml->{param}{$_}{value};
	  } else {
        $params{$_} = $xml->{param}{$_};
	  }
	}
  } else {
	for (keys %{$xml} ) {
	  if ( defined  $xml->{$_}{value} ) {
        $params{$_} = $xml->{$_}{value};
	  } else {
        $params{$_} = $xml->{$_};
	  }
	}
  }
  $self->set( \%params );
  $self->randomize();
  return $self;
}

=head2 asXML

Prints it as XML. The caller must close the tags.

=cut

sub asXML {
  my $self = shift;
  my ($opName) = ( ( ref $self) =~ /::(\w+)$/ );
  my $str = "<indi type='$opName' ";
  if ( defined $self->{_fitness} ) {
	$str.= "fitness='$self->{_fitness}'";
  }
  $str.=" />\n\t";
  return $str;
}

=head2 Atom

Sets or gets the value of an atom. Each individual is divided in atoms, which
can be accessed sequentially. If that does not apply, Atom can simply return the
whole individual

=cut

sub Atom {
  croak "This function is not defined at this level, you should override it in a subclass\n";
}

=head2 Fitness

Sets or gets fitness

=cut

sub Fitness {
  my $self = shift;
  if ( defined $_[0] ) {
	$self->{_fitness} = shift;
  }
  return $self->{_fitness};
}

=head2 Chrom

Sets or gets the chromosome itself, that is, the data
structure evolved. Since each derived class has its own
data structure, and its own name, it is left to them to return 
it

=cut

sub Chrom {
  my $self = shift;
  croak "To be implemented in derived classes!";
}

=head1 Known subclasses

=over 4

=item * 

L<Algorithm::Evolutionary::Individual::Vector|Algorithm::Evolutionary::Individual::Vector>

=item * 

L<Algorithm::Evolutionary::Individual::String|Algorithm::Evolutionary::Individual::String>

=item * 

L<GPIndi|GPIndi>

=back

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2002/06/21 09:22:00 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/Evolutionary/Individual/Base.pm,v 1.7 2002/06/21 09:22:00 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.7 $
  $Name $

=cut

"The plain truth";

