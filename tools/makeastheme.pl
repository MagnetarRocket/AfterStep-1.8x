#!/usr/bin/perl

use strict;

# Copyright (c) 1998 "Lathi" <doug@lathi.net>
# Copyright (c) 2000 Ethan Fischer <allanon@crystaltokyo.com>

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

###################
# Purpose
#
# The purpose of this script is to take the current AfterStep
# configuration and strip out a minimal set of data so that it can
# later be applied to the ~/G/L/A directory tree to implement a
# "theme" for AfterStep.  This script works on the assumption of
# version 1.5 or greater.

###################
# Scope
#
# Here are the individual components that I think make up a theme.
# Obviously, the individual look file in its entirety.  Also the Wharf
# TextureType, Pixmap, TextureColor, and BgColor.  The Pager Font,
# SmallFont, Fore, Back, Hilight, DesktopImage, Image, Align,
# BalloonFore, BalloonBack, BalloonFont, BalloonBorderWidth, and
# BalloonBorderColor. Finally, the WinListFont, WinListFore,
# WinListBack, and WinListJustify.  As an added bonus, a scheme will
# be included to allow icons for both Wharf and the database to be
# replaced.

# Setting these options to TRUE is somewhat misleading.  Later on I am
# just going to do a check to see if the option exist in the hash.  It
# is a fast way to find things.  So, setting them to FALSE will not
# disable the option from the list.  It must be undefined.
my %WHARF_OPTIONS = (
  "BgColor" => "TRUE",
  "Pixmap" => "TRUE",
  "TextureColor" => "TRUE",
  "TextureType" => "TRUE",
 );
my %PAGER_OPTIONS = (
  "Align" => "TRUE",
  "Back" => "TRUE",
  "BalloonBack" => "TRUE",
  "BalloonBorderColor" => "TRUE",
  "BalloonBorderWidth" => "TRUE",
  "BalloonFore" => "TRUE",
  "DesktopImage" => "TRUE",
  "Font" => "TRUE",
  "Fore" => "TRUE",
  "Hilight" => "TRUE",
  "Image" => "TRUE",
  "SmallFont" => "TRUE",
  );
my %WINLIST_OPTIONS = (
  "Font" => "TRUE",
  "Fore" => "TRUE",
  "Back" => "TRUE",
  "Justify" => "TRUE",
  "Pixmap" => "TRUE",
  );
my %LOOK_IMAGE_OPTIONS = (
  "TitleButton" => "TRUE",
  "ButtonPixmap" => "TRUE",
  "MenuPinOn" => "TRUE",
  "MenuPinOff" => "TRUE",
	"MArrowPixmap" => "TRUE",
  "BackPixmap" => "TRUE",
  "FrameNorth" => "TRUE",
  "FrameSouth" => "TRUE",
  "FrameEast" => "TRUE",
  "FrameWest" => "TRUE",
  "FrameNW" => "TRUE",
  "FrameNE" => "TRUE",
  "FrameSW" => "TRUE",
  "FrameSE" => "TRUE",
  );

###################
# Assumptions
#
# * Unique themes for each desk will not be supported at this time.
# * Modules that support multiple instances must be formed like this:
#   <new_prefix>Pager versus Wharf<bad_suffix>.  Examples might be
#   MyPager, GoodPager, MyWharf not Wharf2, WharfBad, PagerBad


################### 
# Strategy 
# 
# A new themes directory will be placed in the ~/G/L/A/desktop
# directory.  Each new theme will have its own subdirectory under
# that. Each theme's subdirectory will duplicate the ~/G/L/A/desktop
# subdirectores plus put its own "patches" to the module configuration
# files there.  For example, let's say I had a theme called 'foo'. I
# would then have a directory ~/G/L/A/desktop/themes/foo.  Under that
# I would have the 16bpp, 8bpp, common subdirs and possibly 24bpp and
# other bit depths.  Also in the ~/G/L/A/desktop/themes/foo directory
# would be wharf.foo, pager.foo, and winlist.foo.  OK, that sets up
# how the theme data is stored.
#
# Now on the startmenu, in the Decorations submenu would be a new menu
# called "Themes".  When the startmenu is built, it will scan the
# ~/G/L/A/desktop/themes directory to determine what themes are
# "installed".  When the user then selects a theme from the startmenu,
# this theme installer script will then be executed to modify the
# appropriate files in the non-configurable directory.  
#

###################
# Defines
my $PROGRAM_NAME = "makeastheme.pl";
my $VERSION_MAJOR = 0;
my $VERSION_MINOR = 5;
my $VERSION_PATCH = 3;
my $BIT_DEPTH;             # This value is later read in from the system 

