use strict;
use warnings;

=head1 NAME

    Algorithm::Evolutionary::Op::Base - Base class for OPEAL operators; operators are any object with the "apply"
             method, which does things to individuals or populations.

=head1 SYNOPSIS

    my $op = new Algorithm::Evolutionary::Op::Base; #Creates empty op, with rate

    my $xmlStr=<<EOC;
    <op name='Mutation' type='unary' rate='2'>
      <param name='probability' value='0.5' />
    </op>
    EOC

    my $ref = XMLin($xmlStr);
    my $op = Algorithm::Evolutionary::Op::Base->fromXML( $ref ); #Takes a hash of parsed XML and turns it into an operator    

    print $op->asXML(); #print its back in XML shape

    print $op->rate();  #application rate; relative number of times it must be applied
    print "Yes" if $op->check( 'BinaryIndi' ); #Prints Yes, it can be applied to BinaryIndi
    print $op->arity(); #Prints 1, number of operands it can be applied to

=head1 DESCRIPTION

Base class for operators applied to Individuals and Populations and all the rest

=head1 METHODS

=cut

package Algorithm::Evolutionary::Op::Base;

use lib qw( ../.. ../../.. );

use XML::Simple;
use B::Deparse; #For serializing code

use Carp;
our $VERSION = ( '$Revision: 1.9 $ ' =~ /(\d+\.\d+)/ ) ;


=head2 AUTOLOAD

Automatically define accesors for instance variables

=cut

sub AUTOLOAD {
  my $self = shift;
  our $AUTOLOAD;
  my ($method) = ($AUTOLOAD =~ /::(\w+)/);
  my $instanceVar = "_".lcfirst($method);
  if (defined ($self->{$instanceVar})) {
    if ( @_ ) {
	  $self->{$instanceVar} = shift;
    } else {
	  return $self->{$instanceVar};
    }
  }    

}

=head2 new

Takes a hash with specific parameters for each subclass, creates the 
object, and leaves subclass-specific assignments to subclasses

=cut

sub new {
  my $class = shift;
  my $rate = shift || 1;
  my $hash = shift; #No carp here, some operators do not need specific stuff
  my $self = { rate => $rate }; # Create a reference
  carp "Should be called from subclasses" if ( $class eq  __PACKAGE__ );
  bless $self, $class; # And bless it
  $self->set( $hash ) if $hash ;
  return $self;
}

=head2 fromXML

Takes a definition in the shape <op></op> and turns it into an object, 
if it knows how to do it. The definition must have been processed using XML::Simple.

It parses the common part of the operator, and leaves specific parameters for the
subclass via the "set" method.

=cut

sub fromXML {
  my $class = shift;
  my $xml = shift || carp "XML fragment missing ";
  if ( (ref $xml) ne "HASH" ) { #We are receiving a string
    $xml = XMLin($xml);
  }
  my $self = {}; # Create a reference
  $self->{rate} = $xml->{rate};
  if ( $class eq  __PACKAGE__ ) { #Deduct class from the XML
    $class = $xml->{name} || shift || croak "Class name missing";
  }
  if ( defined  $xml->{name} and ($xml->{name} ne $class) ) {
	croak "XML type does not correspond to class type" ;
  }
  $class = "Algorithm::Evolutionary::Op::$class" if $class !~ /Algorithm::Evolutionary/;
  bless $self, $class; # And bless it

  my %params;
  if ( defined $xml->{param}{value} ) { # There's a single param
	$params{$xml->{param}{name}} = $xml->{param}{value};
  } else {
	for ( keys %{$xml->{param}} ) {
	  $params{$_} = $xml->{param}{$_}{value};
	}
  }

  #Now process code fragments
  my %codeFrags;
  if ( defined $xml->{code}{type} ) { # There's a single param
	$codeFrags{$xml->{code}{type}} = $xml->{code}{src};
  } else {
	for ( keys %{$xml->{code}} ) {
	  $codeFrags{$_} = $xml->{code}{$_}{value};
	}
  }

  #Now Recursively process operators
  my %ops;
  if ( defined $xml->{op}{value} ) { # There's a single param
	$ops{$xml->{op}{name}} = $xml->{op}{value};
  } else {
	for ( keys %{$xml->{op}} ) {
	  $ops{$_} = $xml->{op}{$_};
	}
  }
  #If the class is not loaded, we load it. The 
  if ( !$INC{"$class\.pm"} ) {
    eval "require $class" || croak "Can't find $class Module";
  }
  #Let the class configure itself
  $self->set( \%params, \%codeFrags, \%ops );
  return $self;
}


=head2 asXML

Prints as XML, following the EvoSpec 0.2 XML specification. Should be
called from derived classes, not by itself. Provides a default
implementation of XML serialization, with a void tag that includes the
name of the operator and the rate (all operators have a default
rate). For instance, a C<foo> operator would be serialized as C< E<lt>op
name='foo' rate='1' E<gt> >.

