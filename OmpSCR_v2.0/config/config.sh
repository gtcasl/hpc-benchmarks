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
# OpenMP Source Code Repository
#
# COMPILER CONFIGURATION SCRIPT 
# 	Needs bash(1) or ash(1); and which(1) command
#
# Copyright (C) 2004, Arturo González-Escribano
#
# Version: 0.4
#

#
# USER/BASE CONFIGURATION FILES
#
PREFIX=./config/templates/
CONFIG_SUFFIX=cf.mk
USERCONFIG=$PREFIX/user.$CONFIG_SUFFIX
MKFILES=$PREFIX/*.$CONFIG_SUFFIX

#
# FUNCTIONS FOR QUESTIONING
#
yesno_question() {
	REPLY=""
	while [ "$REPLY" != "y" -a "$REPLY" != "n" ]
	do
		read -p "$1 (y/n) [$2] " REPLY
		REPLY=${REPLY:-"$2"}
	done
	}
free_question() {
	read -p "$1 [$2] " REPLY
	REPLY=${REPLY:-"$2"}
	}
get_from_list() {
	shift $1
	REPLY=$1
	}


#
# MAIN
#
# 1. INTRO
clear
echo
echo "OpenMP Source Code Repository (Makefile Configuration Script)"
echo "-------------------------------------------------------------"
echo

# 2. CHOOSE TEMPLATE
# 2.1. TEMPLATE SELECTION MESSAGES
echo "Choose one template for default values"
if [ -r $USERCONFIG ]
then
	echo "(You may choose \"user\" to modify the previous user-defined configuration)"
fi
echo -------------------------

# 2.2.1. GET LIST OF TEMPLATE NAMES
TEMPLATES=
for name in $(ls $MKFILES)
do
	name=${name%*.$CONFIG_SUFFIX}
	name=${name#$PREFIX/*}
	TEMPLATES="$TEMPLATES $name"
done

# 2.2.2. SHOW LIST OF TEMPLATE NAMES
option_count=0
VALID_ANSWERS=""
default_answer=
for name in $TEMPLATES
do
	option_count=$(($option_count+1))
	echo $option_count")" $name
	VALID_ANSWERS="$VALID_ANSWERS $option_count"

	if [ "$name" = "user" ] ; then default_answer=$option_count ; fi
	if [ "$name" = "none" -a -z "$default_answer" ]
				then default_answer=$option_count ; fi
done

# 2.3. SELECT TEMPLATE
valid_answer="false"
while [ "$valid_answer" = "false" ]
do
	free_question " (choose a number) ? " "$default_answer"
	for name in $VALID_ANSWERS; do
		if [ "$name" = "$REPLY" ] ; then valid_answer="true" ; fi
	done
done
get_from_list $REPLY $TEMPLATES
template=$REPLY


# 2.4. LOAD TEMPLATE
OSCR_USE_C="n"
echo
echo "TEMPLATE: $template"
. $PREFIX/$template.$CONFIG_SUFFIX


# 3. QUESTIONS
# 3.2. C COMPILER QUESTIONS
yesno_question "Do you want to use your OpenMP C compiler?" $OSCR_USE_C
OSCR_USE_C=$REPLY
if [ "$OSCR_USE_C" = "y" ]
then
	# 3.2.1. C COMPILER NAME
	free_question "---- Type the command name to run your OpenMP C compiler" $OSCR_CC
	if which "$REPLY" >/dev/null 2>&1
	then OSCR_CC=$REPLY
	else
		echo
		echo "Error: Cannot find in your PATH the compiler command: $REPLY"
		echo
		exit
	fi

	# 3.2.2. PARALLEL FLAG
	free_question "---- Type flag/s to activate OpenMP parallel directives" $OSCR_C_OMPFLAG
	OSCR_C_OMPFLAG=$REPLY

	# 3.2.3. PARALLELIZATION REPORT
	free_question "---- Type optional flag/s for parallelization reporting" $OSCR_C_REPORT
	OSCR_C_REPORT=$REPLY

	# 3.2.4. SEQUENTIAL FLAG
	free_question "---- Type flag/s for OpenMP stubs (sequential compiling)" $OSCR_C_OMPSTUBSFLAG
	OSCR_C_OMPSTUBSFLAG=$REPLY

	# 3.2.5. OTHERS
	free_question "---- Type any other common flag/s (as optimization flags)" $OSCR_C_OTHERS
	OSCR_C_OTHERS=$REPLY

	# 3.2.6. END C COMPILER QUESTIONS
	echo "----"
fi

# 3.3. C++ COMPILER QUESTIONS
yesno_question "Do you want to use your OpenMP C++ compiler?" $OSCR_USE_CPP
OSCR_USE_CPP=$REPLY
if [ "$OSCR_USE_CPP" = "y" ]
then
	# 3.3.1. C COMPILER NAME
	free_question "---- Type the command name to run your OpenMP C++ compiler" $OSCR_CPPC
	if which "$REPLY" >/dev/null 2>&1
	then OSCR_CPPC=$REPLY
	else
		echo
		echo "Error: Cannot find in your PATH the compiler command: $REPLY"
		echo
		exit
	fi

	# 3.3.2. PARALLEL FLAG
	free_question "---- Type flag/s to activate OpenMP parallel directives" $OSCR_CPP_OMPFLAG
	OSCR_CPP_OMPFLAG=$REPLY

	# 3.3.3. PARALLELIZATION REPORT
	free_question "---- Type optional flag/s for parallelization reporting" $OSCR_CPP_REPORT
	OSCR_CPP_REPORT=$REPLY

	# 3.3.4. SEQUENTIAL FLAG
	free_question "---- Type flag/s for OpenMP stubs (sequential compiling)" $OSCR_CPP_OMPSTUBSFLAG
	OSCR_CPP_OMPSTUBSFLAG=$REPLY

	# 3.3.5. OTHERS
	free_question "---- Type any other common flag/s (as optimization flags)" $OSCR_CPP_OTHERS
	OSCR_CPP_OTHERS=$REPLY

	# 3.3.6. END C++ COMPILER QUESTIONS
	echo "----"
fi

# 3.4. FORTRAN COMPILER QUESTIONS
yesno_question "Do you want to use your OpenMP Fortran90/95 compiler?" $OSCR_USE_F
OSCR_USE_F=$REPLY
if [ "$OSCR_USE_F" = "y" ]
then
	# 3.4.1. FORTRAN COMPILER NAME
	free_question "---- Type the command name to run your OpenMP Fortran90/95 compiler" $OSCR_FF
	if which "$REPLY" >/dev/null 2>&1
	then OSCR_FF=$REPLY
	else
		echo
		echo "Error: Cannot find in your PATH the compiler command: $REPLY"
		echo
		exit
	fi

	# 3.4.2. PARALLEL FLAG
	free_question "---- Type flag/s to activate OpenMP parallel directives" $OSCR_F_OMPFLAG
	OSCR_F_OMPFLAG=$REPLY

	# 3.4.3. PARALLELIZATION REPORT
	free_question "---- Type optional flag/s for parallelization reporting" $OSCR_F_REPORT
	OSCR_F_REPORT=$REPLY

	# 3.4.4. SEQUENTIAL FLAG
	free_question "---- Type flag/s for OpenMP stubs (sequential compiling)" $OSCR_F_OMPSTUBSFLAG
	OSCR_F_OMPSTUBSFLAG=$REPLY

	# 3.4.5. OTHERS
	free_question "---- Type any other common flag/s (as optimization flags)" $OSCR_F_OTHERS
	OSCR_F_OTHERS=$REPLY

	# 3.4.6. END FORTRAN COMPILER QUESTIONS
fi

# 4. CONFIRMATION MESSAGES
echo 
if [ "$OSCR_USE_C" = "y" ]
then
	# 4.1. C CONFIRMATION MESSAGE
	echo "Your C compilation lines will be similar to the following..."
	echo "     Parallel:      $ $OSCR_CC $OSCR_C_OMPFLAG $OSCR_C_REPORT $OSCR_C_OTHERS   -o file   file.c"
	echo "     Sequential:    $ $OSCR_CC $OSCR_C_OMPSTUBSFLAG $OSCR_C_OTHERS   -o file   file.c"
else
	# 4.2. NO USE OF C COMPILER
	echo "No C compiler will be used"
fi
if [ "$OSCR_USE_CPP" = "y" ]
then
	# 4.3. C++ CONFIRMATION MESSAGE
	echo "Your C++ compilation lines will be similar to the following..."
	echo "     Parallel:      $ $OSCR_CPPC $OSCR_CPP_OMPFLAG $OSCR_CPP_REPORT $OSCR_CPP_OTHERS   -o file   file.cpp"
	echo "     Sequential:    $ $OSCR_CPPC $OSCR_CPP_OMPSTUBSFLAG $OSCR_CPP_OTHERS   -o file   file.cpp"
else
	# 4.4. NO USE OF C++ COMPILER
	echo "No C++ compiler will be used"
fi
if [ "$OSCR_USE_F" = "y" ]
then
	# 4.5. FORTRAN CONFIRMATION MESSAGE
	echo "Your FORTRAN 90/95 compilation lines will be similar to the following..."
	echo "     Parallel:      $ $OSCR_FF $OSCR_F_OMPFLAG $OSCR_F_REPORT $OSCR_F_OTHERS   -o file   file.c"
	echo "     Sequential:    $ $OSCR_FF $OSCR_F_OMPSTUBSFLAG $OSCR_F_OTHERS   -o file   file.c"
else
	# 4.6. NO USE OF FORTRAN COMPILER
	echo "No FORTRAN 90/95 compiler will be used"
fi

# 4. CONFIRM CONFIGURATION
echo 
yesno_question "Do you agree?" "y"
if [ "$REPLY" = "y" ]
then
	# IF NO USE OF A GIVEN COMPILER, WE DO NOT LOOSE OLD OPTIONS ANYWAY
	echo "#" > $USERCONFIG
	echo "# OpenMP Source Code Repository" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# COMPILER CONFIGURATION MAKEFILE" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# This file include details about your C and/or Fortran90/95 compilers " >> $USERCONFIG
	echo "# and compilation flags, common to all applications" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "########################################" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# SECTION 1: C COMPILER" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 1.1. C compiler activation" >> $USERCONFIG
	echo "#	A value of \"y\" will enable C source code compilation" >> $USERCONFIG
	echo "#	A value of \"n\" will unable C source code compilation" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_USE_C=$OSCR_USE_C" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 1.2. The name of your C compiler or front-end" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_CC=$OSCR_CC" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 1.3. Flag/s needed to activate OpenMP pragmas recognition" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_C_OMPFLAG=$OSCR_C_OMPFLAG" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 1.4. Flag/s needed for serial compilation (No OpenMP)" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_C_OMPSTUBSFLAG=$OSCR_C_OMPSTUBSFLAG" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 1.5. (Optional)" >> $USERCONFIG
	echo "#	Flags to obtain some report or information about the parallelization" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_C_REPORT=$OSCR_C_REPORT" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 1.6. (Optional) Other common flags (e.g. optimization)" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_C_OTHERS=$OSCR_C_OTHERS" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "########################################" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# SECTION 2: C++ COMPILER" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 2.1. C++ compiler activation" >> $USERCONFIG
	echo "#	A value of \"y\" will enable C++ source code compilation" >> $USERCONFIG
	echo "#	A value of \"n\" will unable C++ source code compilation" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_USE_CPP=$OSCR_USE_CPP" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 2.2. The name of your C++ compiler or front-end" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_CPPC=$OSCR_CPPC" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 2.3. Flag/s needed to activate OpenMP pragmas recognition" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_CPP_OMPFLAG=$OSCR_CPP_OMPFLAG" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 2.4. Flag/s needed for serial compilation (No OpenMP)" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_CPP_OMPSTUBSFLAG=$OSCR_CPP_OMPSTUBSFLAG" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 2.5. (Optional)" >> $USERCONFIG
	echo "#	Flags to obtain some report or information about the parallelization" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_CPP_REPORT=$OSCR_CPP_REPORT" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 2.6. (Optional) Other common flags (e.g. optimization)" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_CPP_OTHERS=$OSCR_CPP_OTHERS" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "########################################" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# SECTION 3: Fortran90/95 COMPILER" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 3.1. Frotran90/95 compiler activation" >> $USERCONFIG
	echo "#	A value of \"y\" will enable Fortran90/95 source code compilation" >> $USERCONFIG
	echo "#	A value of \"n\" will unable Fortran90/95 source code compilation" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_USE_F=$OSCR_USE_F" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 3.2. The name of your Frotran90/95 compiler or front-end" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_FF=$OSCR_FF" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 3.3. Flag/s needed to activate OpenMP pragmas recognition" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_F_OMPFLAG=$OSCR_F_OMPFLAG" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 3.4. Flag/s needed for serial compilation (No OpenMP)" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_F_OMPSTUBSFLAG=$OSCR_F_OMPSTUBSFLAG" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 3.5. (Optional)" >> $USERCONFIG
	echo "#	Flags to obtain some report or information about the parallelization" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_F_REPORT=$OSCR_F_REPORT" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# 3.6. (Optional) Other common flags (e.g. optimization)" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "OSCR_F_OTHERS=$OSCR_F_OTHERS" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "# END OF COMPILER CONFIGURATION MAKEFILE" >> $USERCONFIG
	echo "#" >> $USERCONFIG
	echo "########################################" >> $USERCONFIG
else
	echo
	echo "Keeping previous configuration"
	echo
fi

