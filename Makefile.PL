use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile( 'NAME'		=> 'Algorithm::Evolutionary',
	       'VERSION_FROM'	=> 'Evolutionary.pm', # finds $VERSION
	       'PREREQ_PM'		=> {Test::Simple => 0.44,
					    XML::Parser::EasyTree => 0.01,
					    Math::Random => 0.63,
					    Tree::DAG_Node => 1.04,
					    B::Deparse => 0.56}, # e.g., Module::Name => 1.1
	       'PMLIBDIRS'       => [ 'Evolutionary', 'Evolutionary/Op', 'Evolutionary/Individual' ],
	       ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
		(ABSTRACT_FROM => 'Evolutionary.pm', # retrieve abstract from module
		 AUTHOR     => 'J. J. Merelo <jmerelo@geneura.ugr.es>') : ())
);

#Add new targets
sub MY::postamble {
  return <<'MAKE_FRAG';
docs:
	pod2html --verbose --htmlroot .. --podpath=Evolutionary/Individual:Evolutionary/Op:Evolutionary --outfile index.html.html Evolutionary.pm; \
	cd Evolutionary; for i in *.pm; do base=`basename $$i .pm`; echo $$base; pod2html --verbose --htmlroot ../.. --podpath=Individual:Op --outfile $$base.html $$i; done ; \
		for i in *.pod; do base=`basename $$i .pod`; echo $$base; pod2html --verbose --htmlroot ../..   --podpath=Individual:Op --outfile $$base.html $$i; done; \
 		cd Op; for i in *.pm; do base=`basename $$i .pm`; echo $$base; pod2html --verbose --htmlroot ../../.. --podroot ..  --outfile $$base.html $$i; done ; \
		cd ../Individual; for i in *.pm; do base=`basename $$i .pm`; echo $$base; pod2html --verbose --htmlroot ../../.. --podroot .. --outfile $$base.html $$i; done
MAKE_FRAG
}

		
