/*************************************************************************
  This program is part of the
	OpenMP Source Code Repository

	http://www.pcg.ull.es/ompscr/
	e-mail: ompscr@etsii.ull.es

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License 
  (LICENSE file) along with this program; if not, write to
  the Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
  Boston, MA  02111-1307  USA
	
FILE: 		c_loopB.badSolution2.c
VERSION:	1.0
DATE:
AUTHOR:		Arturo González-Escribano
COMMENTS TO:	arturo@infor.uva.es
DESCRIPTION:
		Parallelizing an inner loop with dependences
		Forward dependency (pipeline)

		for (iter=0; iter<numiter; iter++) {
			for (i=0; i<size-1; i++) {
				V[i] = f( V[i], V[i-1] );
			}
		}

		Method: Try parallelization with PARALLEL FOR, 
			adding ORDERED clause
		Result: SEQUENTIAL CODE and NON-CORRECT!!!
COMMENTS:
REFERENCES:
BASIC PRAGMAS:	parallel-for (ordered)
USAGE:		./c_loopB.badSolution2 <size> <numiter>
INPUT:		The array has fixed innitial values:  V[i]=i
OUTPUT:		Compile with -DDDEBUG to see final array values
FILE FORMATS:
RESTRICTIONS:
REVISION HISTORY:
**************************************************************************/
#include<stdio.h>
#include<stdlib.h>
#include<OmpSCR.h>


/* PROTOYPES */
void loop(int, int, int);


/* MAIN: PROCESS PARAMETERS */
int main(int argc, char *argv[]) {
int nthreads, size, numiter;
char *argNames[2] = { "size", "numiter" };
char *defaultValues[2] = { "1000", "100" };
char *timerNames[1] = { "EXE_TIME" };

nthreads = omp_get_max_threads();
OSCR_init( nthreads,
	"Sinthetic loops experiment.",
	NULL,
	2,
	argNames,
	defaultValues,
	1,
	1,
	timerNames,
	argc,
	argv );

/* 1. GET PARAMETERS */
size = OSCR_getarg_int(1);
numiter = OSCR_getarg_int(2);

/* 2. CALL COMPUTATION */
loop(nthreads, size, numiter);

/* 3. REPORT */
OSCR_report();

return 0;
}


/*
* DUMMY FUCNTION
*/
#define f(x,y)	((x+y)/2.0)

/*
*
* PARALLEL LOOP
*
*/
void loop(int nthreads, int size, int numiter) {
/* VARIABLES */
int i,iter;

/* DECLARE VECTOR AND ANCILLARY DATA STRUCTURES */
double *V=NULL;
int totalSize = size*nthreads;

V = (double *)OSCR_calloc(totalSize, sizeof(double));

/* 1. INITIALIZE VECTOR */
for (i=0; i<totalSize; i++) {
	V[i]= 0.0 + i;
	}

/* 2. START TIMER */
OSCR_timer_start(0);

/* 3. ITERATIONS LOOP */
for(iter=0; iter<numiter; iter++) {

	/* 3.1. PROCESS ELEMENTS */
#pragma omp parallel for default(none) shared(V,totalSize) private(i) schedule(static) ordered
	for (i=0; i<totalSize-1; i++) {
		V[i] = f(V[i],V[i-1]);
		}

	/* 3.2. END ITERATIONS LOOP */
	}


/* 4. STOP TIMER */
OSCR_timer_stop(0);

/* 5. WRITE VECTOR (DEBUG) */
#ifdef DEBUG
#include "debug_V.c"
#endif

/* 6. END */
}
