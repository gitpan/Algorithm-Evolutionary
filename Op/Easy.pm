use strict;
use warnings;

=head1 NAME

    Algorithm::Evolutionary::Op::Easy - evolutionary algorithm, single generation, with 
                    variable operators.
                 

=head1 SYNOPSIS

  my $easyEA = Algorithm::Evolutionary::Op::Base->fromXML( $ref->{initial}{section}{pop}{op} );
  # Parsed XML fragment, see samples

  for ( my $i = 0; $i < $ref->{initial}{section}{pop}{op}{param}{maxgen}{value}; $i++ ) {
    print "<", "="x 20, "Generation $i", "="x 20, ">\n"; 
    $easyEA->apply(\@pop ); 
    for ( @pop ) { 
      print $_->asString, "\n"; 
    } 
  }

  #Define a default algorithm with predefined evaluation function,
  #Mutation and crossover. Default selection rate ls 4
  my $algo = new Algorithm::Evolutionary::Op::Easy( $eval ); 

  #Define an easy single-generation algorithm with predefined mutation and crossover
  my $m = new Algorithm::Evolutionary::Op::Bitflip; #Changes a single bit
  my $c = new Algorithm::Evolutionary::Op::Crossover; #Classical 2-point crossover
  my $generation = new Algorithm::Evolutionary::Op::Easy( $rr, 0.2, [$m, $c] );

=head1 Base Class

L<Algorithm::Evolutionary::Op::Base|Algorithm::Evolutionary::Op::Base>

=cut

=head1 DESCRIPTION

Genetic algorithm that uses the other component. Must take as input the operators thar are going to be
used, along with its priorities

=head1 METHODS

=cut

package Algorithm::Evolutionary::Op::Easy;

our $VERSION = ( '$Revision: 1.1 $ ' =~ /(\d+\.\d+)/ ) ;

use Carp;
use Algorithm::Evolutionary::Op::Bitflip;
use Algorithm::Evolutionary::Op::Crossover;

use Algorithm::Evolutionary::Op::Base;
our @ISA = qw(Algorithm::Evolutionary::Op::Base);

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
      my $xover = new Algorithm::Evolutionary::Op::Crossover;
      push( @{$self->{_ops}}, $xover );
  }
  bless $self, $class;
  return $self;

}

=head2 set

Sets the instance variables. Takes a ref-to-hash as
input

=cut

sub set {
  my $self = shift;
  my $hashref = shift || croak "No params here";
  my $codehash = shift || croak "No code here";
  my $opshash = shift || croak "No ops here";
  $self->{_selrate} = $hashref->{selrate};

  for ( keys %$codehash ) {
	$self->{"_$_"} =  eval "sub {  $codehash->{$_} } ";
  }

  $self->{_ops} =();
  for ( keys %$opshash ) {
	push @{$self->{_ops}},  Algorithm::Evolutionary::Op::Base->fromXML( $opshash->{$_}, $_ );
  }
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

  #Evaluate
  my $eval = $self->{_eval};
  my @ops = @{$self->{_ops}};
  my @popEval;
  for ( @$pop ) {
	my $fitness;
	if ( !defined ($_->Fitness() ) ) {
	  $fitness = $eval->( $_ );
	  $_->Fitness( $fitness );
	}
	push @popEval, $_;
  }

  #Sort
  my @popsort = sort { $b->{_fitness} <=> $a->{_fitness}; }
					  @popEval ;

  #Eliminar
  my $pringaos = ($#popsort+1)*$self->{_selrate};
  splice @popsort, $#popsort - $pringaos, $pringaos;

  my $totRate = 0;
  for ( @ops ) {
	$totRate += $_->{rate};
  }

  for ( @ops ) {
	my $relRate = $_->{rate} / $totRate;
	for ( my $i = 0; $i < $pringaos*$relRate; $i++ ) {
	  my @offspring;
	  for ( my $j = 0; $j < $_->arity(); $j ++ ) {
		my $chosen = $popsort[ rand( $#popsort )];
		push( @offspring, $chosen->clone() );
	  }
	  my $mutante = $_->apply( @offspring );
	  push( @popsort, $mutante );
	}
  }

  #Return
  for ( my $i = 0; $i <= $#popsort; $i++ ) {
#	print $i, "->", $popsort[$i]->asString, "\n";
	$pop->[$i] = $popsort[$i];
  }

  
}

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2002/06/20 15:41:35 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/Evolutionary/Op/Easy.pm,v 1.1 2002/06/20 15:41:35 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.1 $
  $Name $

=cut

"The truth is out there";
