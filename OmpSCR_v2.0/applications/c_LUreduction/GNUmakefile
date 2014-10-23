#************************************************************************
#  This GNUmakefile program is part of the
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
# OpenMP Source Code Repository
#
# Application Makefile (to be used with GNUmake)
#
# Dependent on:
#   1) the common rules file: ../../config/commonRules.mk
#   2) the common compiler configuration file: ../../config/templates/user.cf.mk
#
# Copyright (C) 2004, Arturo González Escribano
# Version: 0.2
#

SHELL=/bin/sh
.SUFFIXES:

#
# A. APPLICATION DEVELOPER SECTION
#

# 1. DEFINE YOUR APPLICATION NAMES
#    The name of the main source file, without extension 
#    REMEMBER: .par AND .seq SUFFIXES WILL BE ADDED AUTOMATICALLY
#
EXES=c_lu


# 2. (Optional) DEFINE USER LOCAL FLAGS HERE
CFLAGS=
FFLAGS=
LIBS=

# 3. (Optional) DEFINE COMMON DEPENDENCIES FOR ALL OBJECTIVES
COMMON_DEP=debug_ML.c

# 4. (Optional) EXTRA LOCAL MODULES TO LINK WITH IN C OR FORTRAN
EXTRA_MOD_C=
EXTRA_MOD_F=

# 5. (Optional) RULES TO MAKE THE EXTRA MODULES

# 6. DEBUG ( Default no )
#    To include -DDDEBUG in the compilation line
#	a) Override in command line: $ gmake DEBUG=yes
# 	b) Or uncomment the following line 
# DEBUG=yes

#
# END OF APPLICATION DEVELOPER SECTION 
# (DO NOT MODIFY BELOW THIS POINT, EXCEPT TO OVERRIDE COMMON COMPILER CONFIG)
#

#
# B. COMMON RULES MAKEFILE
#
-include ../../config/commonRules.mk

#
# END
#
