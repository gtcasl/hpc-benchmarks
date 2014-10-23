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
!FILE:		cell_solution5.f90
!VERSION:	1.0
!DATE:		Jun,2004
!AUTHOR:	Arturo González-Escribano
!COMMENTS TO:	arturo@infor.uva.es
!DESCRIPTION:      
!		Jacobi iteration for the heat equation
!		Solution 5: 
!			Non Series-Parallel (SP) version
!				Iterations are not fully synchronized
!
!			Copy to oldM values splited in three parts:
!			- Copy values needed by my "left" thread (1 column)
!			- Copy values needed by my "right" thread (1 column)
!			- Copy values needed only by myself
!
!			Each of the two first copies are synchronized only
!			with their thread counterparts using:
!
!			*** Flushed variables: Active waits ***
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
!USAGE: 	./f_cell.solution5 <size_x> <size_y> <numiter>
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
PROGRAM cell_solution5
USE oscrCommon_f
USE omp_lib
implicit none

INTERFACE
	subroutine cell(nthreads,size_x,size_y,numiter)
	integer :: nthreads, size_x, size_y, numiter
	end subroutine cell
END INTERFACE

integer :: nthreads, size_x, size_y, numiter
character(len=8),dimension(3) :: argNames = (/ 'size_x ', 'size_y ','numiter' /)
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

! 0.2. DECLARE SYNCHRONIZATION VARIABLES
integer,dimension(0:nthreads-1) :: syncL, syncR
integer :: neigL, neigR

! 0.3. DECLARE MATRICES
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


! 1.1. INITIALIZE MATRIX INNER PART AND BOUNDARY CONDITIONS
M=0.0
oldM=0.0
oldM(0,:) = 100.0
oldM(size_x+1,:) = 200.0
oldM(:,0) = 50.0
oldM(:,size_y+1) = 75.0

! 1.2. INITIALIZE SYNCHRONIZATION VARIABLES
syncL = 0
syncR = 0


! 2. START TIMER
call OSCR_timer_start(1)

! 3. PROCESS IN PARALLEL
!$OMP PARALLEL default(none) &
!$OMP	shared(numiter,nthreads,size_y,size_x,M,oldM,syncL,syncR) &
!$OMP	private(iter,thread,limitL,limitR,neigL,neigR,i,j)

	! 3.1. COMPUTE NEIGHBOR INDECES
	thread = OMP_GET_THREAD_NUM()
	neigL = thread - 1	
	neigR = thread + 1	

	! 3.2. COMPUTE LIMIT INDECES
	limitL = thread*(size_y/nthreads)+1
	limitR = (thread+1)*(size_y/nthreads)

	! 3.3. ITERATIONS LOOP
	do iter=1,numiter

		! 3.3.1. WAIT FOR NEIGHBORS TO FINISH USING OUR OLD DATA
		if (thread .NE. 0) then
!$OMP			flush(syncL)
			do while(syncL(thread) .NE. 0)
!$OMP				flush(syncL)
			end do
		end if
		if (thread .NE. nthreads-1) then
!$OMP			flush(syncR)
			do while(syncR(thread) .NE. 0)
!$OMP				flush(syncR)
			end do
		end if
	
		! 3.3.2. COPY/SAVE VALUES NEEDED BY OTHER THREADS
		oldM(1:size_x, limitL) = M(1:size_x, limitL)
		oldM(1:size_x, limitR) = M(1:size_x, limitR)

		! 3.3.3. INFORM NEIGHBOR THREADS ABOUT I HAVE FINISHED COPIES
		syncL(thread)=1
		syncR(thread)=1
!$OMP		flush(syncL)
!$OMP		flush(syncR)

		! 3.3.4. SYNCHRONIZE BEFORE CHANGING THE LOCAL PART
		!	WAIT FOR NEIGHBOR THREADS TO FINISH THEIR COPY/SAVE
		if (thread .NE. 0) then
!$OMP			flush(syncR)
			do while (syncR(neigL) .NE. 1)
!$OMP				flush(syncR)
			end do
		end if
		if (thread .NE. nthreads-1) then
!$OMP			flush(syncL)
			do while (syncL(neigR) .NE. 1)
!$OMP				flush(syncL)
			end do
		end if

		! 3.3.5. COPY/SAVE THE REST OF OLD VALUES
		oldM(1:size_x,limitL+1:limitR-1) = M(1:size_x,limitL+1:limitR-1)

		! 3.3.6. COMPUTE ITERATION
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

		! 3.3.7. LOCAL WORK ENDED, PREPARE SYNCHRONIZATION
		!	INFORM NEIGBORS I HAVE FINISHED USING THEIR DATA
		if (thread .NE. 0) then
			syncR(neigL)=0
!$OMP			flush(syncR)
		end if
		if (thread .NE. nthreads-1) then
			syncL(neigR)=0
!$OMP			flush(syncL)
		end if

	! 3.4. END ITERATIONS LOOP
	enddo

!$OMP	END PARALLEL

! 4. STOP TIMER
call OSCR_timer_stop(1)

! 5. WRITE MATRIX (DEBUG)
include "debug_M.f90"

! 6. END PROGRAM
END SUBROUTINE cell
