
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
