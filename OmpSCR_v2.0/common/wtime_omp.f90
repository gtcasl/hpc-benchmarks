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
! Version: Pure OMP 
!	Please, check that your compiler stubs implement OMP_GET_WTIME
!	function properly if you plan to use sequential compilation option
!  
! Copyright (C) 2004, Arturo González Escribano
!

!
! 1. Wtime
!
function OSCR_WTIME()
	USE OMP_LIB
	double precision :: OSCR_WTIME

	OSCR_WTIME = omp_get_wtime()
end function OSCR_WTIME


!
! 2. PRECISION
!
function OSCR_TIMER_PRECISION()
	USE OMP_LIB
	double precision :: OSCR_TIMER_PRECISION

	OSCR_TIMER_PRECISION = omp_get_wtick()
end function OSCR_TIMER_PRECISION

