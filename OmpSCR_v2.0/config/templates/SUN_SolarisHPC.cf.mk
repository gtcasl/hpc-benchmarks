#
# OpenMP Source Code Repository
#
# COMPILER CONFIGURATION MAKEFILE
#
# This file include details about your C and/or Fortran90/95 compilers 
# and compilation flags, common to all applications
#


########################################
#
# SECTION 1: C COMPILER
#

#
# 1.1. C compiler activation
#	A value of "y" will enable C source code compilation
#	A value of "n" will unable C source code compilation
#
OSCR_USE_C=y

#
# 1.2. The name of your C compiler or front-end
#
OSCR_CC=cc

#
# 1.3. Flag/s needed to activate OpenMP pragmas recognition
#
OSCR_C_OMPFLAG=-xopenmp

#
# 1.4. Flag/s needed for serial compilation (No OpenMP)
#
OSCR_C_OMPSTUBSFLAG=-xopenmp_stubs

#
# 1.5. (Optional)
#	Flags to obtain some report or information about the parallelization
#
OSCR_C_REPORT=-loopinfo

#
# 1.6. (Optional) Other common flags (e.g. optimization)
#
OSCR_C_OTHERS=



########################################
#
# SECTION 2: Fortran90/95 COMPILER
#

#
# 1.1. Frotran90/95 compiler activation
#	A value of "y" will enable Fortran90/95 source code compilation
#	A value of "n" will unable Fortran90/95 source code compilation
#
OSCR_USE_F=y

#
# 1.2. The name of your Frotran90/95 compiler or front-end
#
OSCR_FF=f95

#
# 1.3. Flag/s needed to activate OpenMP pragmas recognition
#
OSCR_F_OMPFLAG=-openmp

#
# 1.4. Flag/s needed for serial compilation (No OpenMP)
#
OSCR_F_OMPSTUBSFLAG=-openmp_stubs

#
# 1.5. (Optional)
#	Flags to obtain some report or information about the parallelization
#
OSCR_F_REPORT=-loopinfo

#
# 1.6. (Optional) Other common flags (e.g. optimization)
#
OSCR_F_OTHERS=



#
# END OF COMPILER CONFIGURATION MAKEFILE
#
########################################
