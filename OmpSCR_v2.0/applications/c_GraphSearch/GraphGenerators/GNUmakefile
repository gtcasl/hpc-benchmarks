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
# Utilities Makefile, to be used with GNUmake
#
# Copyright (C) 2004, Arturo González Escribano
# Version: 1.0
#

SHELL=/bin/sh
.SUFFIXES:

OBJS=fftGraph randomGraph

all: $(OBJS)


# PROGRAM RULES
fftGraph: fftGraph.c
	$(CC) $(CFLAGS) -o $@ $< -lm

randomGraph: randomGraph.c
	$(CC) $(CFLAGS) -o $@ $<


# CLEAN RULE
clean:
	rm -f $(OBJS)


#
# END
#
