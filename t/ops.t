#-*-Perl-*-

use Test;
BEGIN { plan tests => 30 };
use lib qw( ../../.. ../.. ..); #Just in case we are testing it in-place

#Use: module name, args to ctor. 
my %modulesToTest = (
					 Mutation => [0.5],
					 Bitflip => [10],
					 Crossover => [2],
					 GaussianMutation => [],
					 TreeMutation => [0.5],
					 VectorCrossover => [0.5],
					 CX =>[],
					 ChangeLengthMutation =>[],
					 Inverover=>[],
					 LinearFreezer=>[],
					 RouletteWheel=>[100],
					 TournamentSelect=>[100,7],
					 NoChangeTerm => [10],
					 GenerationalTerm => [10],
					 DeltaTerm => [1, 0.1] );

my %ops;
for ( keys %modulesToTest ) {
  my $op = createAndTest( $_, $modulesToTest{$_});
  $ops{ ref $op } = $op;
}

#Subroute that tests and creates an op. Takes as argument
#the name of the op and a ref-to-array with the arguments to new
sub createAndTest ($$;$) {
	my $module = shift || die "No module name";
	my $newArgs = shift || die "No args";

	my $class = "Algorithm::Evolutionary::Op::$module";
	#require module
	eval " require  $class" || die "Can't load module $class: $@";
	my $nct = new $class @$newArgs; 
	print "Testing $module\n";
	ok( ref $nct, $class );

	my $xml = $nct->asXML();
	my $newnct =  Algorithm::Evolutionary::Op::Base->fromXML( $xml );

	ok( $xml, $newnct->asXML() );

	return $nct;
  }
  
=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2002/06/20 15:41:35 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/Evolutionary/t/ops.t,v 1.2 2002/06/20 15:41:35 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.2 $
  $Name $

=cut
