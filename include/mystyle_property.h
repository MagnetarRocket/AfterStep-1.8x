#ifndef AS_MYSTYLE_PROPERTY_H
#define AS_MYSTYLE_PROPERTY_H

/*
 * For the MyStyle server (AfterStep):
 * 1. call mystyle_set_property() with the root window, atom name 
 *    "_AS_STYLE", and atom type XA_INTEGER
 *
 * For MyStyle clients (modules):
 * 1. call mystyle_get_property() with the root window, atom name 
 *    "_AS_STYLE", and atom type XA_INTEGER
 * 2. read in any local MyStyle definitions
 * 3. watch for PropertyNotify on the root window
 * 3a. when a PropertyNotify is seen, call mystyle_get_property() as above
 * 3b. update app look as necessary
 *
 * Notes:
 *  o mystyle_get_property() calls mystyle_fix_styles()
 */

void mystyle_set_property (Display * display, Window w, Atom name, Atom type);
void mystyle_get_property (Display * display, Window w, Atom name, Atom type);

#endif /* AS_MYSTYLE_PROPERTY_H */
