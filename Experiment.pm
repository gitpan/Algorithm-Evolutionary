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

our $VERSION = ( '$Revision: 1.1 $ ' =~ /(\d+\.\d+)/ ) ;

use Carp;
use XML::Simple;

=head2 new

   Creates a new experiment. An C<Experiment> has two parts: the population and the algorithm.
   The population is created from a set of parameters

=cut

sub new ($$$$;$) {
  my $class = shift;
  my $self = ();
  $self->{_pop} = ();
  my $popSize = shift || carp "Pop size = 0, can't create\n";
  my $indiType = shift || carp "Empty individual class, can't create\n";
  my $indiSize = shift || carp "Empty individual size, no reasonable default, can't create\n";
  for ( my $i = 0; $i < $popSize; $i ++ ) {
	my $indi = Algorithm::Evolutionary::Individual::Base::new( $indiType, { length => $indiSize } );
	$indi->randomize();
	push @{$self->{_pop}}, $indi;
  }

  $self->{_algo} = shift || die "Can't find an algorithm";
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
    	  <src> my $chrom = shift;
                my $str = $chrom->Chrom();
                my $fitness = 0;
                for ( my $i = 0; $i < length( $str ) / $blockSize; $i++ ) {
	              my $block = 1;
	              for ( my $j = 0; $j < $blockSize; $j++ ) {
	                $block &= substr( $str, $i*$blockSize+$j, 1 );
	              }
	              ( $fitness += $blockSize ) if $block;
                }
                return $fitness;
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

  #Process population
  $self->{_pop} = ();
  my $popSize = $xml->{initial}{pop}{size} || carp "Pop size = 0, can't create\n";
  for ( my $i = 0; $i < $popSize; $i ++ ) {
	my $indi = Algorithm::Evolutionary::Individual::Base->fromParam( $xml->{initial}{pop}{section} );
	push @{$self->{_pop}}, $indi;
  }

  
  #Process op
  $self->{_algo} = Algorithm::Evolutionary::Op::Base->fromXML( $xml->{initial}{op} );
  
  #Bless and return
  bless $self, $class;

  return $self;
}