###################
# Command line option defaults;

my ($COMMAND_PATH, $COMMAND_NAME) = ($0 =~ m{^(.*)/([^/]+)$});
my $GET_WHARF = 1;
my $GET_PAGER = 1;
my $GET_WINLIST = 1;
my $GET_BACKGROUND = 1;
my $THEME_NAME = $ENV{USER};
my $VERBOSE = 1;
my $TMPDIR = "/tmp/astheme.$$";
my $UPDATE_AS = 1;

##################
# Command Line Syntax Checking
sub usage {
  my $usage;
  $usage = sprintf(
           "Usage: \n" .
           "%s [-h] [--no_wharf] [--no_pager] [--no_winlist] [--no_background]\n" .
           "%*s [--no-update] [-q] [-v] [-V] [[-t] <theme_name>]\n" .
           "  -h --help           this help\n" .
           "     --no_background  do not install desktop background\n" .
           "     --no_pager       do not install pager options\n" .
           "     --no_wharf       do not install wharf options\n" .
           "     --no_winlist     do not install winlist options\n" .
           "     --no-update      do not tell AfterStep to load the theme\n" .
           "  -q --quiet          do not print anything\n" .
           "  -t --theme          specify theme to install\n" .
           "  -V --verbose        warn about missing options\n" .
           "  -v --version        print version information\n",
           $COMMAND_NAME, length($COMMAND_NAME), "");
  return $usage;
}

sub version {
  return "$PROGRAM_NAME $VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH\n";
}

while (@ARGV >= 1) {
  my $argument = shift;
  if (($argument eq "-t" || $argument eq "--theme") && @ARGV) {
    $THEME_NAME = shift;
  } elsif ($argument eq "--no_wharf") {
    $GET_WHARF = 0;
  } elsif ($argument eq "--no_pager") {
    $GET_PAGER = 0;
  } elsif ($argument eq "--no_winlist") {
    $GET_WINLIST = 0;
  } elsif ($argument eq "--no_background") {
    $GET_BACKGROUND = 0;
  } elsif ($argument eq "--no-update") {
    $UPDATE_AS = 0;
  } elsif ($argument eq "-q" || $argument eq "--quiet") {
    $VERBOSE = 0;
  } elsif ($argument eq "-V" || $argument eq "--verbose") {
    $VERBOSE = 2;
  } elsif ($argument eq "-h" || $argument eq "--help") {
    print usage();
    exit 0;
  } elsif ($argument eq "-v" || $argument eq "--version") {
    print version();
    exit 0;
  } elsif ($argument =~ /^--/) {
  	last;
  } else {
    print usage();
    exit 1;
  }
}

if (@ARGV > 1) {
  print usage();
  exit 1;
}

$THEME_NAME = shift if @ARGV;

###################
# Determine base directory names

my $AFTERSTEP_VERSION;
my $AFTERSTEP_DIR="~/GNUstep/Library/AfterStep";
my $SHARE_DIR="/usr/local/share/afterstep";

open (PROC, "afterstep -c 2> /dev/null |");
if (eof(PROC)) {
  warn "Cannot start 'afterstep -c' process: $!\n" .
       "Please be sure 'afterstep' is in your \$PATH.\n" if ($VERBOSE > 1);
}
foreach (<PROC>) {
  s/\s+/ /;
  my ($key,$value) = split ' ';
  $AFTERSTEP_DIR = $value if ($key eq "AfterDir");
  $SHARE_DIR = $value if ($key eq "ShareDir");
  $AFTERSTEP_VERSION = (split(' '))[2] if ($key eq "AfterStep" && $value eq "version");
}
close PROC;

$AFTERSTEP_DIR =~ s@^~/@$ENV{HOME}/@;
###################
# Derive some more directory names

my $NONCONFIG_DIR="${AFTERSTEP_DIR}/non-configurable";
my $DESKTOP_DIR="${AFTERSTEP_DIR}/desktop";
my $THEME_DIR="$TMPDIR";
my $WHARF_FILE="${AFTERSTEP_DIR}/wharf";
my $PAGER_FILE="${AFTERSTEP_DIR}/pager";
my $WINLIST_FILE="${AFTERSTEP_DIR}/winlist";
my $BACKGROUND_FILE="${NONCONFIG_DIR}/0_background";

###################
# Make sure temporary files are removed.

