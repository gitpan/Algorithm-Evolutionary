#-*-Perl-*-

use Test;
BEGIN { plan tests => 4 };
use lib qw( ../../.. ../..); #Just in case we are testing it in-place

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
ok ( ref $e, 'Algorithm::Evolutionary::Experiment' );

my $xml=<<EOC;
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
    	  <src><![CDATA[ my $chrom = shift;
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
          ]]></src>
        </code>
        <op name='Mutation' type='unary' rate='1'>
            <param name='probability' value='0.5' />
      	</op>
      	<op name='Crossover' type='binary' rate='5'>
        	<param name='numpoints' value='2' />
      	</op>
    </op>
    
    
  </initial>

</ea>
EOC
  my $e2 = Algorithm::Evolutionary::Experiment->fromXML( $xml );
  ok( ref $e2, 'Algorithm::Evolutionary::Experiment' );
  ok( ref $e2->{_algo}, 'Algorithm::Evolutionary::Op::Easy' );
  ok( scalar @{$e2->{_pop}}, 20 );

  
=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2002/06/21 09:22:00 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/Evolutionary/t/experiment.t,v 1.1 2002/06/21 09:22:00 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.1 $
  $Name $

=cut
