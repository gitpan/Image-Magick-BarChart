###########################################################################
#
#	File: Bar.pm
#
#	Author: Alexander Christian Westholm, awestholm@verizon.net
#
#	Client: CPAN
#
#	CVS: $Id: Bar.pm,v 1.7 2004/06/20 01:48:15 awestholm Exp $
#
###########################################################################
=head1 NAME

Image::Magick::BarChart::Bar - Bar objects used by the BarChart module

=head1 DESCRIPTION

Image::Magick::BarChart::Bar is an object used by the BarChart package to represent individual bars within a given chart. Essentially, the BarChart package acts as a collector/controller of these objects. Most of the attributes that affect a given bar will be set through calls to the BarChart package [through parameters to B<addBar()>]. Instances of this package can also be created and passed to B<addBar()> directly.

See the documentation for Image::Magick::BarChart for more details about the method B<addBar>.

=head2 METHODS

This package offers only two public methods: B<new()>, which is a constructor, and B<draw()>, which paints the object on a canvas. As with the main BarChart package, most of the functionality is implemented through parameters to the constructor. Most parameters are instance variables that apply to the current bar only. If this is not the case, it will be noted. The parameters are as follows:

=over

=item number

I<number> sets one of two values. If the bar is being drawn using square units, this number represents how many units will be drawn. If the bar is being drawn as a percentage, this number is the number which will be divided by I<maximum> to arrive at that percentage (assuming the default comparison function is being used).

=item maximum

I<maximum> sets the maximum number used in percentage calculation. In other words, this number is equal to 100%. Note that if this parameter is set, the bar will be drawn using the percentage method. If it is not set, the unit method will be used.

=item comparison

I<comparison> is a subroutine reference that calculates the percentage filled by a given bar. When the class calls it, it is passed I<number> and I<maximum>. It is assumed to return a numeric value. The default comparison routine returns I<number>/I<maximum>. This is a class variable, and applies to all bars in the current graph.

=item maxPixels

I<maxPixels> is the largest amount of pixels filled by bars in the current graph. In other words, I<maxPixels> will be the length or height of a bar if it is filled 100%. If the bar is being drawn in units instead of through the percentage method, this parameter will not be used. This is a class variable, and applies to all bars in the current graph.

=item unitSize

I<unitSize> sets the number of pixels in height and width a unit will consist of when drawing the current bar. For example, a value of 20 will result in 20x20 square units being used to draw the bar.

=item color

I<color> is the fill color used for the current bar. This value is passed directly to Image::Magick, and can take any form accepted by that module. This includes text names for various common colors, such as 'red', as well as RGB values, such as #FF0000.

=item vertical

I<vertical> is a boolean value which, if set, results in bars being drawn from the bottom of the canvas to the top, instead of left to right.

=item font

I<font> is another parameter that gets passed directly to Image::Magick. Obviously enough, it is the font to be used when associating text with any bar. The format of this value is as required by Image::Magick. This is a class variable, and applies to all bars in the current graph.

=item fontSize

I<fontSize> is quite obviously the size of the font used when associating text with a bar. This is given in number of pixels. This is a class variable, and applies to all bars in the current graph.

=item text

I<text> is the text description associated with the current bar.

=item textSpace

I<textSpace> is the number of pixels reserved on the canvas for text. This open area will be placed immediately above the bar, in the case of a vertical graph, or after it, in the case of horizontal. The default is 100 pixels.

=item skip

I<skip> is the number of pixels of space used to distance the text associated with a bar from the actual bar itself. By default, this is 2 pixels. Note that if a negative value is passed in, it is possible to position the text inside of the bar itself.

=item barStartX

I<barStartX> is the starting X coordinate for the current bar.

=item barStartY

I<barStartY> is the starting Y coordinate for the current bar.

=item debug

I<debug> is a boolean flag that, if given a true value, tells the module to print basic diagnostic messages as work is performed. These messages will appear on STDERR.

=back

=head1 AUTHOR

Alexander Christian Westholm, E<lt>awestholm@verizon.netE<gt>

=head1 SEE ALSO

L<Image::Magick>, L<Image::Magick::BarChart>

=head1 COPYRIGHT

Copyright 2004, Alexander Christian Westholm.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

package Bar;

use strict;
use warnings;
use vars qw[$AUTOLOAD];
use Image::Magick;

our $VERSION		= '1.01';

our $maxPixels		= 400;
our $font		= "None";
our $fontSize		= 15;
our $comparisonRoutine	= \&_defaultComparison;

sub new {
	my $pkg	= shift;
	my %opts= @_;

	die "NUMBER is a mandatory parameter for object creation!" if not $opts{number};
	if(not($opts{maximum} or $opts{unitSize})){
		die "Must supply either MAXIMUM or UNITSIZE to constructor!";
	}

	$opts{color}	= 'grey' if not $opts{color};
	$opts{vertical} = 0 if not defined $opts{vertical};
	$opts{debug}	= 0 if not defined $opts{debug};
	$opts{barSize}	= 20 if not $opts{barSize};
	$opts{textSpace}= 100 if not $opts{textSpace};
	$opts{skip}	= 2 if not $opts{skip};

	$maxPixels	= $opts{maxPixels} if $opts{maxPixels};
	$font			= $opts{font} if $opts{font};
	$fontSize		= $opts{fontSize} if $opts{fontSize};
	$comparisonRoutine	= $opts{comparison} if $opts{comparison};
	
	return bless \%opts, $pkg;
}

sub _defaultComparison {
	my $number	= shift;
	my $max		= shift;

	# div by zero won't happen because max is
	# checked in constructor and mutator, but
	# having this line makes me feel secure
	die "Cannot allow MAXIMUM to be ZERO!" if $max == 0;

	my $retval = $number / $max;
	$retval = 1 if $retval > 1;
	return $retval
}

