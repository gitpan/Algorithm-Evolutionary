use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
			  'NAME'		=> 'Algorithm::Evolutionary',
			  'VERSION_FROM'	=> 'Evolutionary.pm', # finds $VERSION
			  'PREREQ_PM'		=> {XML::Simple => 1.05,
									Math::Random => 0.61,
									Tree::DAG_Node => 1.04,
									B::Deparse => 0.56}, # e.g., Module::Name => 1.1
			  'PMLIBDIRS'       => [ 'Op', 'Individual' ],
			  'INSTALLHTMLSCRIPTDIR' => 'html',
              'HTMLLIBPODS' => { XML => 'XML.pod' },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Evolutionary.pm', # retrieve abstract from module
       AUTHOR     => 'J. J. Merelo <jmerelo@geneura.ugr.es>') : ()),
);
