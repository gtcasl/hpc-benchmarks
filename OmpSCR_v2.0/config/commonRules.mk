#************************************************************************
#  This GNUmakefile program is part of the
#	OpenMP Source Code Repository
#
#	http://www.pcg.ull.es/OmpSCR/
#	e-mail: ompscr@etsii.deioc.ull.es
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
# OpenMP Source Code Repository
#
# Common rules Makefile 
#
# Dependent on the common compiler configuration file: 
# 					../config/templates/user.cf.mk
#
# Copyright (C) 2004, Arturo González-Escribano
#
# Version: 0.2.1
#

#
# 0. OTHER CONFIGURABLE DETAILS
#

# Directory to store executable files
OUTPUTDIR=../../bin

# Directory to store log files about compilation 
LOGDIR=../../log

# Suffix of a log file containing the specific compilation line for a program
COMPLINE_SUFFIX=compLine

# Flag to find the common include files
INCLUDE_FLAGS=-I../../include

# Common objects to be linked with any application
COMMON_C=../../common/ompscrCommon_c.o ../../common/wtime_c.o
COMMON_CPP=../../common/ompscrCommon_cpp.o ../../common/wtime_cpp.o
COMMON_F=../../common/ompscrCommon_f.o ../../common/wtime_f.o

#
# 1. PAR, SEQ, ALL OBJECTIVE NAMES
#
PAR=$(foreach name, $(EXES), $(OUTPUTDIR)/$(name).par )
SEQ=$(foreach name, $(EXES), $(OUTPUTDIR)/$(name).seq )
ALL=$(PAR) $(SEQ)

#
# 2. DEBUG 
#
ifeq ($(DEBUG), yes)
	CFLAGS +=-g -DDEBUG
	CPPFLAGS +=-g -DDEBUG
endif

#
# 3. BUILD PAR OR SEQ RULES
#
.PHONY: all par seq
all: $(ALL)
	@echo
	@echo "Compilation command line for each application has been stored in ./log directory"
	@echo

par: $(PAR)
	@echo
	@echo "Compilation command line for each application has been stored in ./log directory"
	@echo

seq: $(SEQ)
	@echo
	@echo "Compilation command line for each application has been stored in ./log directory"
	@echo

#
# 3. LOAD CONFIGURATION
#
OSCR_USE_C="n"
OSCR_USE_CPP="n"
OSCR_USE_F="n"

-include ../../config/templates/user.cf.mk

#
# 4. IMPLICIT RULES FOR C PARALLEL AND SEQUENTIAL COMPILATION
#
ifeq ($(OSCR_USE_C), y)

CC=$(OSCR_CC)
CPARFLAGS=$(OSCR_C_OMPFLAG) $(OSCR_C_REPORT) $(OSCR_C_OTHERS)
CSEQFLAGS=$(OSCR_C_OMPSTUBSFLAG) $(OSCR_C_OTHERS)

$(OUTPUTDIR)/%.par : %.c $(COMMON_DEP) $(EXTRA_MOD_C) $(COMMON_C)
	@ echo "$(CC) $(CPARFLAGS) $(CFLAGS) $(INCLUDE_FLAGS) -o $@ $< $(EXTRA_MOD_C) $(COMMON_C) $(LIBS)" > $(LOGDIR)/$*.par.$(COMPLINE_SUFFIX)
	$(CC) $(CPARFLAGS) $(CFLAGS) $(INCLUDE_FLAGS) -o $@ $< $(EXTRA_MOD_C) $(COMMON_C) $(LIBS)
	
$(OUTPUTDIR)/%.seq : %.c $(COMMON_DEP) $(EXTRA_MOD_C) $(COMMON_C)
	@ echo "$(CC) $(CSEQFLAGS) $(CFLAGS) $(INCLUDE_FLAGS) -o $@ $< $(EXTRA_MOD_C) $(COMMON_C) $(LIBS)" > $(LOGDIR)/$*.seq.$(COMPLINE_SUFFIX)
	$(CC) $(CSEQFLAGS) $(CFLAGS) $(INCLUDE_FLAGS) -o $@ $< $(EXTRA_MOD_C) $(COMMON_C) $(LIBS)

else

$(OUTPUTDIR)/%.par : %.c 
	@echo "There is not a C OpenMP compiler to build $@"

$(OUTPUTDIR)/%.seq : %.c
	@echo "There is not a C OpenMP compiler to build $@"

endif

#
# 5. IMPLICIT RULES FOR C++ PARALLEL AND SEQUENTIAL COMPILATION
#
ifeq ($(OSCR_USE_CPP), y)

CPPC=$(OSCR_CPPC)
CPPPARFLAGS=$(OSCR_CPP_OMPFLAG) $(OSCR_CPP_REPORT) $(OSCR_CPP_OTHERS)
CPPSEQFLAGS=$(OSCR_CPP_OMPSTUBSFLAG) $(OSCR_CPP_OTHERS)

$(OUTPUTDIR)/%.par : %.cpp $(COMMON_DEP) $(EXTRA_MOD_CPP) $(COMMON_CPP)
	@ echo "$(CPPC) $(CPPPARFLAGS) $(CPPFLAGS) $(INCLUDE_FLAGS) -o $@ $< $(EXTRA_MOD_CPP) $(COMMON_CPP) $(LIBS)" > $(LOGDIR)/$*.par.$(COMPLINE_SUFFIX)
	$(CPPC) $(CPPPARFLAGS) $(CPPFLAGS) $(INCLUDE_FLAGS) -o $@ $< $(EXTRA_MOD_CPP) $(COMMON_CPP) $(LIBS)
	
