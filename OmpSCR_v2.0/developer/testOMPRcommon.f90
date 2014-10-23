!*************************************************************************
!  This program is part of the
!	OpenMP Source Code Repository
!
!	http://www.pcg.ull.es/OmpSCR/
!	e-mail: ompscr@zion.deioc.ull.es
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
!**************************************************************************
!
! OSCR common module test program 
!
! Compile with -O0 or some dummy loops could be eliminated by optimization
!
! Author: Arturo González-Escribano, 2004
!
!**************************************************************************
!
program TestOSCRcommon
USE oscrCommon_f
USE omp_lib

character(8),dimension(3) :: names = (/ 'argOne', 'argTwo', 'argThree' /)
character(8),dimension(3) :: defValues = (/ '1', '2.0', 'three' /)
character(18),dimension(1) :: timerNames = (/ 'task1' /)
integer :: intVar
real	:: realVar
character(1024)	:: stringVar

integer	:: i,j,k
integer :: numThreads


!
! 1. FIXING NUMBER AND NAMES OF PARAMETERS
!
numThreads = omp_get_num_threads()
call OSCR_init(								&
	numThreads,							&
	'A test application to show how the oscrCommon module is used',	&
	'',								&
	3, 								&
	names,								&
	defValues,							&
	2,								&
	1,								&
	timerNames)

!
! 2. GET PARAMETER VALUES
!
intVar = OSCR_getarg_integer(1)
realVar = OSCR_getarg_real(2)
stringVar = OSCR_getarg_character(3)

!
! 3. SOME TIME MEASURED COMPUTATION
!
write(*,*) 'Beginning the first test'
call OSCR_timer_start(1)
do i=1,1000000
	k=k+1
enddo
call OSCR_timer_stop(1)

!
! 4. SEVERAL (1,000) TIME ACCUMULATED TASKS (using another timer)
!
write(*,*) 'Beginning the second test'
call OSCR_timer_start(2)
do i=1,100
	do j=1,1000000
		k=k+1
	enddo
enddo
call OSCR_timer_stop(2)

!
! 6. REPORT 
!
write(*,*)
write(*,*) 'Report:'
call OSCR_report()

!  We manually report the mean time of the accumulated tasks
write(*,'(A17,F12.6)') ' Mean time tasks2: ', OSCR_timer_read(2) / 100.0

stop
end program

