#
# OpenMP Source Code Repository
#
# General Makefile (To be processed by GNUmake)
#
# (c) 2004, Arturo Gonzalez Escribano
#
# Version: 0.3
#

# VERSION
OSCR_VERSION=2.0

# GENERAL CONVENTIONS
SHELL=/bin/sh
.SUFFIXES:

# PHONY TARGETS
.PHONY: help config all par seq clean distclean dist

#
# INFO
#
help:
	@echo
	@echo "        Welcome to OpenMP Repository v$(OSCR_VERSION) !!!"
	@echo
	@echo "Usage:"
	@echo
	@echo " gmake config     - Information about how to configure your compiler details"
	@echo " gmake bashconfig - Interactive compilers configuration (bash shell)" 
	@echo " gmake ashconfig  - Interactive compilers configuration (ash shell)" 
	@echo
	@echo " gmake all        - Will build all the versions of each application"
	@echo " gmake seq        - Will build only the sequential versions of applications"
	@echo " gmake par        - Will build only the parallel versions of applications"
	@echo
	@echo " gmake clean      - Will remove the applications"
	@echo " gmake distclean  - Will remove applications and compiler configuration"
	@echo " gmake help       - Show this help"
	@echo


# 
# CONFIGURATION SCRIPT
#
config:
	@echo
	@echo OpenMP Repository compilers configuration...
	@echo
	@echo "To configure the makefiles to use your compilers and options,"
	@echo "please, edit the file:"
	@echo "                ./config/templates/user.cf.mk"
	@echo
	@echo "There are more templates for specific plattforms in"
	@echo " ./config/templates"
	@echo "You may copy one of them as 'user.cf.mk' and adapt it"
	@echo
	@echo "Alternatively, if you have a bash(1) or ash(1) shell, you may use an"
	@echo "interactive configuration script. Try: "
	@echo " > gmake bashconfig"
	@echo " > gmake ashconfig"
	@echo

bashconfig:
	@bash ./config/config.sh

ashconfig:
	@ash ./config/config.sh

#
# DEBUG ( Default no, override with command line: $ gmake DEBUG=yes )
#
DEBUG=no


#
# DEFINE ALL OBJECTIVES (APPLICATION SUBDIRS)
#
ALL=common $(filter-out applications/CVS, $(wildcard applications/*))

#
# BUILD ONLY PARALLEL BINARIES
#
par:
	@ $(foreach dir, $(ALL), gmake -C $(dir) DEBUG=$(DEBUG) par; )
	@echo
	@echo "Compilation command line for each application has been stored in ./log directory"
	@echo

#
# BUILD ONLY SEQUENTIAL BINARIES
#
seq:
	@ $(foreach dir, $(ALL), gmake -C $(dir) DEBUG=$(DEBUG) seq; )
	@echo
	@echo "Compilation command line for each application has been stored in ./log directory"
	@echo

#
# BUILD ALL RULE
#
all:
	@ $(foreach dir, $(ALL), gmake -C $(dir) DEBUG=$(DEBUG) all; )
	@echo
	@echo "Compilation command line for each application has been stored in ./log directory"
	@echo


#
# CLEAN RULES
#
clean:
	@ $(foreach dir, $(ALL), gmake -C $(dir) clean; )

distclean:
	@ $(foreach dir, $(ALL), gmake -C $(dir) clean; )
	cp ./config/templates/none.cf.mk ./config/templates/user.cf.mk

#
# CREATE DISTRIBUTION FILE RULE
#
DIST_NAME=OmpSCR_v$(OSCR_VERSION)
dist:
#	@ gmake clean
#	rm -f ./OmpSCR_v$(OSCR_VERSION).tar.gz
#	tar cpf ./OmpSCR_v$(OSCR_VERSION).tar *
#	gzip OmpSCR_v$(OSCR_VERSION).tar

	@ gmake clean
	rm -f ./OmpSCR_v$(OSCR_VERSION).tar.gz
	ln -s `pwd` ./$(DIST_NAME)
	tar cphf ./$(DIST_NAME).tar --exclude=./$(DIST_NAME)/$(DIST_NAME) ./$(DIST_NAME)
	gzip OmpSCR_v$(OSCR_VERSION).tar
	rm -f ./$(DIST_NAME)
						  


