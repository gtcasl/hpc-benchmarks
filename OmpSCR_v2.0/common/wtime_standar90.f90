!***************************************************************************
!  This library is part of the
!	OpenMP Source Code Repository
!
!	http://www.pcg.ull.es/OmpSCR/
!	e-mail: ompscr@zion.deioc.ull.es
!
!  This library is free software; you can redistribute it and/or
!  modify it under the terms of the GNU Lesser General Public
!  License as published by the Free Software Foundation; either
!  version 2.1 of the License, or (at your option) any later version.
!
!  This library is distributed in the hope that it will be useful,
!  but WITHOUT ANY WARRANTY; without even the implied warranty of
!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
!  Lesser General Public License for more details.
!
!  You should have received a copy of the GNU Lesser General Public
!  License along with this library; if not, write to the Free Software
!  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
!
!	
!**************************************************************************
!
! Installation dependent wtime functions
!
! Version: Standar Fortran90 system clock
!  
! Copyright (C) 2004, Arturo González Escribano
!

!
! 1. Wtime
!
function OSCR_WTIME()
	USE OMP_LIB
	double precision :: OSCR_WTIME

	double precision :: wtime
	integer :: now, rate

	call system_clock(now, rate)
	wtime = now
	wtime = wtime / (0.0+rate)

	OSCR_WTIME = wtime
end function OSCR_WTIME


!
! 2. PRECISION
!
function OSCR_TIMER_PRECISION()
	USE OMP_LIB
	double precision :: OSCR_WTIME

	real :: wtick
	integer :: now, rate

	call system_clock(now, rate)
	wtick = 1.0 / (0.0+rate)

	OSCR_TIMER_PRECISION = wtick
end function OSCR_TIMER_PRECISION

