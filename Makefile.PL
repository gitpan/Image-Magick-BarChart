use 5.008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Image::Magick::BarChart',
    'VERSION_FROM'	=> 'BarChart.pm', # finds $VERSION
    'PREREQ_PM'		=> {
	Image::Magick	=>	'6.0.1',
	}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'BarChart.pm', # retrieve abstract from module
       AUTHOR     => 'Alexander Christian Westholm <awestholm@verizon.net>') : ()),
);
