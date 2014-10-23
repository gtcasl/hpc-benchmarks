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
! OpenMP Source Code Repository
!
! Module: oscrCommon_f90
! Version: v0.2
!
! Copyright (C) 2004, Arturo González Escribano
! 
! Common funtions to control command line arguments, timers and report
!
!**************************************************************************
!
MODULE oscrCommon_f
        implicit none

	! 0. CONSTANTS
	character(len=5)	:: OSCR_TESTARG = '-test'
	character(len=66)	:: OSCR_HEADER = 'This program is part of the OpenMP Source Code Repository (OmpSCR)'

	! 1. INITIALIZATION CONTROL
	logical			:: oscrData_init = .false.
	integer			:: oscrData_numThreads  = 0

	! 2. COMMAND LINE ARGUMENTS CONTROL
	integer			:: oscrData_numArgs = 0
	character(len=1024)	:: oscrData_usage = '?'
	character(len=1024),dimension(:),allocatable	:: oscrData_argNames
	character(len=1024),dimension(:),allocatable	:: oscrData_argv

	integer, external 	:: iargc
	character(len=1024)	:: argsBuffer

	! 3. TIMERS CONTROL
	integer			:: oscrData_numTimers
	integer			:: oscrData_numReportedTimers
	character(len=1024),dimension(:),allocatable	:: oscrData_reportedTimerNames

	TYPE oscrTimer
		double precision	:: start
		double precision	:: elapsed
		logical			:: active
	END TYPE oscrTimer
        TYPE(oscrTimer),dimension(:),allocatable        :: oscrTimers
	
	! 4. WTIME INTERFAZ
	double precision,external 	:: oscr_wtime



