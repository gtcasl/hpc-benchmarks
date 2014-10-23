!°*********************************************************************
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
!  FILE:              f_pi.f90
!  VERSION:           1.0
!  DATE:              May 2004
!  COMMENTS TO:       sande@csi.ull.es
!  DESCRIPTION:       Parallel implementation of PI generator using OpenMP
!  COMMENTS:          The area under the curve y=4/(1+x*x) between 0 and 1 provides a way to compute Pi
!	                   The value of this integral can be approximated using a sum.
!  REFERENCES:        http://en.wikipedia.org/wiki/Pi
!	                   http://nereida.deioc.ull.es/~llCoMP/examples/examples/pi/pi_description.html
!  BASIC PRAGMAS:     parallel
!  USAGE:             ./f_pi.par
!  INPUT:             Default precision
!  OUTPUT:            The value of PI
!	FILE FORMATS:      -
!	RESTRICTIONS:      -
!	REVISION HISTORY:
!**************************************************************************


program pi_fortran
USE oscrCommon_f
USE omp_lib
implicit none

integer, parameter  :: DEFAULT_PREC  = 1000000   ! Default precision 
integer, parameter  :: NUM_ARGS      = 1
integer, parameter  :: NUM_TIMERS    = 1
double precision   :: PI25DT = 3.141592653589793238462643
double precision   :: local, w, total_time, pi

integer :: NUMTHREADS
character(len=8),dimension(NUM_ARGS) :: argNames = (/ 'Precission' /)
character(len=8),dimension(NUM_ARGS) :: defaultValues = (/ '1000000' /)
character(len=8),dimension(NUM_TIMERS) :: timerNames = (/ 'EXE_TIME' /)


integer :: i,  N   ! Precision 

NUMTHREADS = omp_get_max_threads()
call OSCR_init( NUMTHREADS,           &
  "Pi.",  &
  '',               &
  NUM_ARGS,                &
  argNames,             &
  defaultValues,              &
  NUM_TIMERS,                &
  NUM_TIMERS,                &
  timerNames )


N = OSCR_getarg_integer(NUM_ARGS)
call OSCR_timer_start(NUM_TIMERS)
 w = 1.0 / N
 pi = 0.0

!$OMP PARALLEL PRIVATE(local,i), SHARED(w,N), &
!$OMP REDUCTION(+:pi)
!$OMP DO 
      do i=1,N
         local = (i + 0.5) * w;
         pi = pi + 4.0 / (1.0 + local * local);
      end do

!$OMP END DO

!$OMP END PARALLEL 
   
   pi = pi * w;
 

call OSCR_timer_stop(NUM_TIMERS)
total_time = OSCR_timer_read(NUM_TIMERS)
call  OSCR_report() 
!
 print*,"\n \t# THREADS INTERVAL \tTIME (secs.) \tPI \t\t\tERROR\n\t"
 print*,pi,total_time, N, (PI25DT-pi)

END

!
! * vim:ts=2:sw=2:
! 

