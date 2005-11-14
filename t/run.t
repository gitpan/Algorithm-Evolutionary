#!/usr/bin/perl


#########################
use lib qw( . ../.. ../../.. .. ); #Just in case we are testing it in-place
use Algorithm::Evolutionary::Experiment;
use Algorithm::Evolutionary::Op::Easy;
use XML::LibXML;
my $parser = XML::LibXML->new();
XML::LibXML->new();

use Test;
BEGIN { plan tests => 4 };
#########################


my @files = qw( marea.xml royalroad.xml onemax.xml experiment.xml );

for ( @files ) {	
  open (X, "<xml/$_" );
  my $xml = join("", <X>);
  close X;
  $xp = Algorithm::Evolutionary::Experiment->fromXML( $xml );
  my $popRef = $xp->go();	
  ok ( $popRef->[0]->Fitness() > 0, 1 );
}


########################################################################

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2005/11/14 12:34:08 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/t/run.t,v 1.3 2005/11/14 12:34:08 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.3 $
  $Name $

=cut
