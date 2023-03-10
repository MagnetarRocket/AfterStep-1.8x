#!/usr/bin/perl

use strict;
use Cwd;

# Copyright (c) 1998 Doug Alcorn <alcornd@earthlink.net>
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
# The purpose of this script is to take a minimal set of data and apply
# it to the ~/G/L/A directory tree to implement a "theme" for AfterStep.
# This script works on the assumption of version 1.5 or greater.

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

###################
# Flags
my %IMAGE_OPTIONS = (
  "Pixmap" => "TRUE",
  "DesktopImage" => "TRUE",
  "Image" => "TRUE",
  "Pixmap" => "TRUE",
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
my %MOD_FLAGS = (
  'wharf' => "TRUE",
  'pager' => "TRUE",
  'winlist' => "TRUE",
  'background' => "TRUE",
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
my $PROGRAM_NAME = "installastheme.pl";
my $VERSION_MAJOR = 0;
my $VERSION_MINOR = 5;
my $VERSION_PATCH = 3;
my $BIT_DEPTH;             # This value is later read in from the system 

###################
# Defines
my ($COMMAND_PATH, $COMMAND_NAME) = ($0 =~ m{^(.*)/([^/]+)$});
my $THEME_NAME = $ENV{USER};
my $VERBOSE = 1;
my $TARFILE = 0;
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
    delete $MOD_FLAGS{wharf};
  } elsif ($argument eq "--no_pager") {
    delete $MOD_FLAGS{pager};
  } elsif ($argument eq "--no_winlist") {
    delete $MOD_FLAGS{winlist};
  } elsif ($argument eq "--no_background") {
    delete $MOD_FLAGS{bckground};
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
    $THEME_NAME = shift;
    last;
  } elsif ($argument =~ /^-/) {
    print "unknown option: $argument\n";
    print usage();
    exit 1;
  } else {
    $THEME_NAME = $argument;
    last;
  }
}

if (@ARGV > 1) {
  print usage();
  exit 1;
}

###################
# Determine base directory names

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
}
close PROC;

$AFTERSTEP_DIR =~ s@^~/@$ENV{HOME}/@;

###################
# Derive some more directory names

my $NONCONFIG_DIR="${AFTERSTEP_DIR}/non-configurable";
my $THEME_DIR="${AFTERSTEP_DIR}/desktop/themes";
my $WHARF_FILE="${AFTERSTEP_DIR}/wharf";
my $PAGER_FILE="${AFTERSTEP_DIR}/pager";
my $WINLIST_FILE="${AFTERSTEP_DIR}/winlist";
my $BACKGROUND_FILE="${NONCONFIG_DIR}/0_background";
my %FILE_NAMES = (
  'wharf' => "wharf",
  'pager' => "pager",
  'winlist' => "winlist",
  'background' => "non-configurable/0_background",
  );

foreach (keys %FILE_NAMES) {
  my $filename = $FILE_NAMES{$_};
  $FILE_NAMES{$_} = find_or_copy_config_file($filename);

  if (!$FILE_NAMES{$_} || ! -f $FILE_NAMES{$_}) {
    warn "Unable to find file $filename: $!\n" if ($VERBOSE);
    exit 1;
  }
}

###################
# Configuration Checking

foreach my $dir ($AFTERSTEP_DIR, $NONCONFIG_DIR, "${AFTERSTEP_DIR}/desktop", $THEME_DIR) {
  if (! -d $dir) {
    warn "Could not find directory $dir.\n" if ($VERBOSE > 1);
    if (!mkdir($dir, 0700)) {
    	warn "Unable to create directory $dir: $!\n" if ($VERBOSE);
    	exit 1;
    }
  }
}

# If the requested file is not a theme dir under $THEME_DIR (which is 
# quite likely), then go to tarfile mode.
# 1. Create $TMPDIR/astheme.$PID, with safe permissions
# 2. Delete all files (but not subdirs) in $THEME_DIR
# 3. Untar the tarfile in $TMPDIR/astheme.$PID
# 4. Set $THEME_NAME to the first subdir in $TMPDIR/astheme.$PID
# 5. Copy all files from $TMPDIR/astheme.$PID/$THEME_NAME to $THEME_DIR
# 6. Remove $TMPDIR/astheme.$PID