CONTAINS

	!
	! SHOW COMMAND-LINE ARGUMENTS ERROR, AND USAGE-LINE
	!
	subroutine OSCR_ARGS_ERROR(message, ind)
		character(len=*),intent(in)	:: message
		integer,intent(in)		:: ind

		! 1. WRITE ERROR AND USAGE MESSAGE
		write(*,*)
		if ( ind .eq. 0 ) then
			write(*,*) 'OSCR Error: ', trim(message)
		else
			write(*,*) 'OSCR Error: ', trim(message), ' ', ind
		endif

		call getarg(0, argsBuffer)
		write(*,*)
		write(*,*) 'Usage: ', trim(argsBuffer), ' ', OSCR_TESTARG
		write(*,*) '       ', trim(argsBuffer), ' ', trim(oscrData_usage)
		write(*,*)

		! 2. STOP PROGRAM
		stop
	end subroutine OSCR_ARGS_ERROR

	!
	! SHOW INTERNAL ERROR: Don't show usage-line
	!
	subroutine OSCR_ERROR(message, errInfo)
		character(*),intent(in)	:: message
		integer,intent(in)	:: errInfo

		! 1. WRITE ERROR AND MESSAGE
		write(*,*)
		if (errInfo .ne. -1) then
			write(*,*) 'OSCR Error: ', trim(message), errInfo 
		else
			write(*,*) 'OSCR Error: ', trim(message)
		endif
		write(*,*)

		! 2. STOP PROGRAM
		stop
	end subroutine OSCR_ERROR

	!
	! INITIALIZATION FUNCTION
	! Receives:
	!	- The maximum number of threads: Pass get_max_threads() value
	!	- A descriptive message for the common report header
	!	- An optional "usage" string to show when command line errors
	!	- The number of arguments to require in the command line
	!	- An array of strings with the names of these arguments
	!		(Used to build the default "usage" line and for report)
	!	- An array of strings with the default values for arguments
	!	- The number of timers to be defined 
	!	- The number of timers to be automatically reported
	!	- An array of strings with the names of these reported timers
	!
	subroutine OSCR_INIT(						&
		numThreads, description, usage, 			&
		numArgs, argNames, defaultValues,			&
		numTimers, numReportedTimers, reportedTimerNames )

		integer,intent(in)	:: numThreads	
		character(*),intent(in)	:: description
		character(*),intent(in)	:: usage
		integer,intent(in)	:: numArgs
		character(len=*),dimension(:),intent(in) :: argNames
		character(len=*),dimension(:),intent(in) :: defaultValues
		integer,intent(in)	:: numTimers
		integer,intent(in)	:: numReportedTimers
		character(len=*),dimension(:),intent(in) :: reportedTimerNames

		integer	:: i
                integer :: argc

		! 1. CHECK IF INITIALIZED TWICE
		if ( oscrData_init ) then
			 call OSCR_ARGS_ERROR('internal - Initializing twice!!', 0)
		endif
		oscrData_init = .true.

		! 2. FIX THE NUMBER OF THREADS FOR INFORMATION REPORTING
		oscrData_numThreads = numThreads
		if ( numThreads .lt. 1 ) then
			call OSCR_ERROR("Invalid number of threads", numThreads)
		endif

		! 3. PRINT HEADER
		call getarg(0, argsBuffer)
		write(*,*) OSCR_HEADER
		write(*,*)
		write(*,*) 'Program:       ', trim(argsBuffer)
		write(*,*) 'Description:   ', trim(description)

		! 4. NUMBER OF PARAMETERS AND ARGUMENT NAMES
                argc = iargc();
		if ( (numArgs .ne. size(argNames))		&
			.or. (numArgs .ne. size(defaultValues)) ) then
			call OSCR_ERROR("internal - Bad arguments initialization array sizes!!", 0)
		endif

		! 4.1. STORE ARRAYS AND SIZES
		oscrData_numArgs = numArgs
		allocate( oscrData_argNames( numArgs ) )
		oscrData_argNames = argNames

		allocate( oscrData_argv( argc ) )
		do i=1,argc
			call getarg(i, argsBuffer)
			oscrData_argv(i) = argsBuffer
		enddo

		! 4.2. IF EXPLICIT USAGE IS EMPTY, BUILD DEFAULT USAGE LINE
		if ( trim(usage) .ne. '' ) then
			oscrData_usage = usage
		else
			oscrData_usage = ''
			do i=1,numArgs
				oscrData_usage = trim(oscrData_usage)	&
					// " <" // trim(argNames(i)) // ">"
			enddo
		endif

		! 4.3. CHECK THE -test ARGUMENT ALONE IN COMMAND-LINE
		if ( argc .eq. 1 ) then
			if ( oscrData_argv(1) .eq. OSCR_TESTARG) then
				deallocate( oscrData_argv )
				allocate( oscrData_argv( numArgs) )
				do i=1,numArgs
					oscrData_argv(i) = defaultValues(i)
				enddo

				!  CHEAT THE FOLLOWING NUMBER-OF-ARGUMENTS CHECK
				argc = numArgs
			endif
		endif

		! 4.4. CHECK IF THE NUMBER OF ARGUMENTS IS CORRECT
		if ( argc .ne. numArgs ) then
			call OSCR_ARGS_ERROR("Invalid number of arguments", 0)
                endif

		! 4.5. WRITE THE ARGUMENTS VALUES AND BEGIN-EXECUTION LINE
		write(*,*)
		do i=1,numArgs
			write(*,*) 'Argument ', trim(argNames(i)), ' ', trim(oscrData_argv(i))
		enddo

		write(argsBuffer,'(I5)') oscrData_numThreads
		write(*,*) 'Argument NUMTHREADS ', trim(argsBuffer)
		write(*,*)
		write(*,*) 'Running...'
		write(*,*)


		! 5. TIMERS: INIT
		! 5.1. CHECK VALID NUMBER OF TIMERS
		if (numTimers .lt. 1) then
			call OSCR_ERROR("internal - number of timers invalid!!",numTimers)
		endif

		! 5.2. ALLOCATE TIMERS
		oscrData_numTimers = numTimers
		allocate( oscrTimers( numTimers) )
		
		! 5.3. INITIALIZE TIMERS
		do i=1,numTimers
			oscrTimers(i) = oscrTimer(0.0, 0.0, .false.)
		enddo

		! 5.4. CHECK VALID NUMBER OF REPORTED TIMERS
		if ( (numReportedTimers .lt. 0)				&
			.or. (numReportedTimers .gt. oscrData_numTimers)) then 
			call OSCR_ERROR("internal - report: invalid number of Reported-Timers -> ", numReportedTimers)
		endif
		if (numReportedTimers .ne. size(reportedTimerNames)) then
			call OSCR_ERROR("internal - Bad reported timer names initialization array sizes!!", 0)
		endif


		! 5.5. STORE REPORTED TIMER NAMES
		oscrData_numReportedTimers = numReportedTimers
		allocate( oscrData_reportedTimerNames(numReportedTimers) )
		oscrData_reportedTimerNames = reportedTimerNames

	! 6. END
	end subroutine OSCR_INIT



	!
	! CHECK ARGUMENT INDEX
	!
	subroutine OSCR_GETARG_CHECK(ind)
		integer,intent(in)	:: ind

		! 1. CHECK PROPER INDEX
		if ( .not. oscrData_init ) then
			call OSCR_ARGS_ERROR('internal, OSCR_INIT not set before getting arg', ind)
		endif
		if ( (ind .lt. 1) .or. (ind .gt. oscrData_numArgs) ) then
			call OSCR_ARGS_ERROR('internal, getting invalid param number',ind)
		endif
	end subroutine OSCR_GETARG_CHECK	


	!
	! GET ARGUMENT: INTEGER
	!
	integer function OSCR_GETARG_INTEGER(ind)
