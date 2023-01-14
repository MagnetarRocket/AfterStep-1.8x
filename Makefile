

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

subdirs		= lib asimagelib doc tools src/Config src/afterstep src/asetroot \
		  src/Animate src/Audio \
		  src/Banner src/Cascade src/Clean src/Form src/Gnome \
		  src/Ident \
		  src/Pager src/Save src/Scroll src/Sound src/Tile \
		  src/Wharf \
		  src/WinList src/Zharf src/Script/Widgets src/Script

all:
	@for I in ${subdirs}; do (cd $$I; ${MAKE} $@ || exit 1); done

install: install.data
	@$(MKDIR) -p $(LIBDIR); \
	$(MKDIR) -p $(AFTER_BIN_DIR); \
	$(MKDIR) -p $(AFTER_MAN_DIR); \
	for I in ${subdirs}; do (cd $$I; ${MAKE} install || exit 1); done
 
install.bin:
	@$(MKDIR) -p $(AFTER_BIN_DIR); \
	for I in ${subdirs}; do (cd $$I; ${MAKE} install.bin || exit 1); done

install.lib:
	@$(MKDIR) -p $(LIBDIR); \
	for I in ${subdirs}; do (cd $$I; ${MAKE} install.lib || exit 1); done

install.man:
	@$(MKDIR) -p $(AFTER_MAN_DIR); \
	for I in ${subdirs}; do (cd $$I; ${MAKE} install.man || exit 1); done

install.script:
	@$(MKDIR) -p $(AFTER_BIN_DIR); \
	for I in ${subdirs}; do (cd $$I; ${MAKE} install.script || exit 1); done

install.data:
	@if [ -d /usr/local/share/gnome/wm-properties ] ; then \
	if [ -w /usr/local/share/gnome/wm-properties ] ; then \
	echo $(CP) AfterStep.desktop /usr/local/share/gnome/wm-properties/; \
	$(CP) AfterStep.desktop /usr/local/share/gnome/wm-properties/; \
	else \
	echo "/usr/local/share/gnome/wm-properties exists but is not writable."; \
	echo "If you want AfterStep to appear in your Gnome menu, please install as root."; \
	fi \
	fi
	@if [ -d /usr/share/gnome/wm-properties ] ; then \
	if [ -w /usr/share/gnome/wm-properties ] ; then \
	 echo $(CP) AfterStep.desktop /usr/share/gnome/wm-properties/; \
	 $(CP) AfterStep.desktop /usr/share/gnome/wm-properties/; \
	else \
	echo "/usr/share/gnome/wm-properties exists but is not writable."; \
	echo "If you want AfterStep to appear in your Gnome menu, please install as root."; \
	fi \
	fi
	@if [ -d $(AFTER_SHAREDIR) ] ; then \
	  echo $(RMF) -r $(AFTER_SHAREDIR)_old; \
	  echo $(MV) $(AFTER_SHAREDIR) $(AFTER_SHAREDIR)_old; \
	  $(RMF) -r $(AFTER_SHAREDIR)_old; \
	  $(MV) $(AFTER_SHAREDIR) $(AFTER_SHAREDIR)_old; \
	fi; \
	$(MKDIR) -p $(AFTER_SHAREDIR); \
	$(MKDIR) -p $(AFTER_DOC_DIR)
	$(CP) -r afterstep $(AFTER_SHAREDIR)/../
	$(RMF) $(AFTER_SHAREDIR)/*.in
	$(RMF) $(AFTER_SHAREDIR)/non-configurable/*.in
	$(RMF) $(AFTER_SHAREDIR)/start/.include.in
	$(RMF) $(AFTER_SHAREDIR)/start/Desktop/Feel/.include.in
	$(RMF) $(AFTER_SHAREDIR)/start/Desktop/Look/.include.in
	$(RMF) $(AFTER_SHAREDIR)/start/Desktop/Theme/.include.in
	$(RMF) $(AFTER_SHAREDIR)/start/Desktop/Pictures/.include.in
	$(RMF) $(AFTER_SHAREDIR)/*.orig
	$(RMF) $(AFTER_SHAREDIR)/*/*.orig
	$(RMF) $(AFTER_SHAREDIR)/*/*/*.orig
	$(RMF) $(AFTER_SHAREDIR)/*/*/*/*.orig

uninstall:
	@for I in ${subdirs}; do (cd $$I; ${MAKE} uninstall || exit 1); done
	$(RMF) -r $(AFTER_SHAREDIR)
	@if [ -d $(AFTER_SHAREDIR)_old ] ; then \
	  echo $(MV) $(AFTER_SHAREDIR)_old $(AFTER_SHAREDIR); \
	  $(MV) $(AFTER_SHAREDIR)_old $(AFTER_SHAREDIR); \
	fi

clean:
	@for I in ${subdirs}; do (cd $$I; ${MAKE} clean || exit 1); done

distclean:
	@for I in ${subdirs}; do (cd $$I; ${MAKE} distclean || exit 1); done
	$(RMF) config.cache config.log config.status Makefile.bak Makefile config.h configure.h *.o *~ *% *.bak \#* core

indent:
	for i in ${subdirs}; do ${MAKE} -C $$i indent; done
	@cd include; \
	for i in *.h; do \
	  if (indent < $$i > /tmp/$$i); then \
	    echo indent $$i; \
	    mv /tmp/$$i $$i; \
	  fi; \
	done

deps:
	for I in ${subdirs}; do (cd $$I; touch .depend || exit 1); done; \
	for I in ${subdirs}; do (cd $$I; ${MAKE} deps || exit 1); done

config:
	autoconf --localdir=autoconf autoconf/configure.in > \
	configure ; chmod 755 configure
	autoheader --localdir=autoconf autoconf/configure.in > \
	autoconf/config.h.in ; chmod 644 autoconf/config.h.in