sub draw {
	my $me		= shift;
	my $imgHandle	= shift;

	if(not(defined($me->{barStartX}) and defined($me->{barStartY}))){
		die "Must supply BARSTARTX and BARSTARTY in order to draw!";
	}
	if($me->{maximum}){
		if(not $maxPixels){
			die "Must provide MAXPIXELSMAXPIXELS  in order to draw by percentage!";
		}
		$me->_drawPercentage($imgHandle);
		print STDERR "DRAWing by percentage method\n" if $me->{debug};
	}else{
		$me->_drawUnits($imgHandle);
		print STDERR "DRAWing by unit method\n" if $me->{debug};
	}
	$me->_drawText($imgHandle) if $me->{text};
}

sub _drawPercentage {
	my $me		= shift;
	my $imgHandle	= shift;
	my $error;
	my $barCoords	= "$me->{barStartX}, $me->{barStartY} ";
	my $prcntWidth	= $maxPixels;
	my $skip = $me->{skip};
	my $barSize = $me->{barSize};
	$prcntWidth -= $me->{textSpace} if $me->{textSpace}; # afford space for text
	my $checkedMax = $comparisonRoutine->($me->{number}, $me->{maximum});
	# note that this is still necesarry even though handled by default
	# comparison routine, since the user might override that
	$checkedMax = 1 if $checkedMax > 1;
	$prcntWidth *= $checkedMax;
	if($me->{vertical}){
		$prcntWidth = $me->{barStartY} - $prcntWidth;
		$barCoords .= ($me->{barStartX} + $barSize).", $prcntWidth";
		$me->{textX} = $me->{barStartX};
		$me->{textY} = $prcntWidth+$skip;
		print STDERR "DRAWing vertically using coords: $barCoords\n" if $me->{debug};
	}else{
		$prcntWidth = $me->{barStartX} + $prcntWidth;
		$barCoords .= " ${prcntWidth}, ".($me->{barStartY} - $barSize);
		$me->{textX} = $prcntWidth+$skip;
		$me->{textY} = $me->{barStartY};
		print STDERR "DRAWing horizontally using coords: $barCoords\n" if $me->{debug};
	}
	$error = $imgHandle->Draw(
		stroke		=> $me->{color},
		fill		=> $me->{color},
		primitive	=> 'rectangle',
		points		=> $barCoords);
	die $error if $error;
}

sub _drawUnits {
	my $me		= shift;
	my $imgHandle	= shift;
	my $error;
	my $unitX1	= $me->{barStartX};
	my $unitY1	= $me->{barStartY};
	my $unitX2	= $me->{barStartX} + $me->{unitSize};
	my $unitY2	= $me->{barStartY} - $me->{unitSize};
	my $skip	= $me->{skip};

	for (1..$me->{number}){
		$error = $imgHandle->Draw(
			stroke		=> $me->{color},
			fill		=> $me->{color},
			primitive	=> 'rectangle',
			points		=> "${unitX1}, $unitY1 ${unitX2}, $unitY2");
		die $error if $error;
		if($me->{vertical}){
			$unitY1 = $unitY2 - $skip;
			$unitY2 = $unitY1 - $me->{unitSize};
		}else{
			$unitX1 = $unitX2 + $skip;
			$unitX2 = $unitX1 + $me->{unitSize};
		}
	}
	if($me->{vertical}){
		print STDERR "DRAWing units vertically starting at $unitX1, $unitY1\n" if $me->{debug};
		$me->{textX} = $unitX1;
		$me->{textY} = $unitY2+$me->{unitSize};
	}else{
		print STDERR "DRAWing units horizontally starting at $unitX1, $unitY1\n" if $me->{debug};
		$me->{textX} = $unitX2+$skip-$me->{unitSize};
		$me->{textY} = $unitY1;
	}
}

sub _drawText{
	my $me		= shift;
	my $imgHandle	= shift;
	my $error;
	if(not $font){
		die "Cannot write text without setting FONT!";
	}
	print STDERR "TEXT written to image: $me->{text}\n" if $me->{debug};
	if($me->{vertical}){
		my $ycoord = $me->{textY} - 5;
		for my $char (split //, reverse($me->{text})){
			$error = $imgHandle->Annotate(
				text		=>	$char,
				font		=>	$font,
				fill		=>	'black',
				pointsize	=>	$fontSize,
				x		=>	$me->{textX},
				y		=>	$ycoord,
			);
			die $error if $error;
			$ycoord -= $fontSize + 1;
		}
	}else{
		$error = $imgHandle->Annotate(
			text		=>	$me->{text},
			font		=>	$font,
			fill		=>	'black',
			pointsize	=>	$fontSize,
			x		=>	$me->{textX},
			y		=>	$me->{textY}
		);
		die $error if $error;
	}
}

sub comparison {
	shift;
	my $newfunc = shift;
	$comparisonRoutine = $newfunc if $newfunc;
	return $comparisonRoutine;
}

sub maxPixels{
	shift;
	my $newwid = shift;
	$maxPixels = $newwid if $newwid;
	return $maxPixels;
}

sub font {
	shift;
	my $fontloc = shift;
	$font = $fontloc if $fontloc;
	return $font;
}

sub fontSize {
	shift;
	my $newsz = shift;
	$fontSize = $newsz if $newsz;
	return $fontSize;
}

sub AUTOLOAD {
	my $me		= shift;
	my $data	= shift;
	my $instVar	= $AUTOLOAD;
	$instVar	=~ s/.*:://;
	$me->{$instVar} = $data if defined $data;
	return $me->{$instVar};
}

1;
