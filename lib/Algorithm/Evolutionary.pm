package Algorithm::Evolutionary;

#use version; our $VERSION = qv('0.62');
our $VERSION = '0.62_1';

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
persistence provided by XML modules, and, in some cases, YAML.

The algorithm allows to create simple evolutionary algorithms, as well
as more complex ones, that interface with databases or with the
web. 

=begin html

<p>The project is hosted at
<a href='http://opeal.sourceforge.net'>Sourceforge </a>. Latest aditions, and
nightly updates, can be downloaded from there before they are uploaded
to CPAN. That page also hosts the mailing list, as well as bug
reports, news, updates, whatever.</p>

<p>In case the examples are hidden somewhere in the C<.cpan> directory,
    you can also download them from <a
    href='http://opeal.cvs.sourceforge.net/opeal/Algorithm-Evolutionary/'>the
    CVS repository</a>, and the <a
    href='https://sourceforge.net/project/showfiles.php?group_id=34080&package_id=54504'>-examples</a>
    tarballs in the file download area of that repository</

=end html

=head1 AUTHOR

=begin html

Main author and developer is J. J. Merelo, jmerelo (at)
geneura.ugr.es. There have also been some contributions from Javi
Garc�a, fjgc (at) decsai.ugr.es and Pedro Castillo, pedro (at)
geneura.ugr.es. Patient users that have submitted bugs include <a
href='http://barbacana.net'>jamarier</a>. Bugs, requests and any kind
of comment are welcome.

=end html

=head1 Examples

There are a few examples in the C<examples> subdirectory, which should have been included with your CPAN bundle. Foor instance, check out C<tide_float.pl>, an example of floating point vector optimization, or C<run_easy_ga.pl p_peaks.yaml>, which should run an example of a simple GA on the P_Peaks deceptive function.

=head1 SEE ALSO

L<Algorithm::Evolutionary::Op::Base>.
L<Algorithm::Evolutionary::Individual::Base>.
L<Algorithm::Evolutionary::Fitness::Base>.
L<Algorithm::Evolutionary::Experiment>.
L<Algorithm::Evolutionary::XML>


=cut
