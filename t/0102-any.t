#-*-cperl-*-

use Test::More;
use warnings;
use strict;

use lib qw( lib ../lib ../../lib  ); #Just in case we are testing it in-place

BEGIN { plan tests => 3;
    use_ok('Algorithm::Evolutionary::Individual::Any');
};

#Object methods
my @array = qw (1 2 3);
push @array, ['5','6'];
my $indi = new Algorithm::Evolutionary::Individual::Any 'Object::Array', \@array;
isa_ok( $indi, "Algorithm::Evolutionary::Individual::Any" );

my $fitness = 0.01;
$indi->Fitness( $fitness );
is( $indi->Fitness(), $fitness, 'Fitness' );


=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2009/02/04 20:43:15 $ 
  $Header: /cvsroot/opeal/Algorithm-Evolutionary/t/0102-any.t,v 2.1 2009/02/04 20:43:15 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 2.1 $
  $Name $

=cut