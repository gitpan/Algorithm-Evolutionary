package Algorithm::Evolutionary;

our $VERSION = '0.52';

# Preloaded methods go here.

1;
__END__

=head1 NAME

Algorithm::Evolutionary - Perl extension for performing paradigm-free evolutionary algorithms. 

=head1 SYNOPSIS

  use Algorithm::Evolutionary;
  

=head1 DESCRIPTION

Algorithm::Evolutionary is a set of classes for doing object-oriented
evolutionary computation in Perl. Why would anyone want to do that
escapes my knowledge, but, in fact, we have found it quite useful for
our own purposes. Same as Perl itself.

The design principle of Algorithm::Evolutionary is I<flexibility>: it
should be very easy to extend using this library, and it should be
also quite easy to program what's already there in the evolutionary
computation community. Besides, the library classes should have
persistence provided by XML modules.

The algorithm allows to create simple evolutionary algorithms, as well
as more complex ones, that interface with databases or with the
web. 

The project is hosted at
E<lt>a href='http://opeal.sourceforge.net'E<gt>Sourceforge  E<lt>/aE<gt>. Latest aditions, and
nightly updates, can be downloaded from there before they are uploaded
to CPAN. That page also hosts the mailing list, as well as bug
reports, news, updates, whatever.


=head1 AUTHOR

Main author and developer is J. J. Merelo,
E<lt>jmerelo@geneura.ugr.es<gt>. There have also been some
contributions from Javi García, E<lt>javi@geneura.ugr.es<gt> and Pedro
Castillo, E<lt>javi@geneura.ugr.es<gt>

=head1 SEE ALSO

L<Algorithm::Evolutionary::Op::Base>.
L<Algorithm::Evolutionary::Individual::Base>.

=cut