$(OUTPUTDIR)/%.seq : %.cpp $(COMMON_DEP) $(EXTRA_MOD_CPP) $(COMMON_CPP)
	@ echo "$(CPPC) $(CPPSEQFLAGS) $(CPPFLAGS) $(INCLUDE_FLAGS) -o $@ $< $(EXTRA_MOD_CPP) $(COMMON_CPP) $(LIBS)" > $(LOGDIR)/$*.seq.$(COMPLINE_SUFFIX)
	$(CPPC) $(CPPSEQFLAGS) $(CPPFLAGS) $(INCLUDE_FLAGS) -o $@ $< $(EXTRA_MOD_CPP) $(COMMON_CPP) $(LIBS)

else

$(OUTPUTDIR)/%.par : %.cpp 
	@echo "There is not a C++ OpenMP compiler to build $@"

$(OUTPUTDIR)/%.seq : %.cpp
	@echo "There is not a C++ OpenMP compiler to build $@"

endif

#
# 6. IMPLICIT RULES FOR FORTRAN 90/95 PARALLEL AND SEQUENTIAL COMPILATION
#
ifeq ($(OSCR_USE_F), y)

FC=$(OSCR_FF)
FPARFLAGS=$(OSCR_F_OMPFLAG) $(OSCR_F_REPORT) $(OSCR_F_OTHERS)
FSEQFLAGS=$(OSCR_F_OMPSTUBSFLAG) $(OSCR_F_OTHERS)

$(OUTPUTDIR)/%.par : %.f90 $(COMMON_DEP) $(EXTRA_MOD_F) $(COMMON_F)
	@ echo "$(FC) $(FPARFLAGS) $(FFLAGS) $(INCLUDE_FLAGS) -o $@ $< $(EXTRA_MOD_F) $(COMMON_F) $(LIBS)" > $(LOGDIR)/$*.par.$(COMPLINE_SUFFIX)
	$(FC) $(FPARFLAGS) $(FFLAGS) $(INCLUDE_FLAGS) -o $@ $< $(EXTRA_MOD_F) $(COMMON_F) $(LIBS)

$(OUTPUTDIR)/%.par : %.f95 $(COMMON_DEP) $(EXTRA_MOD_F) $(COMMON_F)
	@ echo "$(FC) $(FPARFLAGS) $(FFLAGS) $(INCLUDE_FLAGS) -o $@ $< $(EXTRA_MOD_F) $(COMMON_F) $(LIBS)" > $(LOGDIR)/$*.par.$(COMPLINE_SUFFIX)
	$(FC) $(FPARFLAGS) $(FFLAGS) $(INCLUDE_FLAGS) -o $@ $< $(EXTRA_MOD_F) $(COMMON_F) $(LIBS)

$(OUTPUTDIR)/%.seq : %.f90 $(COMMON_DEP) $(EXTRA_MOD_F) $(COMMON_F)
	@ echo "$(FC) $(FSEQFLAGS) $(FFLAGS) $(INCLUDE_FLAGS) -o $@ $< $(EXTRA_MOD_F) $(COMMON_F) $(LIBS)" > $(LOGDIR)/$*.seq.$(COMPLINE_SUFFIX)
	$(FC) $(FSEQFLAGS) $(FFLAGS) $(INCLUDE_FLAGS) -o $@ $< $(EXTRA_MOD_F) $(COMMON_F) $(LIBS)

$(OUTPUTDIR)/%.seq : %.f95 $(COMMON_DEP) $(EXTRA_MOD_F) $(COMMON_F)
	@ echo "$(FC) $(FSEQFLAGS) $(FFLAGS) $(INCLUDE_FLAGS) -o $@ $< $(EXTRA_MOD_F) $(COMMON_F) $(LIBS)" > $(LOGDIR)/$*.seq.$(COMPLINE_SUFFIX)
	$(FC) $(FSEQFLAGS) $(FFLAGS) $(INCLUDE_FLAGS) -o $@ $< $(EXTRA_MOD_F) $(COMMON_F) $(LIBS)

else

$(OUTPUTDIR)/%.par : %.f90 
	@echo "There is not a Fortran90/95 OpenMP compiler defined to build $@"
$(OUTPUTDIR)/%.par : %.f95
	@echo "There is not a Fortran90/95 OpenMP compiler defined to build $@"

$(OUTPUTDIR)/%.seq : %.f90
	@echo "There is not a Fortran90/95 OpenMP compiler defined to build $@"
$(OUTPUTDIR)/%.seq : %.f95
	@echo "There is not a Fortran90/95 OpenMP compiler defined to build $@"

endif

#
# RULES TO RECOMPILE COMMON MODULES IF NEEDED
#
$(COMMON_C): ../../common/*.c ../../include/*.h
	gmake -C ../../common DEBUG=$(DEBUG) all

$(COMMON_CPP): ../../common/*.cpp ../../include/*.h
	gmake -C ../../common DEBUG=$(DEBUG) all

$(COMMON_F): ../../common/*.f90
	gmake -C ../../common DEBUG=$(DEBUG) all

#
# CLEAN RULE
#
.PHONY: clean
clean:
	$(foreach name, $(ALL), rm -f $(name); )
	$(foreach name, $(EXES), rm -f $(LOGDIR)/$(name).par.$(COMPLINE_SUFFIX); )
	$(foreach name, $(EXES), rm -f $(LOGDIR)/$(name).seq.$(COMPLINE_SUFFIX); )
ifneq ($(EXTRA_MOD_C),)
	rm -f $(EXTRA_MOD_C) 
endif
ifneq ($(EXTRA_MOD_CPP),)
	rm -f $(EXTRA_MOD_CPP) 
endif
ifneq ($(EXTRA_MOD_F),)
	rm -f $(EXTRA_MOD_F)
endif

