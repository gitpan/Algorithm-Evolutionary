#-*-cperl-*-

use Test::More;
use warnings;
use strict;

use lib qw( lib ../lib ../../lib  ); #Just in case we are testing it in-place

BEGIN { plan tests => 24;
	use_ok('Algorithm::Evolutionary::Wheel');
	use_ok('Algorithm::Evolutionary::Hash_Wheel');
};

my @probabilities = qw( 1 2 3 4 5 );

my $wheel = new Algorithm::Evolutionary::Wheel @probabilities;

isa_ok( $wheel, 'Algorithm::Evolutionary::Wheel' );

for (1..10) {
  my $result = $wheel->spin;
  cmp_ok( $result, '<', @probabilities, "Spinning = $result" );
}

my $probabilities = { a => 1,
		      b => 2,
		      c => 3,
		      d => 4,
		      e => 5 };

my $h_wheel = new Algorithm::Evolutionary::Hash_Wheel $probabilities;

isa_ok( $h_wheel, 'Algorithm::Evolutionary::Hash_Wheel' );

for (1..10) {
  my $result = $h_wheel->spin;
  cmp_ok( $probabilities->{$result}, '>', 0, "Spinning = $result" );
}

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2009/09/09 09:02:40 $ 
  $Header: /cvsroot/opeal/Algorithm-Evolutionary/t/0001-wheel.t,v 1.1 2009/09/09 09:02:40 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.1 $
  $Name $

=cut
