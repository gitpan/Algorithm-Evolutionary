#!/usr/bin/perl

use strict;
use warnings;

use lib qw( ../lib lib );
use Algorithm::Evolutionary::Experiment;
use Algorithm::Evolutionary::Op::Easy;
use File::Slurp;

my $xml_file = shift || die "No XML file\n";
my $xml = read_file( $xml_file ) || die "Can't open $xml_file\n";
my $max_fitness = shift || 100;
my $max_generation = shift || 100;

#Create experiment
my $xp = Algorithm::Evolutionary::Experiment->fromXML( $xml );
my $popRef;
my $gen=0;
do {
    $popRef = $xp->go();	
    print $gen++, " Best= ", $popRef->[0]->Fitness(), "\n";
} until $popRef->[0]->Fitness() >= $max_fitness || $gen >= $max_generation;



########################################################################

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2008/02/13 13:08:22 $ 
  $Header: /cvsroot/opeal/Algorithm-Evolutionary/examples/runfromXML.pl,v 1.2 2008/02/13 13:08:22 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.2 $
  $Name $

=cut