if (! -d "$THEME_DIR/$THEME_NAME") {
	$TARFILE = 1;

	$SIG{INT} = \&signal_handler;
	$SIG{QUIT} = \&signal_handler;
	$SIG{HUP} = \&signal_handler;

	if (substr($THEME_NAME, 0, 1) ne "/") {
		$THEME_NAME = cwd."/$THEME_NAME";
	}
	# Step 1
	if (!mkdir($TMPDIR, 0700)) {
		warn "Unable to create directory $TMPDIR: $!\n" if ($VERBOSE);
		exit 1;
	}
	# Step 2
	if (!opendir(DIR,"$THEME_DIR")) {
		warn "Unable to open directory $THEME_DIR: $!\n" if ($VERBOSE);
		exit 1;
	}
	foreach my $subdir (readdir(DIR)) {
		if (! -d "$THEME_DIR/$subdir") {
			unlink("$THEME_DIR/$subdir");
		}
	}
	closedir(DIR);
	# Steps 3, 4, and 5
	chdir $TMPDIR;
	if (!system(qq'gzip -dc "$THEME_NAME" | tar xf -')) {
		opendir(DIR,$TMPDIR);
		foreach my $dir (readdir(DIR)) {
			if (-d "$TMPDIR/$dir" && $dir ne '.' && $dir ne '..') {
				$THEME_NAME = $dir;
			}
		}
		closedir(DIR);
		opendir(DIR,"$TMPDIR/$THEME_NAME");
		foreach (readdir(DIR)) {
			if (! -d $_) {
				copy_file("$TMPDIR/$THEME_NAME/$_", "$THEME_DIR/$_");
			}
		}
		closedir(DIR);
	}
	rmdir_tree($TMPDIR);
}

END { rmdir_tree($TMPDIR); }
sub signal_handler { rmdir_tree($TMPDIR); exit 1; }

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

my %module = (
  wharf => ['Wharf config file','wharf'],
  winlist => ['WinList config file','winlist'],
  background => ['background image','non-configurable/0_background'],
  pager => ['Pager config file','pager'],
);

foreach my $m (keys %module) {
  if (exists $MOD_FLAGS{$m}) {
    if (! -f "$THEME_DIR/$m.$THEME_NAME") {
      print "Cannot find the $module{$m}[0], $THEME_DIR/$m.$THEME_NAME\n" if ($VERBOSE > 1);
      print "Will not apply theme to $m.\n" if ($VERBOSE > 1);
      delete $MOD_FLAGS{$m};
    } elsif (! -f $FILE_NAMES{$m}) {
      print "Cannot find the config file, $FILE_NAMES{$m}\n" if ($VERBOSE > 1);
      if ( ! -r "$SHARE_DIR/$module{$m}[1]" ) {
        warn "Cannot find global $module{$m}[0]: ${SHARE_DIR}/$module{$m}[1]\n" if ($VERBOSE);
        exit 1;
      }
      print "Copying global config file $SHARE_DIR/$module{$m}[1] to $AFTERSTEP_DIR\n" if ($VERBOSE > 1);
      open(SRC, "${SHARE_DIR}/$module{$m}[1]");
      open(DST, ">${AFTERSTEP_DIR}/$module{$m}[1]");
      print DST <SRC>;
      close(DST);
      close(SRC);
    }
  }
}

# Get bit depth via xdpyinfo
open (PROC, "xdpyinfo|") or
  die "Cannot start 'xdpyinfo' process, $!\n";
while (<PROC>) {
  # looking for a line that has the key word "depths" on it, as in:
  # screen #0:
  #  dimensions:    1024x768 pixels (347x260 millimeters)
  #  resolution:    75x75 dots per inch
  #  depths (1):    16
  next unless /depths/;
  # strip out all the stuff except the actual bit depth
  chomp;			# and the pesky newlines

  s {
     \s*			# Match any beginning spaces
     depths			# Catch the keyword "depths"
     \s+			# follwed by some more spaces
     \(
     (\d+)			# some number of digets 
                                # (remember them for later)
     \)				# the digets are enclosed in parens
     :\s*			# follwed by a colon and some more spaces
     }[]x;			# replace all that with nothing (erase it)
  # The number in parenthases is the length of a list of bit depths
  # We will make an array of that list and read the last one as the actual
  # bit depth
  my @depths = split /,\s/, $_, $1;
  $BIT_DEPTH = $depths[0];
  last;
}

# Check to make sure we got the bit depth from xdpyinfo
unless ($BIT_DEPTH) {
  warn "Couldn't figure out bit depth from xdpyinfo.\n" .
       "Using default of 8.\n" if ($VERBOSE > 1);
	$BIT_DEPTH = 8;
}

# Now that we know the bit depth, we know which look file to
# modify in the non-config directory
$FILE_NAMES{look} = find_or_copy_config_file("non-configurable/0_look.${BIT_DEPTH}bpp");
$FILE_NAMES{base} = find_or_copy_config_file("base.${BIT_DEPTH}bpp");

