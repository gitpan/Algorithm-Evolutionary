#-*-Perl-*-

use Test;
BEGIN { plan tests => 3 };
use lib qw( ../../.. ../.. ..); #Just in case we are testing it in-place

use Algorithm::Evolutionary::Op::NoChangeTerm;
use Algorithm::Evolutionary::Individual::String;

#########################

my $times = 10;
my $nct = new Algorithm::Evolutionary::Op::NoChangeTerm $times; 
ok( ref $nct, "Algorithm::Evolutionary::Op::NoChangeTerm" );

my $indi= new Algorithm::Evolutionary::Individual::String [0,1], 2;
$indi->Fitness(10);
for ( my $i = 0; $i < $times; $i++ ) {
  $nct->apply([$indi]);
}
ok( $nct->apply([$indi]), '' ); #Should return 0

my $xml = $nct->asXML();
my $newnct =  Algorithm::Evolutionary::Op::Base->fromXML( $xml );

ok( $xml, $newnct->asXML() );
  
=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2002/07/25 08:41:34 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/t/NoChangeTerm.t,v 1.1 2002/07/25 08:41:34 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.1 $
  $Name $

=cut
