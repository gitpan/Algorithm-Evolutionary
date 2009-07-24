use strict;
use warnings;

=head1 NAME

Algorithm::Evolutionary::Op::Mutation - BitFlip mutation, changes several bits in a bitstring, depending on the probability

=head1 SYNOPSIS

  use Algorithm::Evolutionary::Op::Mutation;

  my $xmlStr=<<EOC;
  <op name='Mutation' type='unary' rate='2'>
    <param name='probability' value='0.5' />
  </op>
  EOC
  my $ref = XMLin($xmlStr);

  my $op = Algorithm::Evolutionary::Op::->fromXML( $ref );
  print $op->asXML(), "\n*Arity ->", $op->arity(), "\n";

  my $op = new Algorithm::Evolutionary::Op::Mutation (0.5 ); #Create from scratch

=head1 Base Class

L<Algorithm::Evolutionary::Op::Base|Algorithm::Evolutionary::Op::Base>

=head1 DESCRIPTION

Mutation operator for a GA

=cut

package  Algorithm::Evolutionary::Op::Mutation;

our ($VERSION) = ( '$Revision: 3.0 $ ' =~ /(\d+\.\d+)/ );

use Carp;

use base 'Algorithm::Evolutionary::Op::Base';

#Class-wide constants
our $APPLIESTO =  'Algorithm::Evolutionary::Individual::BitString';
our $ARITY = 1;

=head1 METHODS

=head2 new( [$mutation_rate] [, $operator_probability] )

Creates a new mutation operator with a bitflip application rate, which defaults to 0.5,
and an operator application rate (general for all ops), which defaults to 1.

=cut

sub new {
  my $class = shift;
  my $mutRate = shift || 0.5; 
  my $rate = shift || 1;

  my $hash = { mutRate => $mutRate };
  my $self = Algorithm::Evolutionary::Op::Base::new( 'Algorithm::Evolutionary::Op::Mutation', $rate, $hash );
  return $self;
}


=head2 create( [$operator_probability] )

Creates a new mutation operator with an application rate. Rate defaults to 0.5 (which is rather bit, you should not rely on it).

Called create to distinguish from the classwide ctor, new. It just
makes simpler to create a Mutation Operator

=cut

sub create {
  my $class = shift;
  my $rate = shift || 0.5; 

  my $self = {_mutRate => $rate };

  bless $self, $class;
  return $self;
}

=head2 apply( $chromosome )

Applies mutation operator to a "Chromosome", a bitstring, really. Can be
applied only to I<victims> with the C<_str> instance variable; 
it checks before application that the operand is of type
L<Algorithm::Evolutionary::Individual::BitString|Algorithm::Evolutionary::Individual::BitString>. 
It returns the victim.

=cut

sub apply ($;$) {
  my $self = shift;
  my $arg = shift || croak "No victim here!";
  my $victim = $arg->clone();
  croak "Incorrect type ".(ref $victim) if ! $self->check( $victim );
  for ( my $i = 0; $i < length( $victim->{_str} ); $i ++ ) {
      if ( rand() < $self->{_mutRate} ) {
	  my $bit = $victim->Atom($i);
	  $victim->Atom($i,  $bit?0:1 );
      }
  }
  $victim->{'_fitness'} = undef ;
  return $victim;
}

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2009/07/24 08:46:59 $ 
  $Header: /cvsroot/opeal/Algorithm-Evolutionary/lib/Algorithm/Evolutionary/Op/Mutation.pm,v 3.0 2009/07/24 08:46:59 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 3.0 $
  $Name $

=cut