$SIG{INT} = \&signal_handler;
$SIG{QUIT} = \&signal_handler;
$SIG{HUP} = \&signal_handler;
END { rmdir_tree($TMPDIR); }

###################
# Configuration Checking

foreach my $dir ($AFTERSTEP_DIR, $NONCONFIG_DIR, $DESKTOP_DIR, $THEME_DIR, "$THEME_DIR/$THEME_NAME", "$AFTERSTEP_DIR/themes") {
  if (! -d $dir) {
    warn "Could not find directory $dir.\n" if ($VERBOSE > 1);
    if (!mkdir($dir, 0700)) {
    	warn "Unable to create directory $dir: $!\n" if ($VERBOSE);
    	exit 1;
    }
  }
}

$THEME_DIR = "${THEME_DIR}/${THEME_NAME}";

if ($GET_WHARF && ( ! -f $WHARF_FILE )) {
  warn "Cannot find the Wharf config file: $WHARF_FILE\n" .
       "Will not create Wharf specific info for theme.\n" if ($VERBOSE > 1);
  $GET_WHARF = 0;
}

if ($GET_PAGER && ( ! -f $PAGER_FILE )) {
  warn "Cannot find the Pager config file, $PAGER_FILE\n" .
       "Will not create Pager specific info for theme.\n" if ($VERBOSE > 1);
  $GET_PAGER = 0;
}

if ($GET_WINLIST && ( ! -f $WINLIST_FILE )) {
  warn "Cannot find the WinList config file, $WINLIST_FILE\n" .
       "Will not create WinList specific info for theme.\n" if ($VERBOSE > 1);
  $GET_WINLIST = 0;
}

if ($GET_BACKGROUND and ( ! -f $BACKGROUND_FILE )) {
  warn "Cannot find the image file, $BACKGROUND_FILE\n" .
       "Will not apply theme to background image\n" if ($VERBOSE > 1);
  $GET_BACKGROUND = 0;
}

# Get bit depth via xdpyinfo
open (PROC, "xdpyinfo 2> /dev/null |");
if (eof(PROC)) {
  warn "Cannot start 'xdpyinfo' process: $!\n" .
       "Please be sure 'xdpyinfo' is in your \$PATH.\n" if ($VERBOSE);
  exit 1;
}

while (<PROC>) {
  # looking for a line that has the key word "depths" on it, as in:
  # screen #0:
  #  dimensions:    1024x768 pixels (347x260 millimeters)
  #  resolution:    75x75 dots per inch
  #  depths (1):    16
  next unless /depths/;
  # strip out all the stuff except the actual bit depth
  chomp;			# and the pesky newlines
  s/\s*depths \((\d+)\):\s*//;
  my @depths = split /,\s/, $_, $1;
  $BIT_DEPTH = $depths[scalar(@depths) -1];
  last;
}
close PROC;

# Check to make sure we got the bit depth from xdpyinfo
unless ($BIT_DEPTH) {
  warn "Couldn't figure out bit depth from xdpyinfo.\n" .
       "Using default of 8.\n" if ($VERBOSE > 1);
	$BIT_DEPTH = 8;
}

# Now that we know the bit depth, we know which look file to
# modify in the non-config directory
my $LOOK_FILE = find_config_file("non-configurable/0_look.${BIT_DEPTH}bpp");
my $BASE_FILE = find_config_file("base.${BIT_DEPTH}bpp");

if (!$LOOK_FILE) {
  warn "Unable to find file non-configurable/0_look.${BIT_DEPTH}bpp: $!\n" if ($VERBOSE);
  exit 1;
}
if (!$BASE_FILE) {
  warn "Unable to find file base.${BIT_DEPTH}bpp: $!\n" if ($VERBOSE);
  exit 1;
}

# OK, everything is kosher; let's do the easy stuff first...
# Create an "afterstep_version" file to save the version of AfterStep
# this theme was created with.

if (!open(FP, ">${THEME_DIR}/afterstep_version")) {
  warn "Cannot write to ${THEME_DIR}/afterstep_version: $!\n" if ($VERBOSE);
  exit 1;
}
print FP "$AFTERSTEP_VERSION\n";
close(FP);

# copy the look file from the non-config dir over to our theme dir

open(LOOK_SOURCE, "$LOOK_FILE");
my @look_source = <LOOK_SOURCE>;
close LOOK_SOURCE;
if (!open(LOOK_TARGET, ">${THEME_DIR}/look.${THEME_NAME}")) {
  warn "Cannot write to ${THEME_DIR}/look.${THEME_NAME}: $!\n" if ($VERBOSE);
  exit 1;
}
print LOOK_TARGET @look_source;
close LOOK_TARGET;

