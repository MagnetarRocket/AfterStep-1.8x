#include "config.h"

#ifdef __FreeBSD__
#include <sys/syslimits.h>
#else
#include <limits.h>
#endif


/* Maximal length of config. file lines ; attention : the more you define
 * the more memory it uses.  It's safe to leave 255 for long lines.
 */
#define MAXLINELENGTH 1024  /* path could be longer then 255 chars */

			 /* ################### */
			 /* Available libraries */
			 /* ################### */

#define XPM
#define NOJPEG
#define PNG
#define SHAPE
#define HAVE_XINERAMA

#if 1 == 1
#define HAVE_XPM_WRITE
#else
#undef HAVE_XPM_WRITE
#endif


			/* ######################### */
			/* Global configured options */
			/* ######################### */

#define	NO_SGMLTOOLS
#define VERSION		"1.8.11"
#define AFTER_BIN_DIR	"/usr/local/bin"
#define AFTER_MAN_DIR	"/usr/local/man/man1"
#define AFTER_DOC_DIR	"/usr/local/share/afterstep/doc"
#define AFTER_SHAREDIR	"/usr/local/share/afterstep"
#define GNUSTEP         "~/GNUstep"
#define GNUSTEPLIB      "~/GNUstep/Library"
#define AFTER_DIR       "~/GNUstep/Library/AfterStep"
#define AFTER_SAVE      "~/GNUstep/Library/AfterStep/.workspace_state"
#define AFTER_NONCF     "~/GNUstep/Library/AfterStep/non-configurable"
#define AFTER_LOCALE	""

		      /* ############################## */
		      /* In home or share directories : */
		      /* ############################## */

#define START_DIR       "start"
#define BACK_DIR        "backgrounds"
#define LOOK_DIR        "looks"
#define THEME_DIR       "themes"
#define THEME_DATA_DIR  "themefiles"
#define FEEL_DIR        "feels"
#define COMP_FILE	"compatibility"                  /* with -f oldrc */
#define BASE_FILE       "base"                           /* scrdepth */
#define THEME_OVERRIDE_FILE       "theme-override"       
#define BACK_FILE       "non-configurable/%d_background" /* desk */
#define LOOK_FILE       "non-configurable/%d_look.%dbpp" /* desk,scrdepth */
#define FEEL_FILE       "non-configurable/%d_feel.%dbpp" /* desk,scrdepth */
#define THEME_FILE      "non-configurable/%d_theme.%dbpp" /* desk,scrdepth */
#define MENU_FILE	"non-configurable/startmenu"
#define AUTOEXEC_FILE   "autoexec"
#define DATABASE_FILE   "database"

			      /* ############# */
			      /* Look settings */
			      /* ############# */

#define AFTER_XPMDIR    "@xpm_dir@"
#define AFTER_BPMDIR	"@bpm_dir@"
#define XIMAGELOADER    "xli -onroot -quiet -colors 20"
#define SOUNDPLAYER     "play"
#define HELPCOMMAND	"xiterm -e man"
#define DEFAULTSTARTMENUSORT SORTBYALPHA
#define ANIM_STEP       5
#define ANIM_STEP_MAIN  5
#define ANIM_DELAY      2

			      /* ############# */
			      /* Look options  */
			      /* ############# */

#if 0 == 1
#define DIFFERENTLOOKNFEELFOREACHDESKTOP
#else
#undef DIFFERENTLOOKNFEELFOREACHDESKTOP
#endif

#if 1 == 1
#define PAGER_BACKGROUND
#else
#undef PAGER_BACKGROUND
#endif

#if 0 == 1
#define I18N
#else
#undef I18N
#endif

#if 0 == 0
#define NO_WARPPOINTERTOMENU
#else
#undef NO_WARPPOINTERTOMENU
#endif

#if 1 == 1
#undef NO_SAVEWINDOWS
#else
#define NO_SAVEWINDOWS
#endif

#if 1 == 1
#undef NO_TEXTURE
#else
#define NO_TEXTURE
#endif

#if 1 == 1
#undef NO_SHADE
#else
#define NO_SHADE
#endif

#if 1 == 1
#undef NO_VIRTUAL
#else
#define NO_VIRTUAL
#endif

#if 1 == 1
#undef NO_SAVEUNDERS
#else
#define NO_SAVEUNDERS
#endif

#if 1 == 1
#undef NO_WINDOWLIST
#else
#define NO_WINDOWLIST
#endif

#if 1 == 1
#undef NO_AVAILABILITYCHECK
#else
#define NO_AVAILABILITYCHECK
#endif

#if 0 == 1
#define DEBUG_ALLOCS
#else
#undef  DEBUG_ALLOCS
#endif

#if 0 == 1
#define	FIXED_DIR	"fixed"
#else
#undef	FIXED_DIR
#endif

			      /* ############## */
			      /* Action strings */
			      /* ############## */

/* Please don't translate the strings into the language which you use for your
 * pop-up menus since this is default : some decisions about where a function
 * is prohibited (based on mwm-function-hints) is based on a string comparison
 * between the menu item and the strings below
 */

#define MOVE_STRING      "move"
#define RESIZE_STRING1   "size"
#define RESIZE_STRING2   "resize"
#define MINIMIZE_STRING  "minimize"
#define MINIMIZE_STRING2 "iconify"
#define MAXIMIZE_STRING  "maximize"
#define CLOSE_STRING1    "close"
#define CLOSE_STRING2    "delete"
#define CLOSE_STRING3    "destroy"
#define CLOSE_STRING4    "quit"

			/* #################### */
			/* OS dependant defines */
			/* #################### */

/* Really, no one but me should need this */
/* #define BROKEN_SUN_HEADERS */

/* Some logical checks */
#ifdef HAVE_UNAME
#undef HAVE_GETHOSTNAME
#endif

/* Even if limits.h is included, allow PATH_MAX to sun unices */
#ifndef PATH_MAX
#ifdef _POSIX_PATH_MAX
#define PATH_MAX _POSIX_PATH_MAX
#else
#define PATH_MAX 255
#endif
#endif

/* Allows gcc users to use inline, doesn't cause problems for others. */
#ifndef __GNUC__
#define  AFTER_INLINE  /* nothing */
#else
#if defined(__GNUC__) && !defined(inline)
#define AFTER_INLINE __inline__
#else
#define AFTER_INLINE inline
#endif /* __GNUC__ && !(inline) */
#endif /* !(__GNUC__) */

