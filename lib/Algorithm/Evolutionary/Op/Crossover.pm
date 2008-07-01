use strict;
use warnings;

=head1 NAME

  Algorithm::Evolutionary::Op::Crossover - n-point crossover
    operator; puts a part of the second operand into the first
    operand; can be 1 or 2 points.
             

=head1 SYNOPSIS

  #Create from XML description using EvoSpec
  my $xmlStr3=<<EOC;
  <op name='Crossover' type='binary' rate='1'>
    <param name='numPoints' value='3' /> #Max is 2, anyways
  </op>
  EOC
  my $op3 = Algorithm::Evolutionary::Op::Base->fromXML( $xmlStr3 );
  print $op3->asXML(), "\n";

  #Apply to 2 Individuals. Could be String.
  my $indi = new Algorithm::Evolutionary::Individual::BitString 10;
  my $indi2 = $indi->clone();
  my $indi3 = $indi->clone();
  my $offspring = $op3->apply( $indi2, $indi3 ); #$indi2 == $offspring

  #Initialize using OO interface
  my $op4 = new Algorithm::Evolutionary::Op::Crossover 3; #Crossover with 3 crossover points

=head1 Base Class

L<Algorithm::Evolutionary::Op::Base|Algorithm::Evolutionary::Op::Base>

=head1 DESCRIPTION

Crossover operator for a Individuals of type
L<Algorithm::Evolutionary::Individual::String|Individual::String> and
their descendants
(L<Algorithm::Evolutionary::Individual::BitString|Individual::BitString>). Crossover
for L<Algorithm::Evolutionary::Individual::Vector|Individual::Vector>
would be  L<Algorithm::Evolutionary::Op::VectorCrossover|Op::VectorCrossover>


=head1 METHODS

=cut

package Algorithm::Evolutionary::Op::Crossover;

our ($VERSION) = ( '$Revision: 1.2 $ ' =~ /(\d+\.\d+)/ );

use Clone::Fast qw(clone);
use Carp;

use Algorithm::Evolutionary::Op::Base;
our @ISA = ('Algorithm::Evolutionary::Op::Base');

#Class-wide constants
our $APPLIESTO =  'Algorithm::Evolutionary::Individual::String';
our $ARITY = 2;

=head2 new

Creates a new n-point crossover operator, with 2 as the default number of points

=cut

sub new {
  my $class = shift;
  my $hash = { numPoints => shift || 2 };
  my $rate = shift || 1;
  my $self = Algorithm::Evolutionary::Op::Base::new( __PACKAGE__, $rate, $hash );
  return $self;
}

=head2 create

Creates a new 1 or 2 point crossover operator. But this is just to have a non-empty chromosome
Defaults to 2 point

=cut

sub create {
  my $class = shift;
  my $self;
  $self->{_numPoints} = shift || 2;
  bless $self, $class;
  return $self;
}

=head2 apply

Applies xover operator to a "Chromosome", a string, really. Can be
applied only to I<victims> with the C<_str> instance variable; but
it checks before application that both operands are of type
L<BitString|Algorithm::Evolutionary::Individual::String>.

Changes the first parent, and returns it. If you want to change both
parents at the same time, check L<Algorithm::Evolutionary::Op:QuadXOver|Algorithm::Evolutionary::Op:QuadXOver>


=cut

sub  apply ($$$){
  my $self = shift;
  my $arg = shift || croak "No victim here!";
#  my $victim = $arg->clone();
  my $victim = clone( $arg );
  my $victim2 = shift || croak "No victim here!";
  croak "Incorrect type ".(ref $victim) if !$self->check($victim);
  croak "Incorrect type ".(ref $victim2) if !$self->check($victim2);
  my $minlen = (  length( $victim->{_str} ) >  length( $victim2->{_str} ) )?
	 length( $victim2->{_str} ): length( $victim->{_str} );
  my $pt1 = int( rand( $minlen ) );
  my $range = 1 + int( rand( $minlen  - $pt1 ) );
#  print "Puntos: $pt1, $range \n";
  croak "No number of points to cross defined" if !defined $self->{_numPoints};
  if ( $self->{_numPoints} > 1 ) {
	$range =  int ( rand( length( $victim->{_str} ) - $pt1 ) );
  }
  
  substr( $victim->{_str}, $pt1, $range ) = substr( $victim2->{_str}, $pt1, $range );
  $victim->Fitness( undef );
  return $victim; 
}

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2008/06/26 11:37:43 $ 
  $Header: /cvsroot/opeal/Algorithm-Evolutionary/lib/Algorithm/Evolutionary/Op/Crossover.pm,v 1.2 2008/06/26 11:37:43 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.2 $
  $Name $

=cut