# Let's copy the background over to the theme dir
if ($GET_BACKGROUND) {
  open BACKGROUND_SOURCE, "$BACKGROUND_FILE" or
    die "Cannot read from $BACKGROUND_FILE, $!\n";
  open BACKGROUND_TARGET, ">${THEME_DIR}/background.${THEME_NAME}" or
    die "Cannot write to ${THEME_DIR}/background.${THEME_NAME}, $!\n";
  print BACKGROUND_TARGET <BACKGROUND_SOURCE>;
  close BACKGROUND_TARGET;
  close BACKGROUND_SOURCE;
}


# Before we are done with the look file, we need to scan through and
# find any images that need to be copied over to the theme dir.
foreach my $line (@look_source) {
  $line =~ /^\s*(\w+)/;
  if ((defined $1) and (exists $LOOK_IMAGE_OPTIONS{$1})) {
    my $option = $1;
    if ( $1 eq "BackPixmap" ) {
      $line =~ s/^\s*\w+\s+(\d+)\s+//;
      if ( $1 != "128" && $1 != "130") {
	next;
      }
    } elsif ( $1 eq "TitleButton" ) {
      $line =~ s/^\s*\w+\s+\d\s+//;
      my ($image1, $image2) = split /\s+/, $line, 2;
      my $image_name = get_image ($image1); # Finds which directory in
                                       # the PixmapPath the image is in
      copy_image ($image_name); # Copies the correct image to the
                                # theme dir
      $line = $image2;
    }else {
      $line =~ s/^\s*\w+\s+//;
    }
    chomp $line;
    my $image_name = get_image ($line);
    my $return = copy_image ($image_name);
    if ($return) {
      warn "Could not copy '$image_name' from option $option in $LOOK_FILE\n" if ($VERBOSE > 1);
    }
  }
}


# OK, now we are going to scan through the wharf, pager, and winlist
# config files looking for the options we think belong in a theme.
# When we find one, we will strip off the module name and write only
# the option name and the rest of the line to the theme file

my $option;
if ($GET_WHARF) {
  open WHARF_THEME, ">${THEME_DIR}/wharf.${THEME_NAME}" or
    die "Cannot write to the ${THEME_DIR}/wharf.${THEME_NAME}\n";
  open WHARF_FILE, "$WHARF_FILE" or
    die "Cannot read from $WHARF_FILE, $!";
  while(<WHARF_FILE>) {
    s/^\*(\w*Wharf)(\w+)/$2/;	# the stuff in () is the option to
                                # match on.
    if ((defined $2) and (exists $WHARF_OPTIONS{$2})) {
      $option = $2;
      print WHARF_THEME;
      if ( $2 eq "Pixmap" ) {
	s/^Pixmap\s+//;
	chomp;
	my $image_name = get_image ($_); # Finds which directory in
                                         # the PixmapPath the image is in
	my $return = copy_image ($image_name); # Copies the correct image to the
                                  # theme dir
	if ($return) {
	  die "Could not copy '$image_name' from option $option in $WHARF_FILE\n"
	}
      }
    }
    /./;			# clears the patter matching variables
  }
  close WHARF_FILE;
  close WHARF_THEME;
}

if ($GET_PAGER) {
  open PAGER_THEME, ">${THEME_DIR}/pager.${THEME_NAME}" or
    die "Cannot write to the ${THEME_DIR}/pager.${THEME_NAME}\n";
  open PAGER_FILE, "$PAGER_FILE" or
    die "Cannot read from $PAGER_FILE, $!";
  while(<PAGER_FILE>) {
    s/^\*(\w*Pager)(\w+)/$2/;	# the stuff in () is the option to
                                # match on.
    if ((defined $2) and (exists $PAGER_OPTIONS{$2})) {
      my $option = $2;
      print PAGER_THEME;
      if ($option =~ /Image$/) {
	s/^.*Image\s+(\d+)\s+//;
	chomp;
	if (m!~/GNUstep/Library/AfterStep/non-configurable/\d_background!) {
	  next;
	} else {
	  my $image_name = get_image ($_); # Finds which directory in
                                         # the PixmapPath the image is in
	  my $return = copy_image ($image_name); # Copies the correct image to the
                                  # theme dir
	  if ($return) {
	    warn "Could not copy the '$image_name' from the option $option in $PAGER_FILE\n" if ($VERBOSE > 1);
	  }
	}
      }
    }
    /./;			# clears the pattern matching variables
  }
  close PAGER_FILE;
  close PAGER_THEME;
}

