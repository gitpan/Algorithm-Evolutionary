use strict;
use warnings;

=head1 NAME

    Algorithm::Evolutionary::Op::CanonicalGA - Canonical Genetic Algorithm, with any representation
                 

=head1 SYNOPSIS

  my $algo = new Algorithm::Evolutionary::Op::CanonicalGA( $eval ); 

  #Define an easy single-generation algorithm with predefined mutation and crossover
  my $m = new Algorithm::Evolutionary::Op::Bitflip; #Changes a single bit
  my $c = new Algorithm::Evolutionary::Op::QuadXOver; #Classical 2-point crossover
  my $generation = new Algorithm::Evolutionary::Op::CanonicalGA( $rr, 0.2, [$m, $c] );

=head1 Base Class

L<Algorithm::Evolutionary::Op::Base|Algorithm::Evolutionary::Op::Base>

=head1 DESCRIPTION

The canonical classical genetic algorithm evolves a population of
bitstrings until they reach the optimum fitness. It performs mutation
on the bitstrings by flipping a single bit, crossover interchanges a
part of the two parents.

The first operator should be unary (a la mutation) and the second
binary (a la crossover) they will be applied in turn to couples of the
population.

=head1 METHODS

=cut

package Algorithm::Evolutionary::Op::CanonicalGA;

our $VERSION = ( '$Revision: 1.2 $ ' =~ /(\d+\.\d+)/ ) ;

use Carp;
use Algorithm::Evolutionary::Wheel;
use Algorithm::Evolutionary::Op::Bitflip;
use Algorithm::Evolutionary::Op::QuadXOver;

use Algorithm::Evolutionary::Op::Easy;
our @ISA = qw(Algorithm::Evolutionary::Op::Easy);

# Class-wide constants
our $APPLIESTO =  'ARRAY';
our $ARITY = 1;

=head2 new

Creates an algorithm, with the usual operators. Includes a default mutation
and crossover, in case they are not passed as parameters

=cut

sub new {
  my $class = shift;
  my $self = {};
  $self->{_eval} = shift || croak "No eval function found";
  $self->{_selrate} = shift || 0.4;
  if ( @_ ) {
      $self->{_ops} = shift;
  } else {
      #Create mutation and crossover
      my $mutation = new Algorithm::Evolutionary::Op::Bitflip;
      push( @{$self->{_ops}}, $mutation );
      my $xover = new Algorithm::Evolutionary::Op::QuadXOver;
      push( @{$self->{_ops}}, $xover );
  }
  bless $self, $class;
  return $self;

}

=head2 apply

Applies the algorithm to the population; checks that it receives a
ref-to-array as input, croaks if it does not. Returns a sorted,
culled, evaluated population for next generation.


=cut

sub apply ($) {
  my $self = shift;
  my $pop = shift || croak "No population here";
  croak "Incorrect type ".(ref $pop) if  ref( $pop ) ne $APPLIESTO;

  my $eval = $self->{_eval};
  for ( @$pop ) {
    my $fitness;  #Evaluates only those that have no fitness
    if ( !defined ($_->Fitness() ) ) {
      $fitness = $eval->( $_ );
      $_->Fitness( $fitness );
    }
  }

  my @newPop;
  my @rates;
  for ( @$pop ) {
    push @rates, $_->{_fitness};
  }
  my $popWheel=new Algorithm::Evolutionary::Wheel @rates;
  my $popSize = scalar @$pop;
  my @ops = @{$self->{_ops}};
  for ( my $i = 0; $i < $popSize*(1-$self->{_selrate})/2; $i ++ ) {
    my $clone1 = $pop->[$popWheel->spin()]->clone();
    my $clone2 = $pop->[$popWheel->spin()]->clone();
    $clone1 = $ops[0]->apply($clone1 ); # This should be a mutation-like op
    $clone2 = $ops[0]->apply( $clone2 );
    $ops[1]->apply( $clone1, $clone2 ); #This should be a
                                          #crossover-like op
    $clone1->Fitness( $eval->( $clone1 ));
    $clone2->Fitness( $eval->( $clone2 ));
    push @newPop, $clone1, $clone2;
  }
  #Re-sort
  @{$pop}[$popSize*$self->{_selrate}..$popSize-1] =  @newPop;
  @$pop = sort { $b->{_fitness} <=> $a->{_fitness} } @$pop;
}

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2002/07/24 19:16:17 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/Evolutionary/Op/Easy.pm,v 1.2 2002/07/24 19:16:17 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.2 $
  $Name $

=cut

"The truth is out there";