If there is not anything special, this takes also care of the instance
variables different from L<rate>: they are inserted as L<param> within
the XML file. In this case, L<param>s are void tags; if you want
anything more fancy, you will have to override this method.

=cut

sub asXML {
  my $self = shift;
  my ($opName) = ( ( ref $self) =~ /::(\w+)$/ );
  my $name = shift; #instance variable it corresponds to
  my $str =  "<op name='$opName' ";
  $str .= "id ='$name' " if $name;
  if ( $self->{rate} ) { # "Rated" ops, such as genetic ops
	$str .= " rate='".$self->{rate}."'";
  }
  if (keys %$self == 1 ) {
    $str .= " />" ; #Close void tag, only the "rate" param
  } else {
    $str .= " >";
    for ( keys %$self ) {
      if (!/\brate\b/ ) {
		my ($paramName) = /_(\w+)/;
		if ( ! ref $self->{$_}  ) {
		  $str .= "\n\t<param name='$paramName' value='$self->{$_}' />";
		} elsif ( ref $self->{$_} eq 'ARRAY' ) {
		  for my $i ( @{$self->{$_}} ) {
			$str .= $i->asXML()."\n";
		  }
		} elsif ( ref $self->{$_} eq 'CODE' ) {
		  my $deparse = B::Deparse->new;
		  $str .="<code type='eval' language='perl'>\n<src><![CDATA[".$deparse->coderef2text($self->{$_})."]]>\n </src>\n</code>";
		} elsif ( (ref $self->{$_} ) =~ 'Algorithm::Evolutionary' ) { #Composite object, I guess...
		$str .= $self->{$_}->asXML( $_ );
		}
      }
    }
    $str .= "\n</op>";
  }
  return $str;
}

=head2 rate

Gets or sets the rate of application of the operator

=cut

sub rate {
  my $self = shift ;
  $self->{rate} = shift if @_;
  return $self;
}

=head2 check

Check if the object the operator is applied to has the correct type

=cut

sub check {
  my $self = (ref  $_[0] ) ||  $_[0] ;
  my $object =  $_[1];
  my $at = eval ("\$"."$self"."::APPLIESTO");
  return $object->isa( $at ) ;
}

=head2 arity

Returns the arity, ie, the number of individuals it can be applied to

=cut

sub arity {
  my $class = ref shift;
  return eval( "\$"."$class"."::ARITY" );
}

=head2 set

Converts the parameters passed as hash in instance variables. Default
method, probably should be overriden by derived classes. If it is not,
it sets the instance variables by prepending a L<_> to the keys of the
hash. That is, 
  $op->set( { foo => 3, bar => } );
will set L<$op->{_foo}> and  L<$op->{_bar}> to the corresponding values

=cut

sub set {
  my $self = shift;
  my $hashref = shift || croak "No params here";
  for ( keys %$hashref ) {
    $self->{"_$_"} = $hashref->{$_};
  }
}

=head1 Known subclasses

=over 4

=item * 

L<Algorithm::Evolutionary::Op::Mutation|Algorithm::Evolutionary::Op::Mutation>

=item * 

L<Algorithm::Evolutionary::Op::BitFlip|Algorithm::Evolutionary::Op::BitFlip>

=item * 

L<Algorithm::Evolutionary::Op:GaussianMutation|Algorithm::Evolutionary::Op:GaussianMutation>

=item * 

L<Algorithm::Evolutionary::Op:Crossover|Algorithm::Evolutionary::Op:Crossover>

=item * 

L<Algorithm::Evolutionary::Op:VectorCrossover|Algorithm::Evolutionary::Op:VectorCrossover>

=item * 

L<Algorithm::Evolutionary::Op:CX|Algorithm::Evolutionary::Op:CX>

=item * 

L<Algorithm::Evolutionary::Op::ChangeLengthMutation|Algorithm::Evolutionary::Op::ChangeLengthMutation>


=item * 

L<Algorithm::Evolutionary::Op::ArithCrossover|Algorithm::Evolutionary::Op::ArithCrossover> 

=item * 

L<Algorithm::Evolutionary::Op::NoChangeTerm|Algorithm::Evolutionary::Op::NoChangeTerm>

=item * 

L<Algorithm::Evolutionary::Op::DeltaTerm|Algorithm::Evolutionary::Op::DeltaTerm>

=item * 

L<Algorithm::Evolutionary::Op::Easy|Algorithm::Evolutionary::Op::Easy>

=item * 
L<Algorithm::Evolutionary::Op::FullAlgorithm|Algorithm::Evolutionary::Op::FullAlgorithm>



=back

=head1 See Also

The introduction to the XML format used here,
L<Algorithm::Evolutionary::XML.pod|Algorithm::Evolutionary::XML.pod>

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2002/06/20 16:57:25 $ 
  $Header: /cvsroot/opeal/opeal/Algorithm/Evolutionary/Op/Base.pm,v 1.9 2002/06/20 16:57:25 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.9 $
  $Name $

=cut

"What???";
