# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 4 };
use lib qw( lib ../lib ../../lib  ); #Just in case we are testing it in-place

use Algorithm::Evolutionary::Op::GenerationalTerm;
use Algorithm::Evolutionary::Individual::String;

#########################

my $gens = 1;
my $nct = new Algorithm::Evolutionary::Op::GenerationalTerm $gens; 
ok( ref $nct, "Algorithm::Evolutionary::Op::GenerationalTerm" );

my $indi= new Algorithm::Evolutionary::Individual::String [0,1], 2;
ok( $nct->apply([$indi]), 1 ); #Runs once, possible
ok( $nct->apply([$indi]), '' ); #Runs twice, returns fail

my $xml = $nct->asXML();
my $newnct =  Algorithm::Evolutionary::Op::Base->fromXML( $xml );

ok( $xml, $newnct->asXML() );
  
=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2009/02/04 20:43:15 $ 
  $Header: /cvsroot/opeal/Algorithm-Evolutionary/t/GenerationalTerm.t,v 2.1 2009/02/04 20:43:15 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 2.1 $
  $Name $

=cut
