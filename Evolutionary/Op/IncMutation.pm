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

  Mutation operator for a GA; changes a single element in a string by
  changing it to the next in the sequence deducted from the chromosome
  itself.

=cut

package Algorithm::Evolutionary::Op::IncMutation;

our ($VERSION) = ( '$Revision: 1.4 $ ' =~ /(\d+\.\d+)/ );


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

Applies mutation operator to a "Chromosome", a string, really. Can be
applied only to I<victims> with the C<_str> instance variable; but
it checks before application that both operands are of the required
type. The chosen character is changed to the next or previous in
the array of chars used for coding the the string
    my $strChrom = new Algorithm::Evolutionary::Individual::String ['a','c','g','t'] 10;
    my $xmen = new Algorithm::Evolutionary::Op::IncMutation;
    $xmen->apply( $strChrom ) # will change 'acgt' into 'aagt' or
			      # 'aggt', for instance

Issues an error if there is no C<_chars> array.

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
  #Compute order in the array
  croak "Can't do nuthin'; there's no alphabet in the victim" if @{$victim->{_chars}}< 0;
  while (  ($victim->{_chars}[$i] ne $char ) 
		   && ($i < @{$victim->{_chars}}) ) { $i++;};
  #Generate next or previous
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

  CVS Info: $Date: 2002/11/19 12:26:49 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/Evolutionary/Op/IncMutation.pm,v 1.4 2002/11/19 12:26:49 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.4 $
  $Name $


=cut

