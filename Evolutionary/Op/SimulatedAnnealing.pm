use strict;
use warnings;

=head1 NAME

    SimulatedAnnealing - An operator that performs the simulated annealing algorithm
                          on an individual, using an external freezer.

=head1 SYNOPSIS

  #Define an algorithm
  my $m  = new Algorithm::Evolutionary::Op::BitFlip; #Changes a single bit
  my $freezer = new Algorithm::Evolutionary::Op:LinearFreezer( $initTemp );
  my $sa = new Algorithm::Evolutionary::Op::SimulatedAnnealing( $eval, $m, $freezer, $initTemp, $minTemp, $numChanges );

=head1 Base Class

L< Algorithm::Evolutionary::Op::Base| Algorithm::Evolutionary::Op::Base>

=head1 DESCRIPTION

Simulated Annealing

=head1 METHODS

=cut

package Algorithm::Evolutionary::Op::SimulatedAnnealing;

our $VERSION = ( '$Revision: 1.1 $ ' =~ /(\d+\.\d+)/ ) ;
use Carp;
use Algorithm::Evolutionary::Op::LinearFreezer;
use Algorithm::Evolutionary::Op::Base;
our @ISA = qw( Algorithm::Evolutionary::Op::Base);

=head2 new

Creates a S.A. algorithm

=cut

sub new {
  my $class = shift;
  my $self = {};
  $self->{_eval} = shift || croak "No eval function found";
  $self->{_op} = shift || croak "No operator found";
  $self->{_freezer} = shift || croak "No freezer found";
  $self->{_initTemp} = shift || 0.2;
  $self->{_minTemp} = shift || 0.001;
  $self->{_numChanges} = shift || 7;
  $self->{_verbose} = shift || 0;

  bless $self, $class;
  return $self;
}

=cut

=head2 apply

Applies the algorithm to the individual

=cut

sub run ($) {
  my $self  = shift;
  my $indiv = shift || croak "there is no individual";

  #Evaluate
  my $eval = $self->{_eval};
  my $op = $self->{_op};
  my $freezer = $self->{_freezer};
  my $initTemp= $self->{_initTemp};
  my $minTemp = $self->{_minTemp};
  my $numChanges = $self->{_numChanges};
  my $verbose= $self->{_verbose};

  my $t = $initTemp ;
  while ( $t > $minTemp ) {
    for(my $j=0; $j < $numChanges; $j++) {

      my $padre  =  $indiv->clone();
      my $mutado = $op->apply( $padre );

      #Calculate the original individual fitness, if it's necessary
      my $fitness1;
      if ( !defined ($indiv->Fitness() ) ) {
	$fitness1 = $eval->( $indiv );
	$indiv->Fitness( $fitness1 );
      }
      else
	{$fitness1 = $indiv->Fitness(); }

      #Calculate the mutated individual fitness, if it's necessary
      my $fitness2;
      if ( !defined ($mutado->Fitness() ) ) {
	$fitness2 = $eval->( $mutado );
	$mutado->Fitness( $fitness2 );
      }
      else
        {$fitness2 = $mutado->Fitness();}

      my $delta = $fitness1 - $fitness2;

      print "Original=".$indiv->asString."\nMutated =". $mutado->asString."\n" if ( $verbose >= 2);
      print "Fitness1: $fitness1 \tFitness2: $fitness2 \t delta=$delta \n" if ( $verbose >= 2);

      if ( ($delta<0) || (rand()<exp((-1*$delta)/$t)) ) {
	$indiv = $mutado;
      }
    }
    $t = $freezer->apply($t);

    print "T: \t$t \n" if ( $verbose >= 1);
    print $indiv->asString, "\n" if ( $verbose >= 1);
  }

  return $indiv;
}

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2002/07/25 11:44:00 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/Evolutionary/Op/SimulatedAnnealing.pm,v 1.1 2002/07/25 11:44:00 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.1 $
  $Name $

=cut
