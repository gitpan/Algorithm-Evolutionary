#-*-Perl-*-

use Test::More;
BEGIN { plan tests => 10 };
use lib qw( .. ../../.. ../..); #Just in case we are testing it in-place

use Algorithm::Evolutionary::Experiment;
use Algorithm::Evolutionary::Op::Easy;

#########################
my $onemax = sub { 
  my $indi = shift;
  my $total = 0;
  my $len = $indi->length();
  my $i;
  while ($i < $len ) {
	$total += substr($indi->{'_str'}, $i, 1);
	$i++;
  }
  return $total;
};

my $ez = new Algorithm::Evolutionary::Op::Easy $onemax;
my $popSize = 20;
my $indiType = 'BitString';
my $indiSize = 64;

my $e = new Algorithm::Evolutionary::Experiment $popSize, $indiType, $indiSize, $ez;
isa_ok ( $e, 'Algorithm::Evolutionary::Experiment' ); # test 1

my $xml=<<'EOC';
<ea xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:noNamespaceSchemaLocation='ea-alpha.xsd'
    version='0.3'>

  <initial>
    <op name='Creator'>
       <param name='number' value='20' />
       <param name='class' value='BitString' /> 
       <param name='options'>
          <param name='length' value='64' />
       </param>
    </op>

    <op name='Easy'  type='unary'>
        <param name='selrate' value='0.4' />
        <param name='maxgen' value='1' />
        <code type='eval' language='perl'>
    	  <src><![CDATA[ my $chrom = shift;
                my $str = $chrom->Chrom();
                my $fitness = 0;
                my $blockSize = 4;
                for ( my $i = 0; $i < length( $str ) / $blockSize; $i++ ) {
	              my $block = 1;
	              for ( my $j = 0; $j < $blockSize; $j++ ) {
	                $block &= substr( $str, $i*$blockSize+$j, 1 );
	              }
	              ( $fitness += $blockSize ) if $block;
                }
                return $fitness;
          ]]></src>
        </code>
        <op name='Bitflip' type='unary' rate='1'>
            <param name='probability' value='0.5' />
            <param name='howMany' value='1' />
      	</op>
      	<op name='Crossover' type='binary' rate='5'>
        	<param name='numPoints' value='2' />
      	</op>
    </op>
    
    
  </initial>

</ea>
EOC
  my $e2 = Algorithm::Evolutionary::Experiment->fromXML( $xml );
  isa_ok( $e2, 'Algorithm::Evolutionary::Experiment' ); # Test 2
  isa_ok( $e2->{_algo}[1], 'Algorithm::Evolutionary::Op::Easy' ); # Test 3 
  my $popRef = $e2->go();
  ok( scalar @{$popRef} == 20 ); # Test 4

  my $xpxml = $e2->asXML();
  my $bke2 = Algorithm::Evolutionary::Experiment->fromXML( $xpxml );
  ok ( scalar @{$bke2->{_pop}} == 20 ); # Test 5

  open( I, "<xml/marea.xml" ) || die "Can't open xml/marea.xml";
  my $xml2 = join( "", <I> );
  close I;
  my $mxp =  Algorithm::Evolutionary::Experiment->fromXML( $xml2 );
  isa_ok( $mxp, 'Algorithm::Evolutionary::Experiment' ); # Test 6
  isa_ok( $mxp->{_algo}[1], 'Algorithm::Evolutionary::Op::Easy' ); # Test 7
  $popRef = $mxp->go();
  ok( scalar  @{$popRef} == 20 );# Test 8
  
  open( I, "<xml/onemax.xml" ) || die "Can't open xml/onemax.xml";
  my $xml3 = join( "", <I> );
  close I;
  my $oxp =  Algorithm::Evolutionary::Experiment->fromXML( $xml3 );
  isa_ok( $oxp, 'Algorithm::Evolutionary::Experiment' ); # Test 9
  isa_ok( $oxp->{_algo}[1], 'Algorithm::Evolutionary::Op::Easy' ); # Test 10

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2002/09/24 18:40:17 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/t/experiment.t,v 1.5 2002/09/24 18:40:17 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.5 $
  $Name $

=cut
