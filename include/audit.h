#ifndef AFTERSTEP_AUDIT_H
#define AFTERSTEP_AUDIT_H

/*
 * This code is a (hopefully) nearly transparent way to keep track of 
 * memory allocations and deallocations, to make finding memory leaks 
 * easier.  GCC is required (for the __FUNCTION__ preprocessor macro).
 *
 * To use it, define DEBUG_ALLOCS before including this header, and call 
 * print_unfreed_mem() whenever an audit is desired, like so:
 *
 * #ifdef DEBUG_ALLOCS
 * print_unfreed_mem();
 * #endif 
 */

#ifdef DEBUG_ALLOCS

void log_call (const char *fname, int line, const char *call_name, const char *sparam);

#define malloc(a) countmalloc(__FUNCTION__, __LINE__, a)
#define safemalloc(a) countmalloc(__FUNCTION__, __LINE__, a)
#define calloc(a, b) countcalloc(__FUNCTION__, __LINE__, a, b)
#define realloc(a, b) countrealloc(__FUNCTION__, __LINE__, a, b)
#define free(a) countfree(__FUNCTION__, __LINE__, a)

void *countmalloc (const char *fname, int line, size_t length);
void *countcalloc (const char *fname, int line, size_t nrecords, size_t length);
void *countrealloc (const char *fname, int line, void *ptr, size_t length);
void countfree (const char *fname, int line, void *ptr);

#define XCreatePixmap(a, b, c, d, e) count_xcreatepixmap(__FUNCTION__, __LINE__, a, b, c, d, e)
#define XCreateBitmapFromData(a, b, c, d, e) count_xcreatebitmapfromdata(__FUNCTION__, __LINE__, a, b, c, d, e)
#define XCreatePixmapFromBitmapData(a, b, c, d, e, f, g, h) count_xcreatepixmapfrombitmapdata(__FUNCTION__, __LINE__, a, b, c, d, e, f, g, h)
#define XpmReadFileToPixmap(a, b, c, d, e, f) count_xpmreadfiletopixmap(__FUNCTION__, __LINE__, a, b, c, d, e, f)
#define XFreePixmap(a, b) count_xfreepixmap(__FUNCTION__, __LINE__, a, b)

Pixmap count_xcreatepixmap (const char *fname, int line, Display * display, Drawable drawable, unsigned int width, unsigned int height, unsigned int depth);
Pixmap count_xcreatebitmapfromdata (const char *fname, int line, Display * display, Drawable drawable, char *data, unsigned int width, unsigned int height);
Pixmap count_xcreatepixmapfrombitmapdata (const char *fname, int line, Display * display, Drawable drawable, char *data, unsigned int width, unsigned int height, unsigned long fg, unsigned long bg, unsigned int depth);
int count_xpmreadfiletopixmap (const char *fname, int line, Display * display, Drawable drawable, char *filename, Pixmap * pmap, Pixmap * mask, void *attributes);
int count_xfreepixmap (const char *fname, int line, Display * display, Pixmap pmap);

#define XCreateGC(a, b, c, d) count_xcreategc(__FUNCTION__, __LINE__, a, b, c, d)
#define XFreeGC(a, b) count_xfreegc(__FUNCTION__, __LINE__, a, b)

GC count_xcreategc (const char *fname, int line, Display * display, Drawable drawable, unsigned int mask, XGCValues * values);
int count_xfreegc (const char *fname, int line, Display * display, GC gc);

#undef XDestroyImage		/* this is normally a macro */

#define XCreateImage(a, b, c, d, e, f, g, h, i, j) count_xcreateimage(__FUNCTION__, __LINE__, a, b, c, d, e, f, g, h, i, j)
#define XGetImage(a, b, c, d, e, f, g, h) count_xgetimage(__FUNCTION__, __LINE__, a, b, c, d, e, f, g, h)
#define XpmCreateImageFromXpmImage(a, b, c, d, e) count_xpmcreateimagefromxpmimage(__FUNCTION__, __LINE__, a, b, c, d, e)
#define XDestroyImage(a) count_xdestroyimage(__FUNCTION__, __LINE__, a)

XImage *count_xcreateimage (const char *fname, int line, Display * display, Visual * visual, unsigned int depth, int format, int offset, char *data, unsigned int width, unsigned int height, int bitmap_pad, int byte_per_line);
XImage *count_xgetimage (const char *fname, int line, Display * display, Drawable drawable, int x, int y, unsigned int width, unsigned int height, unsigned long plane_mask, int format);
int count_xpmcreateimagefromxpmimage (const char *fname, int line, Display * display, void *xpm_image, XImage ** image, XImage ** mask, void *attributes);
int count_xdestroyimage (const char *fname, int line, XImage * image);

#define XGetWindowProperty(a, b, c, d, e, f, g, h, i, j, k, l) count_xgetwindowproperty(__FUNCTION__, __LINE__, a, b, c, d, e, f, g, h, i, j, k, l)
#define XQueryTree(a, b, c, d, e, f) count_xquerytree(__FUNCTION__, __LINE__, a, b, c, d, e, f)
#define XGetWMHints(a, b) count_xgetwmhints(__FUNCTION__, __LINE__, a, b)
#define XGetWMProtocols(a, b, c, d) count_xgetwmprotocols(__FUNCTION__, __LINE__, a, b, c, d)
#define XGetWMName(a, b, c) count_xgetwmname(__FUNCTION__, __LINE__, a, b, c)
#define XGetClassHint(a, b, c) count_xgetclasshint(__FUNCTION__, __LINE__, a, b, c)
#define XGetAtomName(a, b) count_xgetatomname(__FUNCTION__, __LINE__, a, b)
#define XStringListToTextProperty(a, b, c) count_xstringlisttotextproperty(__FUNCTION__, __LINE__, a, b, c)
#define XFree(a) count_xfree(__FUNCTION__, __LINE__, a)

int count_xgetwindowproperty (const char *fname, int line, Display * display, Window w, Atom property, long long_offset, long long_length, Bool delete, Atom req_type, Atom * actual_type_return, int *actual_format_return, unsigned long *nitems_return, unsigned long *bytes_after_return, unsigned char **prop_return);
Status count_xquerytree (const char *fname, int line, Display * display, Window w, Window * root_return, Window * parent_return, Window ** children_return, unsigned int *nchildren_return);
void *count_xgetwmhints (const char *fname, int line, Display * display, Window w);
Status count_xgetwmprotocols (const char *fname, int line, Display * display, Window w, void *protocols_return, int *count_return);
Status count_xgetwmname (const char *fname, int line, Display * display, Window w, void *text_prop_return);
Status count_xgetclasshint (const char *fname, int line, Display * display, Window w, void *class_hints_return);
char *count_xgetatomname (const char *fname, int line, Display * display, Atom atom);
Status count_xstringlisttotextproperty (const char *fname, int line, char **list, int count, void *text_prop_return);
int count_xfree (const char *fname, int line, void *data);

void print_unfreed_mem (void);

#endif /* DEBUG_ALLOCS */

#endif /* AFTERSTEP_AUDIT_H */
