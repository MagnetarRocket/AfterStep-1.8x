#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <X11/Xlib.h>

#include "../configure.h"
#include "../include/aftersteplib.h"

const char *default_font = "fixed";

/***************************************************************
 * 
 * load a font into a MyFont structure
 * if name == NULL, loads default font
 *
 **************************************************************/
#if defined(LOG_FONT_CALLS) && defined(DEBUG_ALLOCS)
Bool
l_load_font (const char *file, int line, const char *name, MyFont * font)
#else
Bool
load_font (const char *name, MyFont * font)
#endif
{
#ifdef I18N
  char **ml;
  int mc;
  char *ds;
#endif
  Bool success = True;
#if defined(LOG_FONT_CALLS) && defined(DEBUG_ALLOCS)
  log_call (file, line, "load_font", name);
#endif
  if (name == NULL)
    name = default_font;
#ifdef I18N
  /* first try the given name */
  if ((font->fontset = XCreateFontSet (dpy, name, &ml, &mc, &ds)) == NULL)
    {
      char *fn_tmp = NULL;
      fprintf (stderr, "%s: can't get font %s\n", MyName, name);
      fn_tmp = malloc (strlen (name) + strlen (",-*--14-*") + 1);
      strcpy (fn_tmp, name);
      strcat (fn_tmp, ",-*--14-*");
      fprintf (stderr, "Trying... %s\n", fn_tmp);
      /* then try the given name + ",-*--14-*" */
      if (((*font).fontset = XCreateFontSet (dpy, fn_tmp,
					     &ml, &mc, &ds)) == NULL)
	{
	  success = False;
	  /* if we haven't tried the default font yet, try that */
	  if (strcmp (name, default_font) != 0)
	    success = load_font (default_font, font);
	}
      free (fn_tmp);
    }
  if (success == True)
    {
      XFontSetExtents *fset_extents;
      XFontStruct **fs_list;
      XFontsOfFontSet (font->fontset, &fs_list, &ml);
      font->font = fs_list[0];
      if (font->font == NULL)
	{
	  fprintf (stderr, "couldn't get first font in font set!");
	  XFreeFontSet (dpy, font->fontset);
	  return False;
	}
      font->name = mystrdup (name);
      fset_extents = XExtentsOfFontSet (font->fontset);
      font->width = fset_extents->max_logical_extent.width;
      font->height = fset_extents->max_logical_extent.height;
      font->y = font->font->ascent;
    }
#else
  if ((font->font = XLoadQueryFont (dpy, name)) == NULL)
    {
      fprintf (stderr, "%s: can't get font %s\n", MyName, name);
      if ((font->font = XLoadQueryFont (dpy, default_font)) == NULL)
	success = False;
    }
  if (success == True)
    {
      font->name = mystrdup (name);
      font->width = font->font->max_bounds.rbearing + font->font->min_bounds.lbearing;
      font->height = font->font->ascent + font->font->descent;
      font->y = font->font->ascent;
    }
#endif
  return success;
}

/***************************************************************
 *
 * unload a font from a MyFont structure
 *
 **************************************************************/
#if defined(LOG_FONT_CALLS) && defined(DEBUG_ALLOCS)
void
l_unload_font (const char *file, int line, MyFont * font)
#else
void
unload_font (MyFont * font)
#endif
{
#if defined(LOG_FONT_CALLS) && defined(DEBUG_ALLOCS)
  log_call (file, line, "unload_font", font->name);
#endif
  if (font->name != NULL)
    free (font->name);
#ifndef I18N
  if (font->font != NULL)
    XFreeFont (dpy, font->font);
#else /* I18N */
  if (font->fontset != NULL)
    XFreeFontSet (dpy, font->fontset);
  font->fontset = NULL;
#endif /* I18N */
  font->name = NULL;
  font->font = NULL;
}
