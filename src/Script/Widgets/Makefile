OBJS = CheckBox.o HDipstick.o HScrollBar.o ItemDraw.o List.o Menu.o \
       MiniScroll.o PopupMenu.o PushButton.o RadioButton.o Rectangle.o \
       Swallow.o TextField.o Tools.o VDipstick.o VScrollBar.o Widget.o
OBJSDLL         = $(OBJS)

PROG            = libWidgets.a
DYNPROG         = libWidgets.so
LIBVER          = 1.5
LIBVERMAJOR     = 1
#INSTALLONBUILD  = install


#
# Copyright (c) 1998, Guylhem AZNAR <guylhem@oeil.qc.ca>
#


#
# Copyright (c) 1998, Guylhem AZNAR <guylhem@oeil.qc.ca>
#

CC		= gcc
CCFLAGS         =  -O2  -Wall -fPIC
# -march=pentiumpro -mcpu=pentiumpro
EXTRA_DEFINES	= 

RANLIB		= ranlib
AR		= ar clq
CP		= /bin/cp
MV		= /bin/mv
RM		= /bin/rm
RMF		= /bin/rm -f
MKDIR		= /bin/mkdir

YACC		= bison -y
LEX		= flex
YACCFLAGS	= -d
LEXFLAGS	=

INSTALL		= /usr/bin/install -c
INSTALL_PROGRAM	= /usr/bin/install -c -s -m 755
INSTALL_DATA	= /usr/bin/install -c -m 644
INSTALL_LIB	= /usr/bin/install -c -m 755
INSTALL_SCRIPT	= /usr/bin/install -c -m 755

INCS_X		= 
INCS_XPM	= -I/usr/X11/include
INCS_JPEG	= 
INCS_PNG	= -I/usr/X11/include
INCLUDES	= $(INCS_X) $(INCS_XPM) $(INCS_JPEG) $(INCS_PNG)

LIBS_X		= -lXinerama -lXext      -L/usr/X11/lib -lXpm
LIBS_XPM	= 
LIBS_JPEG	= 
LIBS_PNG	= -L/usr/X11/lib -lpng -lz -lm
LIBS_AUDIO	= 
LIBS_XEXTS	= 
LIB_AFTERSTEP	= ../../lib/libafterstep.a  
LIB_ASIMAGE     = ../../asimagelib/libasimage.a 
LIB_WIDGETS     = ../Script/Widgets/libWidgets.a
LIBS_ASIMAGE    = $(LIB_ASIMAGE) $(LIB_AFTERSTEP) $(LIBS_JPEG) $(LIBS_PNG) $(LIBS_XPM)
LIB_ASCONFIG    = ../Config/libasConfig.a
LIBRARIES	= $(LIBS_ASDYN) $(LIBS_XEXTS) $(LIBS_X)

LIBDIR		= $(DESTDIR)/usr/local/lib
AFTER_BIN_DIR	= $(DESTDIR)/usr/local/bin
AFTER_MAN_DIR	= $(DESTDIR)/usr/local/man/man1
AFTER_DOC_DIR	= $(DESTDIR)/usr/local/share/afterstep/doc
AFTER_SHAREDIR	= $(DESTDIR)/usr/local/share/afterstep
GNUSTEP		= ~/GNUstep
GNUSTEPLIB	= ~/GNUstep/Library
AFTER_DIR	= ~/GNUstep/Library/AfterStep
AFTER_SAVE	= ~/GNUstep/Library/AfterStep/.workspace_state
AFTER_NONCF	= ~/GNUstep/Library/AfterStep/non-configurable

#
# End of Make.defines
#

all:            $(PROG) $(INSTALLONBUILD)

install.bin:

install.lib:	$(PROG) 

install.man:

install.script:

install.dyn:
		$(INSTALL_LIB) $(DYNPROG).$(LIBVER) $(LIBDIR)
		-@/bin/rm -f $(LIBDIR)/$(DYNPROG).$(LIBVERMAJOR) $(LIBDIR)/$(DYNPROG)
		ln -sf $(DYNPROG).$(LIBVER) $(LIBDIR)/$(DYNPROG).$(LIBVERMAJOR)
		ln -sf $(DYNPROG).$(LIBVERMAJOR) $(LIBDIR)/$(DYNPROG)
		@( \
		 if test `uname` = "Linux"; then \
		   if test $(LIBDIR) = "/lib" || test $(LIBDIR) = "/usr/lib"; then \
		     echo "" > /dev/null; \
		   elif grep -q $(LIBDIR) /etc/ld.so.conf > /dev/null 2>&1; then \
		     echo "" > /dev/null; \
		   else \
		     echo "Unable to find $(LIBDIR) in ld.so.conf. In order to use "; \
		     echo "$(DYNPROG), you may need to add it or set LD_LIBRARY_PATH."; \
		   fi; \
		   echo "ldconfig"; \
		   ldconfig; \
		 fi \
		)

uninstall.bin:

uninstall.lib:

uninstall.man:

uninstall.script:

clean:
		$(RMF) $(PROG) *.so.* *.so *.o *~ *% *.bak \#* core

distclean:
		$(RMF) $(PROG) *.o *.so.* *~ *% *.bak \#* *.orig core Makefile

indent:
		@SRCS=`echo "$(OBJS) " | sed "s/.o /.c /g"`; \
		if test "x$$SRCS" == "x"; then exit; fi; \
		for i in $$SRCS; do \
		  if (indent < $$i > /tmp/$$i); then \
		    echo "indent $$i"; \
		    mv /tmp/$$i $$i; \
		  fi; \
		done

deps:		
		echo -n > .depend ; \
		buf="" ; \
		for file in `find . -name "*.c"` ; do \
		  if test "x$$buf" != "x"; then \
		      echo $$buf >>.depend ; \
		      echo >>.depend ; \
		  fi; \
		  buf="."`echo $$file | awk -F . '{print $$2}'`".o:" ; \
		  for d in `grep "#include \"" < $$file | awk -F \" '{print $$2}'`; do \
		      if test "x$$buf" != "x"; then \
		         echo $$buf \\ >>.depend ; \
		      fi; \
		      echo -n "        " >>.depend ; \
		      buf="$$d "; \
		  done; \
		done; \
		if test "x$$buf" != "x"; then \
		  echo $$buf >>.depend ; \
		fi

$(PROG):	$(OBJS)
		$(RMF) $(PROG)
		$(AR) $(PROG) $(OBJS)
		$(RANLIB) $(PROG)

.c.o:
		$(CC) $(CCFLAGS) $(EXTRA_DEFINES) $(INCLUDES) $(EXTRA_INCLUDES) -c $*.c

#
# include dependency files if they exist
#
# this is merely a precaution, but as it does not work with ansi make
# we took it out
#ifneq ($(wildcard .depend),)
#include .depend
#endif

$(DYNPROG): $(DYNPROG).$(LIBVERMAJOR)
	ln -sf $(DYNPROG).$(LIBVERMAJOR) $(DYNPROG)

$(DYNPROG).$(LIBVERMAJOR): $(DYNPROG).$(LIBVER)
	ln -sf $(DYNPROG).$(LIBVER) $(DYNPROG).$(LIBVERMAJOR)

$(DYNPROG).$(LIBVER): $(OBJSDLL)
	$(CC) -shared -Wl,-soname,$(DYNPROG).$(LIBVERMAJOR) -o $(DYNPROG).$(LIBVER) \
	 $(OBJSDLL)


install:	install.lib

uninstall:	uninstall.lib
