use strict;
use warnings;

=head1 NAME

    Algorithm::Evolutionary::Experiment - Class for setting up an experiment
                 
=head1 SYNOPSIS
  
  use Algorithm::Evolutionary::Experiment;
  my $popSize = 20;
  my $indiType = 'BitString';
  my $indiSize = 64;
  
  my $ex = new  Algorithm::Evolutionary::Experiment $popSize, $indiType, $indiSize, $algorithm; #Algorithm might be anything of type Op


=head1 DESCRIPTION

Experiment contains an algorithm and a population, and applies one to the other. Contains both as instance variables.

=head1 METHODS

=cut

package Algorithm::Evolutionary::Experiment;

use Algorithm::Evolutionary::Individual::Base;
use Algorithm::Evolutionary::Op::Base;

our $VERSION = ( '$Revision: 1.3 $ ' =~ /(\d+\.\d+)/ ) ;

use Carp;
use XML::Simple;

=head2 new

   Creates a new experiment. An C<Experiment> has two parts: the population and the algorithm.
   The population is created from a set of parameters: popSize, indiType and indiSize, and a 
   array of algorithms that will be applied sequentially. Alternatively, if only operators
   is passed as an argument, it is understood as a array of algorithms (including, probably,
   initialization of the population).

=cut

sub new ($$$$;$) {
  my $class = shift;
  my $self = ();
  $self->{_pop} = ();
  if ( (ref $_[0]) !~ /Algorithm::Evolutionary/ ) { 
    my $popSize = shift || carp "Pop size = 0, can't create\n";
    my $indiType = shift || carp "Empty individual class, can't create\n";
    my $indiSize = shift || carp "Empty individual size, no reasonable default, can't create\n";
    for ( my $i = 0; $i < $popSize; $i ++ ) {
      my $indi = Algorithm::Evolutionary::Individual::Base::new( $indiType, { length => $indiSize } );
      $indi->randomize();
      push @{$self->{_pop}}, $indi;
    }
  };
  @_ || die "Can't find an algorithm";
  push @{$self->{_algo}}, @_;
  bless $self, $class;
  return $self
  
}

=head2 fromXML

Creates a new experiment, same as before, but with an XML specification. An 
example of it follows:

 <ea xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:noNamespaceSchemaLocation='ea-alpha.xsd'
    version='0.2'>

  <initial>
    <pop size='20'>
       <section name='indi'> 
          <param name='type' value='BitString' /> 
          <param name='length' value='64' />
       </section>
    </pop>

    <op name='Easy'  type='unary'>
        <param name='selrate' value='0.4' />
        <param name='maxgen' value='100' />
        <code type='eval' language='perl'>
    	  <src><![CDATA[ #source goes here ]]>
          </src>
        </code>
        <op name='GaussianMutation' type='unary' rate='1'>
        	<param name='avg' value='0' />
			<param name='stddev' value='0.1' />
      	</op>
      	<op name='VectorCrossover' type='binary' rate='1'>
        	<param name='numpoints' value='1' />
      	</op>
    </op>
    
    
  </initial>

 </ea>
 
 This is an alternative constructor. Takes a well-formed string with the XML
 spec, which should have been done according to EvoSpec 0.3, or the same
 string processed with C<XML::Simple>, and returns a built experiment

=cut

sub fromXML ($;$) {
  my $class = shift;
  my $xml = shift || carp "XML fragment missing ";
  if ( (ref $xml) ne "HASH" ) { #We are receiving a string
    $xml = XMLin($xml);
  }
  my $self = {}; # Create a reference

  #Process population, via the creator operator
  if ( $xml->{initial}{op}{name} ) {
    push( @{$self->{_algo}}, Algorithm::Evolutionary::Op::Base->fromXML( $xml->{initial}{op} ) );
  } else {
    for ( keys  %{$xml->{initial}{op}} ) {
      push( @{$self->{_algo}}, Algorithm::Evolutionary::Op::Base->fromXML( $xml->{initial}{op}{$_}, $_ ) );
    }
  }

  #Process population, if it exists
  $self->{_pop} = [];
  for (  @{$xml->{pop}{indi}} ) {
	push( @{$self->{_pop}}, Algorithm::Evolutionary::Individual::Base->fromXML( $_ ) );
  }
  #Bless and return
  bless $self, $class;

  return $self;
}


=head2 go

Applies the different operators in the order that they appear; returns the population
as a ref-to-array.

=cut

sub go {
  my $self = shift;
  for ( @{$self->{_algo}} ) {
	$_->apply( $self->{_pop} );
  }
  return $self->{_pop}
}

=head2 asXML
 
Opposite of fromXML; serializes the object in XML. First the operators, and then
the population

=cut

sub asXML {
  my $self = shift;
  my $str=<<'EOC';
<ea xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:noNamespaceSchemaLocation='ea-alpha.xsd'
    version='0.3'>
<!-- Serialization of an Experiment object. Generated automatically by
     Experiment $Revision: 1.3 $ -->
    <initial>
EOC

  for ( @{$self->{_algo}} ) {
	$str.= $_->asXML()."\n";
  }
  
  $str .="\t</initial>\n<!-- Population --><pop>\n";
   for ( @{$self->{_pop}} ) {
	$str .= $_->asXML()."\n";
  }
  $str .="\n\t</pop>\n</ea>\n";
  return $str;
}

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2002/09/01 15:27:51 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/Evolutionary/Experiment.pm,v 1.3 2002/09/01 15:27:51 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.3 $
  $Name $

=cut

"What???";
