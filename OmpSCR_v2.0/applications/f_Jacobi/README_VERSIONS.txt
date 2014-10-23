f_jacobi01.f90	two parallel regions with one parallel loop each, the naive approach
f_jacobi02.f90	original OpenMP version from www.openmp.org, 2 parallel loops in one parallel region (PR)
f_jacobi03.f90	1 PR outside the iteration loop, 4 Barriers
f_jacobi04.f90	1 PR outside the iteration loop, 3 Barrier
f_jacobi05.f90	like f_jacobi04.f90, precalculation of the loop limits
f_jacobi06.f90	like f_jacobi05.f90, trying to optimize the reduction
f_jacobi08.f90	1 PR outside the iteration loop, 2-fold unrolling, software pipelining, 2 barriers per iteration
f_jacobi09.f90 	1 PR outside the iteration loop, no copying, 4-fold unrolling, software pipelining, 1 barrier per iteration
f_jacobi10.f90	1 PR like V9, with errorh(0:2) to reduce code length
f_jacobi11.f90	1 PR like V9, with errorh(0:2) and uh(.,.,0:1) to reduce code length - bad performance

