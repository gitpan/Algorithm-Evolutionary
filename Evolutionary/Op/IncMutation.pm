use strict;
use warnings;

=head1 NAME

  Algorithm::Evolutionary::Op::IncMutation - Increments/decrements by one the value of one of the components
                of the string, takes into account the char class

=cut

=head1 SYNOPSIS

  my $xmlStr2=<<EOC;
  <op name='IncMutation' type='unary' rate='0.5' />
  EOC
  my $ref2 = XMLin($xmlStr2);

  my $op2 = Algorithm::Evolutionary::Op::Base->fromXML( $ref2 );
  print $op2->asXML(), "\n*Arity ", $op->arity(), "\n";

  my $op = new Algorithm::Evolutionary::Op::IncMutation; #Create from scratch

=head1 Base Class

L<Algorithm::Evolutionary::Op::Base|Algorithm::Evolutionary::Op::Base>


=head1 DESCRIPTION

Mutation operator for a GA; changes a single element in a string

=cut

package Algorithm::Evolutionary::Op::IncMutation;

our ($VERSION) = ( '$Revision: 1.2 $ ' =~ /(\d+\.\d+)/ );


use Carp;

use Algorithm::Evolutionary::Op::Base;
our @ISA = qw(Algorithm::Evolutionary::Op::Base);

#Class-wide constants
our $APPLIESTO =  'Algorithm::Evolutionary::Individual::String';
our $ARITY = 1;

=head2 create


Creates a new mutation operator.

=cut

sub create {
  my $class = shift;
  my $self = {};
  bless $self, $class;
  return $self;
}

=head2 apply

Applies mutation operator to a "Chromosome", a bitstring, really. Can be
applied only to I<victims> with the C<_str> instance variable; but
it checks before application that both operands are of the required type.

=cut

sub apply ($;$){
  my $self = shift;
  my $arg = shift || croak "No victim here!";
  my $victim = $arg->clone();
  croak "Incorrect type ".(ref $victim) if ! $self->check( $victim );
  my $rnd = int (rand( length( $victim->{_str} ) ));
  my $char = $victim->Atom( $rnd );
  #Compute its place in the array
  my $i = 0;
  while (  ($victim->{_chars}[$i] ne $char ) 
		   && ($i < @{$victim->{_chars}}) ) { $i++;};
  my $newpos = ( rand() > 0.5)?$i-1:$i+1;
  $newpos = @{$victim->{_chars}}-1 if !$newpos;
  $newpos = 0 if $newpos >= @{$victim->{_chars}};
  substr( $victim->{_str}, $rnd, 1 ) =  $victim->{_chars}[$newpos];
  $victim->Fitness(undef);
  return $victim;
}

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2002/06/18 12:21:13 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/Evolutionary/Op/IncMutation.pm,v 1.2 2002/06/18 12:21:13 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.2 $
  $Name $


=cut