if ($GET_WINLIST) {
  open WINLIST_THEME, ">${THEME_DIR}/winlist.${THEME_NAME}" or
    die "Cannot write to the ${THEME_DIR}/winlist.${THEME_NAME}\n";
  open WINLIST_FILE, "$WINLIST_FILE" or
    die "Cannot read from $WINLIST_FILE, $!";
  while(<WINLIST_FILE>) {
    s/^\*(\w*WinList)(\w+)/$2/;	# the stuff in () is the option to
                                # match on.
    if ((defined $2) and (exists $WINLIST_OPTIONS{$2})) {
      print WINLIST_THEME;
    }
    if ((defined $2) and ($2 eq "Pixmap")) {
	chomp;
	s/^.*Pixmap\s+//;
	my $image_name = get_image ($_); # Finds which directory in
				# the PixmapPath the image is in
	my $return = copy_image ($image_name); # Copies the correct
                                               # image to the theme
                                               # dir
	if ($return) {
	  warn "Could not copy the '$image_name' from the option $option in $PAGER_FILE\n" if ($VERBOSE > 1);
	}
      }
    /./;			# clears the patter matching variables
  }
  close WINLIST_FILE;
  close WINLIST_THEME;
}

chdir($TMPDIR);
qx{tar cf - "$THEME_NAME" | gzip -9 > "$AFTERSTEP_DIR/themes/$THEME_NAME.tar.gz"};

if ($UPDATE_AS) {
  exec('ascommand.pl', 'QuickRestart "" startmenu');
}

sub get_image {
  my @pixmap_path;
  my $image_name = shift;
  
  $image_name =~ s/^~/$ENV{'HOME'}/; # perl doesn't grok the '~'
  $image_name =~ s/\s*$//;		# gotta remove any trailing white space
  if ( -e $image_name ) {
    return $image_name;
  }
  
  open BASE_FILE, $BASE_FILE or
    die "Cannot read from $BASE_FILE, $!\n";
  
  while(<BASE_FILE>) {
    next unless (/^PixmapPath/);
    chomp;
    s/^PixmapPath\s+//;
    s/~/$ENV{'HOME'}/g;	      # Perl doesn't grok '~'
    @pixmap_path = split /:/; # This stores the directories in the
                              # pixmap path in an array that can be
                              # searched for the necessary image.
    last;
  }
  close BASE_FILE;
  my @found_icons = grep { -e ($_ = "$_/$image_name") } @pixmap_path;
  my $match = $found_icons[0];
  if (!defined $match || $match eq "") {
    warn "Could not find $image_name\n" if ($VERBOSE > 1);
    return -1;
  } else {
    return $match;	# This returns the first found image
  }
}

sub copy_image {
  my $image_name = shift;
  $image_name =~ m!([^/]*)$!;
  my $base_name = $1;

  
  open IMAGE_SOURCE, $image_name or do {
    warn "Cannot read from $image_name, $!\n" if ($VERBOSE > 1);
    return 1;
  };
  open IMAGE_TARGET, ">${THEME_DIR}/${base_name}" or do {
    warn "Cannot write to ${THEME_DIR}/${base_name}, $!\n" if ($VERBOSE > 1);
    return 1;
  };

  print IMAGE_TARGET <IMAGE_SOURCE>;
  close IMAGE_SOURCE;
  close IMAGE_TARGET;
  return 0;
}

sub find_config_file {
	my ($filename) = @_;
	if (-f "$AFTERSTEP_DIR/$filename") {
		return "$AFTERSTEP_DIR/$filename";
	} elsif (-f "$SHARE_DIR/$filename") {
		return "$SHARE_DIR/$filename";
	}
	return undef;
}

sub open_with_fail {
	my ($filename, $fail_ok) = @_;
	local *FH;
	if (!open(FH, $filename)) {
		warn "Unable to open $filename: $!\n" if ($VERBOSE > $fail_ok);
		exit 1 unless $fail_ok;
	}
	return *FH;
}

sub signal_handler {
	rmdir_tree($TMPDIR);
	exit 1;
}

sub rmdir_tree {
	my ($path) = @_;
	if (defined $path && -d $path) {
		opendir(DIR, $path);
		foreach (readdir(DIR)) {
			if (! -d "$path/$_") {
				unlink("$path/$_");
			} elsif ($_ ne '.' && $_ ne '..') {
				rmdir_tree("$path/$_");
			}
		}
		closedir(DIR);
		rmdir("$path");
	}
}
