#************************************************************************
#  This program is part of the
#	OpenMP Source Code Repository
#
#	http://www.pcg.ull.es/OmpSCR/
#	e-mail: ompscr@zion.deioc.ull.es
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License 
#  (LICENSE file) along with this program; if not, write to
#  the Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
#  Boston, MA  02111-1307  USA
#
#*************************************************************************
#
# OpenMP source Code Repository
#
# Common modules Makefile (to be used with GNUmake)
#
# Dependent on:
#	1) the common compiler configuration file: ../config/user.cf.mk
#
# Copyright (C) 2004, Arturo González Escribano
#

SHELL=/bin/sh
.SUFFIXES:

# 1. LOCAL FLAGS
CFLAGS=-I../include
CPPFLAGS=-I../include
FFLAGS=-I../include

# 2. MODULE NAMES
OBJS=ompscrCommon_f.o wtime_f.o ompscrCommon_c.o wtime_c.o ompscrCommon_cpp.o wtime_cpp.o   

# 3. COMMON DEPENDENCIES FOR ALL OBJECTIVES (IF NEEDED)
COMMON_DEP=

# 4. DEBUG ( Default no )
#	Override with command line: $ make DEBUG=yes
# 	Or uncomment the following line 
# DEBUG=yes

ifeq ($(DEBUG), yes)
	CFLAGS +=-g -DDEBUG
      CPPFLAGS +=-g -DDEBUG
endif

#
# 5. LOAD COMPILER CONFIGURATION
#
OSCR_USE_C="n"
OSCR_USE_CPP="n"
OSCR_USE_F="n"

-include ../config/templates/user.cf.mk

#
# 6. BUILD ANYTHING FOR: par OR seq OR all RULES
#	(Move .mod files to ../include directory if they are generated)
#	(Build the library)
#
.PHONY: all par seq
all: $(OBJS)
ifeq ($(OSCR_USE_F), y)
	cp *.mod ../include
endif

par: $(OBJS)
ifeq ($(OSCR_USE_F), y)
	cp *.mod ../include
endif

seq: $(OBJS)
ifeq ($(OSCR_USE_F), y)
	cp *.mod ../include
endif


#
# 7. IMPLICIT RULES FOR C MODULES COMPILATION
#
ifeq ($(OSCR_USE_C), y)
CC=$(OSCR_CC)
CFLAGS+=$(OSCR_C_OTHERS)

%_c.o : %.c 
	$(CC) $(CFLAGS) -c -o $@ $<

else

%_c.o : %.c 
	@echo "There is not a C OpenMP compiler to build $@"

endif

#
# 8. IMPLICIT RULES FOR C++ MODULES COMPILATION
#
ifeq ($(OSCR_USE_CPP), y)
CPPC=$(OSCR_CPPC)
CPPFLAGS+=$(OSCR_CPP_OTHERS)

%_cpp.o : %.cpp 
	$(CPPC) $(CPPFLAGS) -c -o $@ $<

else

%_cpp.o : %.cpp 
	@echo "There is not a C++ OpenMP compiler to build $@"

endif


#
# 9. IMPLICIT RULES FOR FORTRAN 90/95 MODULES COMPILATION
#
ifeq ($(OSCR_USE_F), y)
FC=$(OSCR_FF)
FFLAGS+=$(OSCR_F_OTHERS)

%_f.o : %.f90
	$(FC) $(FFLAGS) -c -o $@ $<
%_f.o : %.f95
	$(FC) $(FFLAGS) -c -o $@ $<

else

%_f.o : %.f90 
	@echo "There is not a Fortran90/95 OpenMP compiler defined to build $@"
%_f.o : %.f95
	@echo "There is not a Fortran90/95 OpenMP compiler defined to build $@"

endif

#
# CLEAN RULE
#
.PHONY: clean
clean:
	rm -f $(OBJS)
	rm -f ../include/*.mod ./*.mod

#
# END
#
