# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 4 };
use lib qw( ../../.. ../.. .. ); #Just in case we are testing it in-place

use Algorithm::Evolutionary::Op::DeltaTerm;
use Algorithm::Evolutionary::Individual::String;

#########################

my $target = 1;
my $delta = 0.1;
my $nct = new Algorithm::Evolutionary::Op::DeltaTerm $target, $delta; 
ok( ref $nct, "Algorithm::Evolutionary::Op::DeltaTerm" );

my $indi= new Algorithm::Evolutionary::Individual::String [0,1], 2;
$indi->Fitness(1);
ok( $nct->apply([$indi]), '' ); #Should return 0
$indi->Fitness(0);
ok( $nct->apply([$indi]), 1 ); #Should return 0

my $xml = $nct->asXML();
my $newnct =  Algorithm::Evolutionary::Op::Base->fromXML( $xml );

ok( $xml, $newnct->asXML() );
  
=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2002/07/25 08:41:34 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/t/DeltaTerm.t,v 1.1 2002/07/25 08:41:34 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.1 $
  $Name $

=cut