!		integer			:: OSCR_GET_INTEGER
		integer,intent(in)	:: ind
		integer			:: dummy 
		integer			:: ios 

		! 1. CHECK PROPER INDEX
		call OSCR_GETARG_CHECK(ind)
		
		! 2. CONVERT ARG
		read (oscrData_argv(ind),'(I)',iostat=ios) dummy

		! 3. CHECK CONVERSION
		if ( ios .ne. 0 ) then
			call OSCR_ARGS_ERROR('Incorrect type in argument',ind)
		endif
		OSCR_GETARG_INTEGER = dummy
	end function OSCR_GETARG_INTEGER

	!
	! GET ARGUMENT: REAL
	!
	real function OSCR_GETARG_REAL(ind)
!		real			:: OSCR_GET_REAL
		integer,intent(in)	:: ind
		real			:: dummy 
		integer			:: ios

		! 1. CHECK PROPER INDEX
		call OSCR_GETARG_CHECK(ind)
		
		! 2. CONVERT ARG
		read (oscrData_argv(ind),'(F)',iostat=ios) dummy

		! 3. CHECK CONVERSION
		if ( ios .ne. 0 ) then
			call OSCR_ARGS_ERROR('Incorrect type in argument',ind)
		endif
		OSCR_GETARG_REAL = dummy
	end function OSCR_GETARG_REAL

	!
	! GET ARGUMENT: DOUBLE PRECISION
	!
	double precision function OSCR_GETARG_DOUBLEPRECISION(ind)
!		double precision	:: OSCR_GET_DOUBLEPRECISION
		integer,intent(in)	:: ind
		double precision	:: dummy 
		integer			:: ios

		! 1. CHECK PROPER INDEX
		call OSCR_GETARG_CHECK(ind)
		
		! 2. CONVERT ARG
		read (oscrData_argv(ind),'(F)',iostat=ios) dummy

		! 3. CHECK CONVERSION
		if ( ios .ne. 0 ) then
			call OSCR_ARGS_ERROR('Incorrect type in argument',ind)
		endif
		OSCR_GETARG_DOUBLEPRECISION = dummy
	end function OSCR_GETARG_DOUBLEPRECISION

	!
	! GET ARGUMENT: CHARACTER
	!
	character(len=1024) function OSCR_GETARG_CHARACTER(ind)
