#
# OpenMP Source Code Repository
#
# Application Makefile (to be used with GNUmake)
#
# Dependent on:
#   1) the common rules file: ../../config/commonRules.mk
#   2) the common compiler configuration file: ../../config/templates/user.cf.mk
#

SHELL=/bin/sh
.SUFFIXES:

#
# A. APPLICATION DEVELOPER SECTION
#

# 1. DEFINE YOUR APPLICATION NAMES
#    ( appName_c   FOR APPLICATIONS DERIVED FROM C CODE FILE app.c )
#    ( appName_f90 FOR APPLICATIONS DERIVED FROM Fortran90 CODE FILE app.f90 )
#    ( appName_f95 FOR APPLICATIONS DERIVED FROM Fortran95 CODE FILE app.f95 )
#    REMEMBER: .par AND .seq SUFFIXES WILL BE ADDED AUTOMATICALLY
#
EXES=c_md


# 2. (Optional) DEFINE USER LOCAL FLAGS HERE
CFLAGS=
FFLAGS=
LIBS=-lm

# 3. (Optional) DEFINE COMMON DEPENDENCIES FOR ALL OBJECTIVES
COMMON_DEP=

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
