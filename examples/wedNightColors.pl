#!/usr/bin/perl -w
# Representation of data compiled by my girlfriend during the finish of
# a yacht race on June 9th, 2004 in the Annapolis Harbor. Data was gathered
# for 43 boats as they crossed the finish line.
use strict;
use Image::Magick;
use Image::Magick::BarChart;

my $imgHandle = new Image::Magick(size=>"305x250");
$imgHandle->Read("xc:white");
my $font = '@'.shift;
die "USAGE: wedNightColors.pl <font.ttf>" if($font eq '@');
my $sailGraph = new BarChart(
	debug		=>	1,
	vertical	=>	1,
	sort		=>	sub { return @{+shift}},
	startX		=>	25,
	startY		=>	225,
	barSize		=>	15,
	interval	=>	20,
	maxPixels	=>	240,
	textSpace	=>	50,
	maximum		=>	43,	# 43 boats sampled
	font		=>	$font,
	fontSize	=>	10);
$sailGraph->addBar(
	color	=>	'#f9f4ca',
	text	=>	'White',
	number	=>	33);
$sailGraph->addBar(
	color	=>	'#82abed',
	text	=>	'Blue',
	number	=>	3);
$sailGraph->addBar(
	color	=>	'#3dc10d',
	text	=>	'Green',
	number	=>	1);
$sailGraph->addBar(
	color	=>	'#1d39aa',
	text	=>	'Dark Blue',
	number	=>	1);
$sailGraph->addBar(
	color	=>	'#e26d36',
	text	=>	'Red',
	number	=>	3);
$sailGraph->addBar(
	color	=>	'#000000',
	text	=>	'Black',
	number	=>	2);

$sailGraph->addBar(
	color	=>	'#ffffff',
	number	=>	1);

$sailGraph->addBar(
	color	=>	'#cec6b9',
	text	=>	'Grey',
	number	=>	10);
$sailGraph->addBar(
	color	=>	'#efbb6e',
	text	=>	'Golden',
	number	=>	5);
$sailGraph->addBar(
	color	=>	'#f9f4ca',
	text	=>	'White',
	number	=>	28);

$sailGraph->addBar(
	color	=>	'#ffffff',
	number	=>	1);

$sailGraph->addBar(
	color	=>	'#cec6b9',
	text	=>	'Grey',
	number	=>	7);
$sailGraph->addBar(
	color	=>	'#efbb6e',
	text	=>	'Golden',
	number	=>	4);
$sailGraph->addBar(
	color	=>	'#f9f4ca',
	text	=>	'White',
	number	=>	32);

$imgHandle->Draw(
	stroke		=>	'black',
	fill		=>	'black',
	primitive	=>	'rectangle',
	points		=>	'20,0 20,230');
$imgHandle->Draw(
	stroke		=>	'black',
	fill		=>	'black',
	primitive	=>	'rectangle',
	points		=>	'20,230 305,230'); 
$imgHandle->Annotate(
	text		=>	'4',
	font		=>	$font,
	fill		=>	'black',
	x		=>	10,
	y		=>	35);
$imgHandle->Annotate(
	text		=>	'3',
	font		=>	$font,
	fill		=>	'black',
	x		=>	10,
	y		=>	45);
$imgHandle->Annotate(
	text		=>	'1',
	font		=>	$font,
	fill		=>	'black',
	x		=>	10,
	y		=>	225);
$imgHandle->Annotate(
	text		=>	'Hull',
	font		=>	$font,
	fill		=>	'black',
	x		=>	65,
	y		=>	242);
$imgHandle->Annotate(
	text		=>	'Headsail',
	font		=>	$font,
	fill		=>	'black',
	x		=>	165,
	y		=>	242);
$imgHandle->Annotate(
	text		=>	'Mainsail',
	font		=>	$font,	
	fill		=>	'black',
	x		=>	245,
	y		=>	242);

$sailGraph->draw($imgHandle);
$imgHandle->Write("sailcolors.png");
