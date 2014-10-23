/************************************************************************
  This program is part of the
	OpenMP Source Code Repository

	http://www.pcg.ull.es/OmpSCR/
	e-mail: ompscr@zion.deioc.ull.es

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

  --------------------------------------------------------------------
  fftGraph.c
 
  version 1.0

  Generates graphs in .gph format which represents the task graph of
  a parallel FFT computation with "n" communication stages

  Copyright (C) 2004, Arturo González-Escribano
 
**************************************************************************/
#include<math.h>
#include<stdio.h>

int main(int argc, char *argv[]) {
	int jump = 1;
	int stages;
	int procs;
	int tasks;
	int i,j;
	int check=0;

	/* 1. READ ARGUMENTS */
	if (argc != 2) {
		fprintf(stderr,"\nUsage: fftGraph <num_comm_stages>\n\n");
		exit(1);
		}
	check = sscanf(argv[1], "%d", &stages);
	if (check != 1 || stages < 1) {
		fprintf(stderr,"\nError in parameter!!\nUsage: fftGraph <num_comm_stages>\n\n");
		exit(1);
		}

	/* 2. COMPUTE NUMBER OF PROCESSORS AND TOTAL NUMBER OF TASKS */
	procs = (int)pow( 2.0, (double)stages );
	tasks = procs * stages + procs;

	/* 3. WRITE HEADER */
	printf("#\n# Parallel FFT computation\n");
	printf("#\t%d processors, %d stages\n#\n", procs, stages+1);
	printf("T: %d\n", tasks);
	printf("R: 0\n");

	 /* 4. FOR EACH STAGE */
	for (i=0; i<stages; i++) {
		/* 4.1. FOR EACH PROCESSOR */
		for (j=0; j<procs; j++) {
			/* 4.1.1. COMPUTE MY NUMBER AND THE NEXT TASK ON
				THE SAME PROCESSOR */
			int mytask = i*procs + j;
			int nexttask = mytask + procs;

			/* 4.1.2. WRITE NUMBER OF TASK AND SUCCESSORS */
			printf("t%d: s2: ", mytask);

			/* 4.1.3. WRITE NEXT TASK ON THE SAME PROCESSOR */
			printf("%d ", nexttask);

			/* 4.1.4. WRITE THE PARTNER TASK ON NEXT STAGE */
			if ( j % (jump*2) < jump ) 
				printf("%d\n", nexttask + jump);
			else
				printf("%d\n", nexttask - jump);
			}
		/* 4.2. INCREASE JUMP FOR THE NEXT STAGE */
		jump = jump << 1;
		}

	/* 5. LAST STAGE TASKS HAVE NO SUCCESSORS */
	for (j=0; j<procs; j++) {
		int mytask = stages*procs + j;
		printf("t%d: s0:\n", mytask);
		}

	/* 6. END */
}