!		character(len=1024)	:: OSCR_GETARG_CHARACTER
		integer,intent(in)	:: ind
		character(1024)		:: dummy 
		integer			:: ios

		! 1. CHECK PROPER INDEX
		call OSCR_GETARG_CHECK(ind)
		
		! 2. CONVERT ARG
		read (oscrData_argv(ind),'(A)',iostat=ios) dummy

		! 3. CHECK CONVERSION
		if ( ios .ne. 0 ) then
			call OSCR_ARGS_ERROR('Incorrect type in argument',ind)
		endif
		OSCR_GETARG_CHARACTER = trim(dummy)
	end function OSCR_GETARG_CHARACTER


	!
	! CHECK TIMER INDEX
	!
	subroutine OSCR_TIMER_CHECK(routine, ind)
		character(len=*),intent(in)	:: routine
		integer,intent(in)		:: ind

		! 1. CHECK PROPER INDEX
		if ( .not. oscrData_init ) then
			call OSCR_ERROR('internal - Using a timer before initialize OmpSCR',ind)
		endif
		if ((ind .lt. 1) .OR. (ind .gt. oscrData_numTimers)) then
			call OSCR_ERROR('internal - ' // routine // ': invalid timer index ->',ind)
		endif
	end subroutine OSCR_TIMER_CHECK	


	!
	! TIMERS: TIME CLEAR
	!
	subroutine OSCR_TIMER_CLEAR(ind)
		integer,intent(in)	:: ind

		! 1. CHECK VALID INDEX
		call OSCR_TIMER_CHECK('timerClear', ind)

		! 2. CLEAR TIMER
		oscrTimers(ind)%elapsed = 0.0
	end subroutine OSCR_TIMER_CLEAR
	
	!
	! TIMERS: TIME START
	!
	subroutine OSCR_TIMER_START(ind)
		integer,intent(in)	:: ind

		! 1. CHECK VALID INDEX
		call OSCR_TIMER_CHECK('timerStart', ind)

		! 2. CHECK TIMER NOT ACTIVE
		if ( oscrTimers(ind)%active ) then
			call OSCR_ERROR('internal - timerStart, timer already started ->',ind)
		endif
		oscrTimers(ind)%active = .true.

		oscrTimers(ind)%start = oscr_wtime()
	end subroutine OSCR_TIMER_START
	
	!
	! TIMERS: TIME STOP
	!
	subroutine OSCR_TIMER_STOP(ind)
		integer,intent(in)	:: ind
		double precision	:: elapsed

		! 1. CHECK VALID INDEX
		call OSCR_TIMER_CHECK('timerStop', ind)

		! 2. CHECK TIMER ACTIVE
		if ( .not. oscrTimers(ind)%active ) then
			call OSCR_ERROR('internal - timerStop, timer not previously started ->',ind)
		endif
		oscrTimers(ind)%active = .false.

		elapsed = oscr_wtime() - oscrTimers(ind)%start
		oscrTimers(ind)%elapsed = oscrTimers(ind)%elapsed + elapsed
	end subroutine OSCR_TIMER_STOP

	!
	! TIMERS: READ
	!
	double precision function OSCR_TIMER_READ(ind)
!		double precision	:: OSCR_TIMER_READ
		integer,intent(in)	:: ind

		! 1. CHECK VALID INDEX
		call OSCR_TIMER_CHECK('timerRead', ind)

		OSCR_TIMER_READ = oscrTimers(ind)%elapsed
	end function OSCR_TIMER_READ

	!
	! REPORT
	!
	subroutine OSCR_REPORT()
		integer	:: i

		! 1. WRITE TIMERS
		do i=1,oscrData_numReportedTimers
			write(argsBuffer,'(F12.6)') OSCR_TIMER_READ(i)
			write(*,*) 'Timer ', trim(oscrData_reportedTimerNames(i)) , ' ' , trim(argsBuffer)
		enddo
		write(*,*)
	end subroutine OSCR_REPORT

END MODULE oscrCommon_f

