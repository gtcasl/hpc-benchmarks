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
	
 ---------------------------------------------------------------------------
  randomGraph.c

  version 1.0

  Generates directed random graphs in .gph format 
  Parameters:
  	<num_nodes>		Number of nodes in the graph
  	<seed>			Random sequence seed
  	<mean_edges_per_node>	Program generates aproximately this value
  				of edges per node. May be not integer.
 
  NOTE 1: Graphs generated may be unconnected and/or cyclic
  NOTE 2: The algorithm has a time complexity bound of O(n^2)
 
  Copyright (C) 2004, Arturo González-Escribano
 
**************************************************************************/
#include<stdio.h>
#include<stdlib.h>

int main(int argc, char *argv[]) {
	int nodes;
	long seed;
	double numEdgesPerNode;
	double edgesDensity;

	int check=0;
	int i,j;
	short *conex;

	/* 1. READ ARGUMENTS */
	if (argc != 4) {
		fprintf(stderr,"\nUsage: randomGraph <num_nodes> <seed> <mean_edges_per_node>\n\n");
		exit(1);
		}
	check = sscanf(argv[1], "%d", &nodes);
	check += sscanf(argv[2], "%ld", &seed);
	check += sscanf(argv[3], "%lf", &numEdgesPerNode);
	if (check != 3 || nodes < 1) {
		fprintf(stderr,"\nError in parameters!!\n");
		fprintf(stderr,"\nUsage: randomGraph <num_nodes> <seed> <mean_edges_per_node>\n\n");
		exit(1);
		}

	/* 2. WRITE HEADER */
	printf("#\n# Random graph\n");
	printf("#\tNodes: %d, Seed: %ld, Mean of edges (per node): %lf\n#\n", nodes, seed, numEdgesPerNode);
	printf("T: %d\n", nodes);
	printf("R: 0\n");

	/* 3. COMPUTE PROBABILIY OF EACH EDGE TO EXIST */
	edgesDensity = numEdgesPerNode / nodes;

	/* 4. INITIALIZE RANDOM SEQUENCE */
	srand48(seed);

	/* 5. GET MEMORY FOR EDGES */
	conex = (short *)malloc(sizeof(short)*nodes);

	/* 6. FOR EACH NODE */
	for (i=0; i<nodes; i++) {
		int edges = 0;

		/* 6.1. WRITE TASK NUMBER */
		printf("t%d: ", i);

		/* 6.2. FOR EACH POSSIBLE EDGE LEAVING THIS NODE */
		for (j=0; j<nodes; j++) {
			/* 6.2.1. TEST EDGE PRESENCE */
			double rndSample = drand48();
			if (rndSample < edgesDensity) {
				conex[j] = 1;
				edges++;
				}
			else conex[j]=0;
			}

		/* 6.3. WRITE NUMBER OF SUCCESORS */
		printf("s%d:", edges);

		/* 6.4. WRITE SUCCESOR NUMBERS */
		for (j=0; j<nodes; j++) {
			if (conex[j]) printf(" %d",j);
			}

		/* 6.5. WRITE END OF NODE LINE */
		printf("\n");
		}

	/* 7. END */
}
