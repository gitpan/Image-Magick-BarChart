#!/usr/bin/perl -w
# Renders horizontal graph based on mortality rates for outbreaks
# of two strains of the Ebola filovirus, Zaire (most lethal) and Sudan.
# Data originates from www.uoguelph.ca/~dyoo/2004%20MICR4430/ 2004%20LouiseMarta.pdf
use strict;
use Image::Magick::BarChart;
use Image::Magick;

my $imgHandle = new Image::Magick(size => "450x250");
$imgHandle->Read("xc:white");
my $font = '@'.shift;
die "USAGE: ebolaOutbreaks.pl <font.ttf>" if($font eq '@');
my $ebolaGraph = new Image::Magick::BarChart(
	startX		=>	5,
	startY		=>	245,
	barSize		=>	15,
	interval	=>	20,
	border		=>	1,
	skip		=>	-110,
	textSpace	=>	0,
	maxPixels	=>	440,
	debug		=>	1,
	maximum		=>	100,
	sort		=>	sub { return @{+shift} },
	font		=>	$font,
	fontSize	=>	10);
$ebolaGraph->addBar(
		color	=>	'#ff0000',
		text	=>	'Ebola Zaire (1976)',
		number	=>	88);
$ebolaGraph->addBar(
		color	=>	'#ff0000',
		text	=>	'Ebola Zaire (1977)',
		number	=>	100);
$ebolaGraph->addBar(
		color	=>	'#ff0000',
		text	=>	'Ebola Zaire (1994)',
		number	=>	59);
$ebolaGraph->addBar(
		color	=>	'#ff0000',
		text	=>	'Ebola Zaire (1995)',
		number	=>	81);
$ebolaGraph->addBar(
		color	=>	'#ff0000',
		text	=>	'Ebola Zaire (1996)',
		number	=>	68);
$ebolaGraph->addBar(
		color	=>	'#ff0000',
		text	=>	'Ebola Zaire (1996)',
		number	=>	75);
$ebolaGraph->addBar(
		color	=>	'#ff0000',
		text	=>	'Ebola Zaire (1996)',
		number	=>	50);
$ebolaGraph->addBar(
		color	=>	'#ff0000',
		text	=>	'Ebola Zaire (2002)',
		number	=>	79);
$ebolaGraph->addBar(
		color	=>	'#ff0000',
		text	=>	'Ebola Zaire (2003)',
		number	=>	83);
$ebolaGraph->addBar(
		color	=>	'#f70000',
		text	=>	'Ebola Sudan (1976)',
		number	=>	53);
$ebolaGraph->addBar(
		color	=>	'#f70000',
		text	=>	'Ebola Sudan (1979)',
		number	=>	65);
$ebolaGraph->addBar(
		color	=>	'#f70000',
		text	=>	'Ebola Sudan (2001)',
		number	=>	53);
$ebolaGraph->draw($imgHandle);
$imgHandle->Write('ebola.png');