if (! -f $FILE_NAMES{look}) {
  warn "Unable to find file non-configurable/0_look.${BIT_DEPTH}bpp: $!\n" if ($VERBOSE);
  exit 1;
}
if (! -f $FILE_NAMES{base}) {
  warn "Unable to find file base.${BIT_DEPTH}bpp: $!\n" if ($VERBOSE);
  exit 1;
}

# OK, everything is kosher; let's do the easy stuff first...
if (!open(LOOK_SOURCE, "${THEME_DIR}/look.${THEME_NAME}")) {
  warn "Cannot read from ${THEME_DIR}/look.${THEME_NAME}: $!\n" if ($VERBOSE);
  exit 1;
}
my @look_source = <LOOK_SOURCE>;
close LOOK_SOURCE;

# Go through and fix the paths of all the images
for (my $line = 0; $line < scalar(@look_source); $line++) {
  # Skip comment lines (there shouldn't really be any)
  next if ($look_source[$line] =~/^\#/);
  # split and save any leading spaces...
  my $spaces;
  $look_source[$line] =~ s/^(\s+)//;
  if (defined $1) {
    $spaces = $1;
  } else {
    $spaces = "";
  }
  if ($look_source[$line] eq "") {
    s/^/$spaces/;
    next;
  }
  # split the line on the first white space
  my ($option, $parameter) = split /\s+/, $look_source[$line], 2;
  # What might be nice here is to check to make sure that only
  # "approved" options are in the list...
  if (exists $IMAGE_OPTIONS{$option}) {
    # I need to make sure the path specified on images is correct
    if ($option eq "TitleButton") {
	# TitleButton works different from the other image options It
	# has multiple arguments in the $parameter, and the first of
	# which is not an image.
	my ($button, $unpressed, $pressed) = split /\s+/, $parameter, 3;
	$unpressed = &fix_path($option, $unpressed);
	$pressed = &fix_path($option, $pressed);
	$parameter = $button . " " . $unpressed . " " . $pressed;
	$look_source[$line] = $option . " " . $parameter;
      } elsif ($option eq "BackPixmap") {
	my ($type, $image) = split /\s+/, $parameter, 2;
	chomp($type, $image);
	$image = &fix_path($option, $image);
	$look_source[$line] = "$option $type $image\n";
      } else {
	# This means we have a standard image option, which just has
	# the image filename as a parameter
	$parameter = &fix_path($option, $parameter);
	$look_source[$line] = $option . " " . $parameter;
      }
  }
  # put the spaces back at the beginning of the line
  $look_source[$line] =~ s/^/$spaces/;
}

# while we're here, let's put a copy in the non-config dir
open LOOK_TARGET, ">$FILE_NAMES{'look'}" or
  die "Cannot write to $FILE_NAMES{'look'}, $!\n";
print LOOK_TARGET @look_source;
close LOOK_TARGET;

# Let's copy the background over to the non-config dir
if (exists $MOD_FLAGS{'background'}) {
  open BACKGROUND_TARGET, ">$FILE_NAMES{'background'}" or
    die "Cannot write to $FILE_NAMES{'background'}, $!\n";
  open BACKGROUND_SOURCE, "${THEME_DIR}/background.${THEME_NAME}" or
    die "Cannot read ${THEME_DIR}/background.${THEME_NAME}, $!\n";
  print BACKGROUND_TARGET <BACKGROUND_SOURCE>;
  close BACKGROUND_TARGET;
  close BACKGROUND_SOURCE;
  delete $MOD_FLAGS{'background'};
}

# OK, in the wharf, pager, and winlist file only the options that need
# to be replaced from the config files.  Lets read the options into a
# hash.  Some assumptions here, any multiple Wharfs, or Pagers will
# begin with *<new_name>Pager rather than *Pager<new_name>.  This
# could probably be done with a subroutine.

foreach my $module (keys %MOD_FLAGS) {
  &edit_config($module);
}

# The thought on the base.bpp file is this: if we prefix the PixmaPath
# with our theme dir, and icons in that path will be used instead of
# the normal ones.  This will allow the themeifying of the window
# icons and wharf icons without actually having to modify the wharf
# icon names or database icon names.  The only problem might be with having
# a line that is too long.

rename $FILE_NAMES{base}, "$FILE_NAMES{base}.temp" or
  die "Cannot rename $FILE_NAMES{base}, $!\n";
open BASE_INPUT, "$FILE_NAMES{base}.temp" or
  die "Cannot read $FILE_NAMES{base}.temp, $!\n";
open BASE_FILE, ">$FILE_NAMES{base}" or
  die "Cannot write to $FILE_NAMES{base}, $!\n";

while (my $line = <BASE_INPUT>) {
  # Let's arbitrarily hammer any directories in the PixmapPath that
  # are subdirs of ~g/l/a/desktop/themes...  If anyone complains, I
  # don't know how to fix it.  The problem is that if a bunch of
  # themes get applied in a row, the PixmapPath will become too long.
  #
  # Note that if the $HOME directory is replaced with the '~', I won't
  # hammer it with this substitute...
  if ($line =~ /^\s*PixmapPath/i) {
    my $ppath = $line;
    $ppath =~ s{^(\s*PixmapPath\s*)(.*)}[$1]s;
    $line =~ s{^\s*PixmapPath\s*}[]i;
    chomp $line;
    my @path = split(/:/, $line);
    for (my $i = @path - 1 ; $i >= 0 ; $i--) {
      if ($path[$i] eq "" || $path[$i] =~ "^$THEME_DIR\$" || $path[$i] =~ "^$THEME_DIR/") {
        splice(@path, $i, 1);
      }
    }
    unshift(@path, $THEME_DIR);
    $line = "$ppath " . join(':', @path) . "\n";
  }
  print BASE_FILE $line;
}
close BASE_FILE;
close BASE_INPUT;

if ($UPDATE_AS) {
  exec('ascommand.pl', 'Restart "" afterstep');
}

sub edit_config {

  # This little routing is a way to genericly edit a module's config
  # file.  It does this by evaluating the argument passed (the lower
  # case version of the module name, eg 'wharf') in varying contexts
  # to get the global variables needed for that module.
  
  my $module_name = shift;
  my $proper_name = substr $module_name, 0, 1;
  $proper_name =~ tr /a-z/A-Z/;
  $proper_name .= substr $module_name, 1;
  my %module_options;
  open MODULE_THEME, "${THEME_DIR}/${module_name}.${THEME_NAME}" or
    die "Cannot read from the ${THEME_DIR}/${module_name}.${THEME_NAME}, $!\n";

  while (<MODULE_THEME>) {
    # Skip comment lines (there shouldn't really be any)
    next if /^\#/;
    # split the line on the first white space
    my ($option, $parameter) = split /\s+/, $_, 2;
    # What might be nice here is to check to make sure that only
    # "approved" options are in the list...
    if (exists $IMAGE_OPTIONS{$option}) {
      if ($option eq "DesktopImage" or $option eq "Image") {
	# Because of the multiple desks and images, we need to handle
	# the PagerImage and PagerDesktopImage differently.
	# Specifically, I will store the desk number for later
	# reference in the target pager config.
	my ($desk, $image) = split /\s+/, $parameter, 2;
	$image = &fix_path($option, $image);
	unless ($module_options{$option}) {
	  # if this is the first option found that ends in "Image"
	  # initialize the hash to point to an anonymous hash
	  $module_options{$option} = {};
	}
	$module_options{$option}{$desk} = $image;
      } else {
	# This means we have a "standard" image option and need to
	# strip any possible specifying path off
	$parameter = &fix_path($option, $parameter);
	$module_options{$option} = $parameter;
      }
    } else {
      $module_options{$option} = $parameter;
    }
  }
  close MODULE_THEME;

  rename $FILE_NAMES{$module_name}, "$FILE_NAMES{$module_name}.temp" or
    die "Cannot make temp file $FILE_NAMES{$module_name}.temp, $!\n";
  open MODULE_INPUT, "$FILE_NAMES{$module_name}.temp" or
    die "Cannor read from $FILE_NAMES{$module_name}.temp, $!\n";
  open MODULE_FILE, ">$FILE_NAMES{$module_name}" or
    die "Cannot write to $FILE_NAMES{$module_name}, $!\n";
  while(<MODULE_INPUT>) {
    my $this_line = $_;
    # the stuff in the second () is the option to match on.
    my ($cust_module_name, $option, $rest_of_line) 
      = m {
	   ^
	   \*			# Match the first character as a '*'
	   (\w*)		# followed by some number of A/N characters
	   $module_name		# followed by our actual module
				# name. this captures the actual
				# module name as it might be linked to
				# allow for multiple instances of the module
	   (\w+)		# This is the actual option name
	   (.*)$		# capture and remember the rest of the line
	  }xi;
 
    unless (defined $option and exists $module_options{$option}) {
      # this means that the line of the wharf file is not interesting
      # so, we will just print it out unmodified
      print MODULE_FILE;
      next;
    }
    # We know we have a potential line to replace.  
    # First, we want to check to see if this looks just like what we would
    # replace it with.
    my $faux_line = "*" . $cust_module_name . $module_name .
      $option . " " .$module_options{$option};
    $faux_line =~ tr /A-Z/a-z/;	# Normalize to lower case
    $faux_line =~ s/\s+/ /g;	# Remove extra spaces
    $this_line =~ tr/A-Z/a-z/;	# normalize this line to all lower case.
    $this_line =~ s/\s+/ /g;
    chomp $this_line;
    chomp $faux_line;
    if ($faux_line eq $this_line) {
      print MODULE_FILE;
      next;
    }
    my $new_line = "*${cust_module_name}${proper_name}${option} $module_options{$option}";
    if ($option =~ /Image$/) {
      $rest_of_line =~ s/^\s+//;
      my ($desk, $image) = split /\s+/, $rest_of_line, 2;
      if (exists $module_options{$option}{$desk}) {
        $new_line = "*${cust_module_name}${proper_name}${option} $desk $module_options{$option}{$desk}\n";
      }
    }
    # To get here means that $this_line matches one of the lines
    # specified in the ${THEMES_DIR}/wharf.${THEME_NAME} file
    # So, let's just commend out the line with a message
    print MODULE_FILE "# next line commented out by theme.${THEME_NAME}\n";
    s/^/\#/;
    print MODULE_FILE;	# Send the current line to file commented out
    # Now write the themefied line out..
    print MODULE_FILE $new_line;
  }
    close MODULE_INPUT;
    close MODULE_FILE;
    unlink "$FILE_NAMES{$module_name}.temp" or
      print "Unable to delete $FILE_NAMES{$module_name}.temp, $!\n";
}

sub fix_path {
  # It is possible for images to have a complete path specified in the
  # theme pack.  However, all the images specified in the
  # configuration files have been stored in the theme dir.  Therefore,
  # the specific path that might be specified needs to be stripped
  # off.  This subroutine will return a parameter line that has the
  # path stripped.  It is up to the client to use it instead of the
  # origianl parameter line.

  my $option = shift;
  my $image_file = shift;

  # The first thing to do is make sure this is not the background
  # image for the Pager.  That is the only image allowed to have a
  # path attached.  All others will be deleted.  And, the only
  # path allowed for the DesktopImage is to $NON-CONFIG_DIR.
  if ($option eq "DesktopImage" or $option eq "Image") {
      # These two options will be left alone if they have the default
      # path specified for the image.

    $image_file =~ s!^(.*\/)!!;
    my $path = $1;
    # I don't know how to make Perl grok the '~' when doing file
    # lookups, so let's convert it.
    $path =~ s/^~/$ENV{'HOME'}/;
    if ($path ne "${NONCONFIG_DIR}/") {
      # There is some "non-standard" path specified
      $path = $THEME_DIR;
    } else {
      # The default path is specified, but I need to temporarily
      # remove the leading '/'
      $path = substr $path, 0, -1;
    }
    # now put the image back together...
    $image_file = $path . "/" . $image_file;
  } else {
    # This means we have a "standard" image option and need to
    # strip any possible specifying path off
    $image_file =~ s!^(.*\/)!!;
  }

  # This is dumb, but I need to convert $HOME back to a ~
  $image_file =~ s/^$ENV{'HOME'}/~/;
  return $image_file;
}

sub copy_file {
	my ($source, $target) = @_;
	if (!open(COPY_SOURCE, $source)) {
		warn "Unable to read $source: $!" if ($VERBOSE);
		exit 1;
	}
	if (!open(COPY_TARGET, ">$target")) {
		warn "Unable to write $target: $!" if ($VERBOSE);
		exit 1;
	}
	print COPY_TARGET <COPY_SOURCE>;
	close(COPY_TARGET);
	close(COPY_SOURCE);
}

sub find_or_copy_config_file {
	my ($filename) = @_;
	if (-f "$AFTERSTEP_DIR/$filename") {
		return "$AFTERSTEP_DIR/$filename";
	} elsif (-f "$SHARE_DIR/$filename") {
		warn "Copying $SHARE_DIR/$filename to $AFTERSTEP_DIR/$filename" if ($VERBOSE > 1);
		copy_file("$SHARE_DIR/$filename", "$AFTERSTEP_DIR/$filename");
		return "$AFTERSTEP_DIR/$filename";
	}
	return undef;
}
