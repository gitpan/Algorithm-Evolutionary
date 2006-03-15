#-*-Perl-*-

use strict;
use warnings;

use Test::More;

BEGIN { plan tests => 34 };
use lib qw( .. ../../.. ../..); #Just in case we are testing it in-place
use Algorithm::Evolutionary::Op::Base;

#Use: module name, args to ctor. 
my %modulesToTest = (
		     Mutation => [0.5],
		     Permutation => [0.5], 
		     Bitflip => [10],
		     Crossover => [2],
		     GaussianMutation => [1,1],
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
		     DeltaTerm => [1, 0.1],
		     Creator => [ 20, 'BitString', {length => 10 }] );

my %ops;
sub createAndTest ($$;$);
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
	isa_ok( $nct, $class );

	my $xml = $nct->asXML();
	my $newnct =  Algorithm::Evolutionary::Op::Base->fromXML( $xml );

	ok( $xml, $newnct->asXML() );

	return $nct;
  }
  
=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2006/03/15 09:29:41 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/t/ops.t,v 1.5 2006/03/15 09:29:41 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.5 $
  $Name $

=cut
