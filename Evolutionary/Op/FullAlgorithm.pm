use strict;
use warnings;

=head1 NAME

    Algorithm::Evolutionary::Op:FullAlgorithm - evolutionary algorithm, single generation, with 
                    variable operators.
                 

=head1 SYNOPSIS

  my $easyEA = Algorithm::Evolutionary::Op::Base->fromXML( $ref->{$xml} );
  $easyEA->apply(\@pop ); 

  #Or using the constructor
   use Algorithm::Evolutionary::Op::Bitflip;
  my $m = new Algorithm::Evolutionary::Op::Bitflip; #Changes a single bit
  my $c = new Algorithm::Evolutionary::Op::Crossover; #Classical 2-point crossover
  my $replacementRate = 0.3; #Replacement rate
  use Algorithm::Evolutionary::Op::RouletteWheel;
  my $popSize = 20;
  my $selector = new Algorithm::Evolutionary::Op::RouletteWheel $popSize; #One of the possible selectors
  use Algorithm::Evolutionary::Op::GeneralGeneration;
  my $onemax = sub { 
    my $indi = shift;
    my $total = 0;
    my $len = $indi->length();
    my $i = 0;
    while ($i < $len ) {
      $total += substr($indi->{'_str'}, $i, 1);
      $i++;
    }
    return $total;
  };
  my $generation = 
    new Algorithm::Evolutionary::Op::GeneralGeneration( $onemax, $selector, [$m, $c], $replacementRate );
  use Algorithm::Evolutionary::Op::GenerationalTerm;
  my $g100 = new Algorithm::Evolutionary::Op::GenerationalTerm 10;
  use Algorithm::Evolutionary::Op::FullAlgorithm;
  my $f = new Algorithm::Evolutionary::Op::FullAlgorithm $generation, $g100;
  print $f->asXML();


=head1 Base Class

L<Algorithm::Evolutionary::Op::Base>

=head1 DESCRIPTION

Easy full algoritm, includes a "generation", that is, a step, and
a termination condition

=cut

package Algorithm::Evolutionary::Op::FullAlgorithm;

our $VERSION = ( '$Revision: 1.3 $ ' =~ /(\d+\.\d+)/ ) ;

use Carp;

use Algorithm::Evolutionary::Op::Base;
our @ISA = qw(Algorithm::Evolutionary::Op::Base);

# Class-wide constants
our $APPLIESTO =  'ARRAY';
our $ARITY = 1;

=head2 new

Takes an already created algorithm and a terminator, and creates an object

=cut

sub new {
  my $class = shift;
  my $algo = shift|| croak "No single generation algo found";
  my $term = shift ||  new  Algorithm::Evolutionary::Op::GenerationalTerm 100;
  my $verbose = shift || 0;
  my $hash = { algo => $algo,
			   terminator => $term,
			   verbose => $verbose };
  my $self = Algorithm::Evolutionary::Op::Base::new( __PACKAGE__, 1, $hash );
  return $self;
}
=head2 set

Sets the instance variables. Takes a ref-to-hash as
input

=cut

sub set {
  my $self = shift;
  my $hashref = shift || croak "No params here";
  my $codehash = shift;
  my $opshash = shift;

  $self->SUPER::set( $hashref );
  #Now reconstruct operators
  for ( keys %$opshash ) {
	$self->{$opshash->{$_}[2]} = 
#	  Algorithm::Evolutionary::Op::Base::fromXML( "Algorithm::Evolutionary::Op::$_", $opshash->{$_} );
	  Algorithm::Evolutionary::Op::Base::fromXML( $_, $opshash->{$_}->[1], $opshash->{$_}->[0] ); 
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

  my $term = $self->{_terminator};
  my $algo = $self->{_algo};
  #Evaluate population, just in case
  my $eval = $algo->{_eval};
  for ( @$pop ) {
    if ( !defined $_->Fitness() ) {
      my $fitness = $eval->($_);
      $_->Fitness( $fitness );
    }
  }
  #Run the algorithm
  do {
	$algo->apply( $pop );
	if  ($self->{_verbose}) {
	  print "Best ", $pop->[0]->asString(), "\n" ;
	  print "Median ", $pop->[@$pop/2]->asString(), "\n";
	  print "Worst ", $pop->[@$pop-1]->asString(), "\n\n";
	}
  } while( $term->apply( $pop ) );
  
}

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2002/09/24 18:40:17 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/Evolutionary/Op/FullAlgorithm.pm,v 1.3 2002/09/24 18:40:17 jmerelo Exp $ 
  $Author: jmerelo $ 

=cut

"The truth is out there";
