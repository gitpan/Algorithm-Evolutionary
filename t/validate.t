#!/usr/bin/perl

use XML::LibXML;
my $parser = XML::LibXML->new();
XML::LibXML->new();

use Test;
BEGIN { plan tests => 5 };
use lib qw( ../.. ../../.. .. ); #Just in case we are testing it in-place

my @filesGood = qw( marea.xml royalroad.xml onemax.xml experiment.xml );
my @filesBad = qw( marea-fails.xml );

for ( @filesGood ) {
  ok ( validate ( "xml/$_", $parser ) =~ /Validated/, 1 );
}

for ( @filesBad ) {
  ok ( validate ( "xml/$_", $parser ) =~ /error/, 1 );
}

########################################################################

sub validate {
  my $fn = shift;
  my $parser = shift;
  my $doc = $parser->parse_file( $fn );
  eval {
    $doc->validate();
  };
  if ( $@ ) {
    return "Validation error: $@ \n";
  } else {
    return "Validated: ". $doc->toString(). "\n";
  }
}

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2005/11/14 12:34:08 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/t/validate.t,v 1.4 2005/11/14 12:34:08 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.4 $
  $Name $

=cut