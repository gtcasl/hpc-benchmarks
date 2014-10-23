!****************************************************************************
!  This program is part of the
!	OpenMP Source Code Repository
!
!	http://www.pcg.ull.es/ompscr/
!	e-mail: ompscr@etsii.ull.es
!
!  This program is free software; you can redistribute it and/or modify
!  it under the terms of the GNU General Public License as published by
!  the Free Software Foundation; either version 2 of the License, or
!  (at your option) any later version.
!
!  This program is distributed in the hope that it will be useful,
!  but WITHOUT ANY WARRANTY; without even the implied warranty of
!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!  GNU General Public License for more details.
!
!  You should have received a copy of the GNU General Public License 
!  (LICENSE file) along with this program; if not, write to
!  the Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
!  Boston, MA  02111-1307  USA
!	
!FILE:		f_cell_solution1.f90
!VERSION:	1.0
!DATE:		Jun,2004
!AUTHOR:	Arturo González-Escribano
!COMMENTS TO:	arturo@infor.uva.es
!DESCRIPTION:      
!		Jacobi iteration for the heat equation
!		Solution 1: 
!			Series-Parallel (SP) version
!		
!			A loop inside a parallel region, 2 barriers
!			to protect the data copies across threads
!
!COMMENTS:
!		Data partition: Equally sized blocks of full columns
!
!		Matrix sizes (size_x, size_y) do not include the boundary
!		conditions. Two extra rows and columns are added to store
!		them.
!
!REFERENCES:	Quinn94 "Parallel Computing. Theory and Practice"
!		
!BASIC PRAGMAS:	parallel, get_thread_num, barrier
!
!USAGE: 	./f_cell.solution1 <size_x> <size_y> <numiter>
!
!INPUT:		The array has fixed innitial values:  
!			All inner elements are 0.0 
!			Boundary conditions have the following values:
!				First row:	100.0
!				Last row:	200.0
!				First column:	50.0
!				Last column:	75.0
!
!OUTPUT:	"debug_M.f90" file, containing code to write the matrix final
!		values is included automatically.
!FILE FORMATS:
!RESTRICTIONS:
!		To simplify the code the number of columns may be evenly 
!		distributed across the number of threads.
!			mod(size_y, numThreads) = 0
!
!REVISION HISTORY:
!
!**************************************************************************

!
! PROGRAM: PROCESS PARAMETERS
!
PROGRAM cell_solution1
USE oscrCommon_f
USE omp_lib
implicit none

INTERFACE
	subroutine cell(nthreads,size_x,size_y,numiter)
	integer :: nthreads, size_x, size_y, numiter
	end subroutine cell
END INTERFACE

integer :: nthreads, size_x, size_y, numiter
character(len=8),dimension(3) :: argNames = (/'size_x ', 'size_y ', 'numiter'/)
character(len=8),dimension(3) :: defaultValues = (/ '1000', '1000', '100 ' /)
character(len=8),dimension(1) :: timerNames = (/ 'EXE_TIME' /)

nthreads = omp_get_max_threads()
call OSCR_init( nthreads,						&
	"Cellular automata: Jacobi solver for the heat equation.",	&
	'',								&
	3,								&
	argNames,							&
	defaultValues,							&
	1,								&
	1,								&
	timerNames )

! 1. GET PARAMETERS
size_x = OSCR_getarg_integer(1)
size_y = OSCR_getarg_integer(2)
numiter = OSCR_getarg_integer(3)

! 2. CHECK: EASY DATA PARTITION SIZES?
IF (mod(size_y,nthreads) .ne. 0) THEN
	write(*,*) "Parameters error!!"
	write(*,*) "Parameters error, size_x/nthreads is not integer!!!"
	STOP
ENDIF

! 2. CALL COMPUTATION
call cell(nthreads, size_x, size_y, numiter)

! 3. REPORT
call OSCR_report()

END


!
! CELLULAR AUTOMATA PROGRAM
!
SUBROUTINE cell(nthreads,size_x,size_y,numiter)
USE oscrCommon_f
USE omp_lib
implicit none
integer :: nthreads, size_x, size_y, numiter

! 0.1. DECLARATIONS 
integer :: i,j
integer :: thread
integer :: iter
integer :: limitL, limitR

! 0.2. DECLARE MATRICES
real,allocatable,dimension(:,:) :: M
real,allocatable,dimension(:,:) :: oldM

allocate( M(0:size_x+1,0:size_y+1) )
allocate( oldM(0:size_x+1,0:size_y+1) )

!
! This alternative declaration is simpler but uses stack memory instead of heap.
! Thus, the matrices sizes supported are smaller due to stack limitations.
!
! real,dimension(0:size_x+1,0:size_y+1) :: M
! real,dimension(0:size_x+1,0:size_y+1) :: oldM
!

! 1. INITIALIZE MATRIX INNER PART AND BOUNDARY CONDITIONS
M=0.0
oldM=0.0
oldM(0,:) = 100.0
oldM(size_x+1,:) = 200.0
oldM(:,0) = 50.0
oldM(:,size_y+1) = 75.0


! 2. START TIMER
call OSCR_timer_start(1)

! 3. PROCESS IN PARALLEL
!$OMP PARALLEL default(none) shared(numiter,nthreads,size_y,size_x,M,oldM) private(iter,thread,limitL,limitR,i,j)

	! 3.1. COMPUTE LIMIT INDECES
	thread = OMP_GET_THREAD_NUM()
	limitL = thread*(size_y/nthreads)+1
	limitR = (thread+1)*(size_y/nthreads)

	! 3.2. ITERATIONS LOOP
	do iter=1,numiter

		! 3.2.1. COPY/SAVE OLD VALUES
		oldM(1:size_x,limitL:limitR) = M(1:size_x,limitL:limitR)

		! 3.2.2. SYNCHRONIZE BEFORE CHANGING LOCAL PART
		!	( IT USES VALUES FOR NON-LOCAL PART )
!$OMP		BARRIER

		! 3.2.3. COMPUTE ITERATION
		DO i=1,size_x
			DO j=limitL,limitR
				M(i,j) = (			&
					oldM(i-1,j) +		&
					oldM(i+1,j) +		&
					oldM(i,j-1) +		&
					oldM(i,j+1) ) / 4.0
			ENDDO
		ENDDO

!
! An alternative code for the loops.
! It is compiler dependent which one is better optimized. Typically they
! are equivalent.
!
!		M(1:size_x,limitL:limitR) = (			&
!			oldM(0:size_x-1,limitL:limitR) +	&
!			oldM(2:size_x+1,limitL:limitR) +	&
!			oldM(1:size_x,limitL-1:limitR-1) +	&
!			oldM(1:size_x,limitL+1:limitR+1) ) / 4.0
!

		! 3.2.4. SYNCHRONIZE BEFORE SAVING ANYTHING IN oldM
		!	( OTHER THREADS MAY BE STILL USING ITS VALUES )
!$OMP		BARRIER

	! 3.3. END ITERATIONS LOOP
	enddo

!$OMP	END PARALLEL

! 4. STOP TIMER
call OSCR_timer_stop(1)

! 5. WRITE MATRIX (DEBUG)
include "debug_M.f90"

! 6. END PROGRAM
END SUBROUTINE cell
