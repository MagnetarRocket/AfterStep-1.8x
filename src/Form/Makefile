OBJS		= Form.o

PROG		= Form

LIBS_ASDYN      = $(LIB_AFTERSTEP)
LIBS_DEPEND     = $(LIB_AFTERSTEP)


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

all:            $(PROG)

install.bin:	$(PROG)
		$(INSTALL_PROGRAM) $(PROG) $(AFTER_BIN_DIR)

install.lib:	$(PROG) 

install.man:
		@if test -f $(PROG).man; then \
		  echo $(INSTALL_DATA) $(PROG).man $(AFTER_MAN_DIR)/$(PROG).1x; \
		  $(INSTALL_DATA) $(PROG).man $(AFTER_MAN_DIR)/$(PROG).1x; \
		fi

install.script:
		@for i in $(SCRIPTS); do \
		  echo $(INSTALL_SCRIPT) $$i $(AFTER_BIN_DIR); \
		  $(INSTALL_SCRIPT) $$i $(AFTER_BIN_DIR); \
		done

uninstall.bin:
		$(RMF) $(AFTER_BIN_DIR)/$(PROG)

uninstall.man:
		$(RMF) $(AFTER_MAN_DIR)/$(PROG).1x

uninstall.script:
		@for i in $(SCRIPTS); do \
		  echo $(RMF) $(AFTER_BIN_DIR)/$$i; \
		  $(RMF) $(AFTER_BIN_DIR)/$$i; \
		done

clean:
		$(RMF) $(PROG) *.o *~ *% *.bak \#* core

distclean:
		$(RMF) $(PROG) *.o *~ *% *.bak \#* *.orig core Makefile

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
		for f in `find . -name "*.h"` ; do \
		  if test "x$$buf" != "x"; then \
		      echo $$buf >>.depend ; \
		      echo "" >>.depend ; \
		  fi; \
		  buf="$$f:"; \
		  for d in `grep "#include \"" <$$f | awk -F \" '{print $$2}'`; do \
		      if test "x$$buf" != "x"; then \
		         echo $$buf \\ >>.depend ; \
		      fi; \
		      echo -n "        " >>.depend ; \
		      buf="$$d "; \
		  done; \
		done; \
		if test "x$$buf" != "x"; then \
		  echo $$buf >>.depend ; \
		  buf="" ; \
		  echo "" >>.depend ; \
		fi ; \
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

$(PROG):        $(OBJS) $(LIBS_DEPEND)
		$(CC) $(OBJS) $(LIBRARIES) $(EXTRA_LIBRARIES) -o $(@)

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

../../lib/libafterstep.a:
		cd ../../lib/; ${MAKE}

../../asimagelib/libasimage.a:
		cd ../../asimagelib/; ${MAKE}

../Config/libasConfig.a:
		cd ../Config/; ${MAKE}

../../lib/libafterstep.so:
		cd ../../lib/; ${MAKE}

../../asimagelib/libasimage.so:
		cd ../../asimagelib/; ${MAKE}

../Config/libasConfig.so:
		cd ../Config/; ${MAKE}

#
# End of Make.common
#

install:	install.bin install.man

uninstall:	uninstall.bin uninstall.man
