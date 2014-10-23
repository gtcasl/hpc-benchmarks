/* 6. WRITE MATRIX (DEBUG) */
{
int i,j;

/* 6.1. WRITE M CONTAINING UPPER PART */
fprintf(stderr,"Matrix: M -----------------\n");
for (i=0; i<size; i++) {
	for (j=0; j<size; j++) {
		fprintf(stderr,"%6.1f\t", M[i][j]);
		}
	fprintf(stderr,"\n");
	}

/* 6.2. WRITE L CONTAINING THE LOWER PART */
fprintf(stderr,"Matrix: L ----------------------------\n");
for (i=0; i<size; i++) {
	for (j=0; j<size; j++) {
		fprintf(stderr,"%6.1f\t", L[i][j]);
		}
	fprintf(stderr,"\n");
	}
}
