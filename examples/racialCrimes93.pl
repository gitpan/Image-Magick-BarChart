#!/usr/bin/perl -w
# Example usage of BarChart module.
# Renders a simple vertical, colored graph based on statistics
# for racials crime in the UK during 1993. This data can be found
# at 
use strict;
use Image::Magick::BarChart;
use Image::Magick;
my $imgHandle	= new Image::Magick(size => "100x200");
$imgHandle->Read('xc:white');
my $font = '@'.shift;
die "USAGE: racialCrimes93.pl <font.ttf>" if($font eq '@');
my $crimeGraph	= new Image::Magick::BarChart(
	debug		=>	1,
	barSize		=>	15,
	interval	=>	25,
	font		=>	$font,
	fontSize	=>	7,
	maximum		=>	10,
	vertical	=>	1);
$crimeGraph->addBar(
		number	=>	0.3,
		color	=>	'#9999ff',
		text	=>	'White');
$crimeGraph->addBar(
		number	=>	3.6,
		color	=>	'#000080',
		text	=>	'Indian');
$crimeGraph->addBar(
		number	=>	4.2,
		color	=>	'#0000ff',
		text	=>	'Pakistani');
$crimeGraph->addBar(
		number	=>	2.2,
		color	=>	'#ccffff',
		text	=>	'Black');
$crimeGraph->draw($imgHandle);
$imgHandle->Write('crimes.png');
