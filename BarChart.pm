###########################################################################
#
#	File: BarChart.pm
#
#	Author: Alexander Christian Westholm, awestholm@verizon.net
#
#	Client: CPAN
#
#	CVS: $Id: BarChart.pm,v 1.14 2004/06/20 02:30:30 awestholm Exp $
#
###########################################################################
=head1 NAME

Image::Magick::BarChart - A simple way to create simple bar charts

=head1 SYNOPSIS
	
 # Simple example based on racially motivated crime statistics
 # for the UK in 1993
 
 use Image::Magick::BarChart;
 use Image::Magick;
 my $imgHandle	= new Image::Magick(size => "100x200");
 $imgHandle->Read('xc:white');
 my $crimeGraph	= new BarChart(
 	barSize		=>	15,
 	interval	=>	25,
 	font		=>	'@LucidaSansDemiBold.ttf',
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
 
=head1 DESCRIPTION

Image::Magick::BarChart aims to provide a way for people to easily generate bar charts from their own code. The interface is aimed at ease of use, and as such, there is much that you may not find here. If you are looking for a complex module capable of graphing any and all datasets thrown at it, you are probably looking in the wrong place. On the other hand, if you want something that won't conjure up fond memories of a statistics class, this module might fit the bill.

It can create vertical or horizontal bar charts, whose bars can be based either on percentages, or a given number of units. Although this is not the most powerful graphing package, it does intend to be flexible with what it does offer. Thus, most things that might potentially effect a simple graph are configurable.

This module is also designed to work in consort with Image::Magick. Think of an instance of Image::Magick::BarChart as a bar chart widget to be placed on an Image::Magick canvas. This allows you to generate a graph, and add fancy things to it afterward, such as a key. One case in which this will be often used is naming of axes. The BarChart module concerns itself only with the presentation of data within these axes, and leaves external labelling to the user.  

=head2 Object Construction

Instances of Image::Magick::BarChart are manipulated mostly through instance variables set during object construction. Construction is brought about through a call to B<new>. All of these instance variables may be modified at a later point during executing by calling a mutator method sharing the same name as the parameter in question, I.E. to set the interval between bars, C<$barchart-E<gt>interval(25)> Some of these parameters directly effect the instance of Image::Magick::BarChart, but many are used to customize the Bar objects which compose the graph. Many of these parameters have default values. The names, purposes and default values of these parameters are as follows (in no particular order):

=over

=item startX

I<startX> is the X coordinate at which the graph will originate. If the graph is being drawn horizontally, the bars will grow outwards from this point. The default starting X coordinate is 0.

=item startY

I<startY> is the Y coordinate at which the graph will originate. If the graph is being drawn vertically, the bars will grow upwards from this point. The default starting Y coordinate is equal to the height of the image in pixels, which means that the default is the bottom of the image.

=item vertical

I<vertical> determines whether or not the bars of a given graph will be displayed vertically or horizontally. Simply, a positive value indicates vertical bars, and any other value indicates that things should be displayed horizontally. The default is 0, thus the default is a horizontal graph.

=item interval

I<interval> is the number of pixels between the start of each bar. Note that this is not the number of pixels from the end of one bar to the start of the next. The default value is 30 pixels.

=item barSize

I<barSize> is the width of a bar in pixels. This defaults to 20 pixels.

=item font

I<font> sets the location of the font used when drawing text associated with each bar. This parameter is passed directly to Image::Magick and should be in a format acceptable to that module. This does not have a default value.

=item fontSize

I<fontSize> sets the number of pixels high a letter may be when associating text with individual bars. This is also passed directly to Image::Magick. The default value is 15 pixels.

=item textSpace

I<textSpace> sets the number of pixels that should be reserved for text associated with each bar. If this parameter is set to zero, no space will be reserved for text. Essentially, this value is subtracted from I<maxPixels> when calculating the width of a given bar. The default is 100 pixels.

=item maxPixels

I<maxPixels> sets the maximum width or height of a bar starting from the base of the graph. In other words, a bar which represents the value 100% will occupy I<maxPixels> pixels from the base of the graph. This parameter defaults to the height of the image, if drawing vertically, or the width, if drawing horizontally.

=item skip

I<skip> is the number of pixels that should separate the beginning of text from the end of a bar. Note that you can place text inside the bar if you set this to the appropriate negative value. The default is 2 pixels in distance, or just off the end of the bar.

=item border

I<border> sets the number of pixels used for creating a solid black border around the graph. If this is not set, no border will be created. The border will be created around the edge of the image canvas, and will not originate from the starting X,Y coordinate. The default is 0, or no border.

=item maximum

I<maximum> is the maximum value against which to calculate percentages for bar values. If this parameter is omitted, it is assumed that the user will pass individual values to B<addBar>. As such, there is no default.

=item sort

I<sort> takes a subroutine reference that sorts the queue of bars before they are drawn. This sub-ref should accept an array reference as its only parameter. The default sorting routine sorts by the number passed to each bar. To display bars based on insertion order, set this parameter to C<sub { return @{+shift} }>

=item comparison

I<comparison> allows you to use a method other than direct percentage comparison when calculating width/height of bars. This parameter takes a subroutine reference that takes two parameters, first the number, then the maximum value for that number. By default, the value returned is simply number / max.

=item debug

I<debug> sets a flag which will print out a few diagnostic messages to STDERR in effort to alert the user about what the module is doing. This level of debugging is far from verbose, but may help pin down error locations.

=back

=head2 Methods

=over

=item addBar

B<addBar> appends an Image::Magick::BarChart::Bar object to the graph. It can take either a pre-made Bar object as a parameter, or it can take a list of key => value pairs that will be used to construct a brand new Bar. Once a Bar object is available, several parameters will be set, according to values present in the BarChart object. If these values have been supplied to the Bar object, they will be overridden. Parameters which will be passed directly to the Bar object include I<number>, I<color>, I<text> and I<unitSize>. I<number> is the number against which a percentage will be calculated. I<color> is the color of the bar, which defaults to grey. I<text> is the text associated with the bar. I<unitSize> is the number of pixels in height and width a cubic unit should be. If I<unitSize> is specified, number will be interpreted as the number of such cubic units used to compose a bar. On the whole, bar representation by percentage is likely to be used much more often, and is probably prettier.

=item preSort

B<preSort> sorts the internal queue of Bar objects, and returns this list to the user. Since the user now has references to all Bars in the graph, each one may be individually accessed. This allows you to do things like altering the color of each odd numbered row, and similar things.

=item draw

B<draw> is called with one parameter, an instance of Image::Magick that will be used as the canvas for the graph. If this is not passed in, a white canvas, 500x500 will be used by default. Quite obviously, this method causes the graph to be drawn upon the canvas.

=back

=head1 AUTHOR

Alexander Christian Westholm, E<lt>awestholm@verizon.netE<gt>

=head1 SEE ALSO

L<Image::Magick>, L<Image::Magick::BarChart::Bar>

=head1 COPYRIGHT

Copyright 2004, Alexander Christian Westholm.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

package Image::Magick::BarChart;
use strict;
use warnings;
use vars qw[$AUTOLOAD];
use Image::Magick;
use Image::Magick::BarChart::Bar;

our $VERSION = '1.01';

sub new {
	my $pkg = shift;
	my %opts = @_;
	$opts{queue}		= [];
	# apply defaults
	$opts{firstIsIn}	= 0; #flag: first bar has been added to chart
	$opts{border}		= 0 if not defined $opts{border};
	$opts{fontSize}		= 15 if not $opts{fontSize};
	$opts{sort}		= \&_defaultSort if not $opts{sort};
	$opts{vertical}		= 0 if not defined $opts{vertical};
	$opts{interval}		= 30 if not $opts{interval};
	$opts{debug}		= 0 if not defined $opts{debug};
	$opts{barSize}		= 20 if not $opts{barSize};
	$opts{textSpace}	= 100 if not defined $opts{textSpace};
	$opts{skip}		= 2 if not $opts{skip};
	
	return bless \%opts, $pkg;
}

sub addBar {
	my $me		= shift;
	my @params	= @_;
	my $barObj;
	# allow user to pass pre-made Bar object in, or pass params
	# to create a new one
	if(not ref $params[0]){
		push @params, (maximum => $me->{maximum}) if $me->{maximum};
		$barObj = new Image::Magick::BarChart::Bar(@params);
	}else{
		$barObj = $params[0];
	}
	# modify object, push on queue
	if(not $me->{firstIsIn}){
		# set class variables...
		$barObj->maxPixels($me->{maxPixels});
		$barObj->font($me->{font});
		$barObj->fontSize($me->{fontSize});
		$barObj->comparison($me->{comparison});
		$me->{firstIsIn} = 1;
	}
	# set instance variables
	$barObj->skip($me->{skip});
	$barObj->barSize($me->{barSize});
	$barObj->textSpace($me->{textSpace});
	$barObj->vertical($me->{vertical});
	$barObj->debug($me->{debug});
	if($me->{debug}){
		print STDERR "ADDing bar ";
		print STDERR $barObj->text() if $barObj->text();
		print STDERR "\n";
	}
	push @{$me->{queue}}, $barObj;
}

sub preSort {
	my $me		= shift;
	$me->{queue} = [$me->{sort}->($me->{queue})];
	print STDERR "PRESORTing\n" if $me->{debug};
	return @{$me->{queue}};
}

sub draw {
	my $me		= shift;
	my $imgHandle	= shift;
	my $error;
	if(not $imgHandle){
		# create default canvas
		$imgHandle = new Image::Magick(size=>'500x500');
		$error = $imgHandle->Read('xc:white');
		die $error if $error;
	}
	my $height	= $imgHandle->Get('Height');
	my $width	= $imgHandle->Get('Width');
	if(not $me->{maxPixels}){
		# set maximum number of pixels for a bar
		if($me->{vertical}){
			$me->maxPixels($height);
		}else{
			$me->maxPixels($width);
		}
	}
	$me->startX(0) if not defined $me->{startX};
	$me->startY($height) if not defined $me->{startY};
	$me->_writeBorder($imgHandle) if $me->{border};
	$me->{queue} = [$me->{sort}->($me->{queue})];
	$me->_makeStartPoints();
	for(@{$me->{queue}}){
		$_->draw($imgHandle);
	}
}

sub _defaultSort {
	my @array = @{+shift};
	return sort {
		$a->{number} <=> $b->{number}
	} @array;
}

sub _writeBorder {
	my $me		= shift;
	my $imgHandle	= shift;
	my $error;
	my $height	= $imgHandle->Get('height');
	my $width	= $imgHandle->Get('width');
	print STDERR "DRAWing border $me->{border} pixels wide\n" if $me->{debug};
	if($me->{border}){
		my $tmp = ($height - $me->{border})-1;
		$error = $imgHandle->Draw(
			stroke		=>	'black',
			fill		=>	'black',
			primitive	=>	'rectangle',
			points		=>	"0, 0 $me->{border}, $height");
		die $error if $error;
		$error = $imgHandle->Draw(
			stroke		=>	'black',
			fill		=>	'black',
			primitive	=>	'rectangle',
			points		=>	"0, $height $width, $tmp");
		die $error if $error;
	}
}

sub _makeStartPoints {
	my $me		= shift;
	my $xpoint	= $me->{startX};
	my $ypoint	= $me->{startY};

	for my $bar (@{$me->{queue}}){
		# depending on if bar is horizontal or vertical,
		# adjust each bar's starting position by incrementing
		# or decrementing the starting X or Y coordinate
		$bar->barStartX($xpoint);
		$bar->barStartY($ypoint);
		$xpoint += $me->{interval} if $me->{vertical};
		$ypoint -= $me->{interval} if not $me->{vertical};
	}
}

#default handler for accessor/mutator methods
sub AUTOLOAD {
	my $me		= shift;
	my $data	= shift;
	my $instVar	= $AUTOLOAD;
	$instVar	=~ s/.*:://;
	$me->{$instVar} = $data if defined $data;
	return $me->{$instVar};
}

1;
