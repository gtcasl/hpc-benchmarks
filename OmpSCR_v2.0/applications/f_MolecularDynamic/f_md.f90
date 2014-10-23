!***********************************************************************
!  This program is part of the
!	OpenMP Source Code Repository
!
!	http://www.pcg.ull.es/ompscr/
!	e-mail: ompbench@etsii.ull.es
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
!	
!  FILE:              f_md.f90
!  VERSION:           1.0
!  DATE:              May 2004
!  AUTHOR:            Bill Magro, Kuck and Associates, Inc. (KAI), 1998
!  COMMENTS TO:       sande@csi.ull.es
!  DESCRIPTION:       This program implements a simple molecular dynamics simulation,
!                     using the velocity Verlet time integration scheme. 
!		      The particles interact with a central pair potential.
!  COMMENTS:	
!  REFERENCES:        W. C. Swope and H. C. Andersen and P. H. Berens and K. R.  Wilson
!                     A Computer Simulation Method for the Calculation of
!                     Equilibrium Constants for the Formation of Physical
!                     Clusters of Molecues: Application to Small Water Clusters
!                      Journal of Chemical Physics, 1982 vol. 76 pg 637-649
!  BASIC PRAGMAS:     parallel do
!  USAGE:             ./f_md.par 4096 10
!  INPUT:             Number of particles
!                     Number of simulation steps
!  OUTPUT:            - 
!	FILE FORMATS:      -
!	RESTRICTIONS:   An excessive number of particles might cause a runtime error  
!                       in the parallel application if memory is not enough.
!	REVISION HISTORY:
!**************************************************************************


      program md_fortran
      USE oscrCommon_f
      USE omp_lib
      implicit none

      ! simulation parameters
      integer ndim       ! dimensionality of the physical space
      integer NPARTS_DEF ! number of particles
      integer NPARTS_MAX ! number of particles
      integer NSTEPS_DEF ! number of time steps in the simulation
      parameter(ndim=3,NPARTS_DEF=4096,NPARTS_MAX=100000,NSTEPS_DEF=10)
      integer, parameter  :: NUM_ARGS      = 2
      integer, parameter  :: NUM_TIMERS    = 1
      real*8 mass        ! mass of the particles
      real*8 dt          ! time step
      real*8 box(ndim)   ! dimensions of the simulation box
      parameter(mass=1.0,dt=1.0e-4)

      ! simulation variables
      integer nparts     ! number of particles
      integer nsteps     ! number of time steps in the simulation
      real*8 position(ndim,NPARTS_MAX)
      real*8 velocity(ndim,NPARTS_MAX)
      real*8 force(ndim,NPARTS_MAX)
      real*8 accel(ndim,NPARTS_MAX)
      real*8 potential, kinetic, E0
      integer i

      integer :: NUMTHREADS
      character(len=8),dimension(NUM_ARGS) :: argNames = (/ 'NPARTS', 'NSTEPS' /)
      character(len=8),dimension(NUM_ARGS) :: defaultValues = (/ '4096', '  10' /)
      character(len=8),dimension(NUM_TIMERS) :: timerNames = (/ 'EXE_TIME' /)
      double precision :: total_time
      box(1:ndim) = 10.
      
      
      NUMTHREADS = omp_get_max_threads()
      call OSCR_init( NUMTHREADS,           &
                      "Molecular dynamic simulation",  &
                      '',               &
                      NUM_ARGS,                &
                      argNames,             &
                      defaultValues,              &
                      NUM_TIMERS,                &
                      NUM_TIMERS,                &
                      timerNames )


      nparts = OSCR_getarg_integer(1)
      nsteps = OSCR_getarg_integer(2)


      ! set initial positions, velocities, and accelerations
      call initialize(nparts,ndim,box,position,velocity,accel)

      call OSCR_timer_start(NUM_TIMERS)
      
      ! compute the forces and energies
      call compute(nparts,ndim,box,position,velocity,mass,force,potential,kinetic)
      E0 = potential + kinetic

      ! This is the main time stepping loop
      do i=1,nsteps
          call compute(nparts,ndim,box,position,velocity,mass, force,potential,kinetic)
          ! write(*,*) potential, kinetic,(potential + kinetic - E0)/E0
          call update(nparts,ndim,position,velocity,force,accel,mass,dt)
      enddo

      call OSCR_timer_stop(NUM_TIMERS)
      total_time = OSCR_timer_read(NUM_TIMERS)
      call  OSCR_report()

      end

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Compute the forces and energies, given positions, masses,
! and velocities
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      subroutine compute(np,nd,box,pos,vel,mass,f,pot,kin)
      implicit none

      integer np
      integer nd
      real*8  box(nd)
      real*8  pos(nd,np)
      real*8  vel(nd,np)
      real*8  f(nd,np)
      real*8  mass
      real*8  pot
      real*8  kin

      real*8 dotr8
      external dotr8
      real*8 v, dv, x

      integer i, j, k
      real*8  rij(nd)
      real*8  d
      real*8  PI2
      parameter(PI2=3.14159265d0/2.0d0)

      ! statement function for the pair potential and its derivative
      ! This potential is a harmonic well which smoothly saturates to a
      ! maximum value at PI/2.
      v(x) = sin(min(x,PI2))**2.
      dv(x) = 2.*sin(min(x,PI2))*cos(min(x,PI2))

      pot = 0.0
      kin = 0.0

      ! The computation of forces and energies is fully parallel.
!$OMP PARALLEL DO DEFAULT(SHARED) PRIVATE(i,j,k,rij,d) &
!$OMP REDUCTION(+ : pot, kin)
      do i=1,np
        ! compute potential energy and forces
        f(1:nd,i) = 0.0
        do j=1,np
             if (i .ne. j) then
               call dist(nd,box,pos(1,i),pos(1,j),rij,d)
               ! attribute half of the potential energy to particle 'j'
               pot = pot + 0.5*v(d)
               do k=1,nd
                 f(k,i) = f(k,i) - rij(k)*dv(d)/d
               enddo
             endif
        enddo
        ! compute kinetic energy
        kin = kin + dotr8(nd,vel(1,i),vel(1,i))
      enddo
!$omp end parallel do
      kin = kin*0.5*mass
  
      return
      end
       
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Initialize the positions, velocities, and accelerations.
! The Fortran90 random_number function is used to choose positions.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      subroutine initialize(np,nd,box,pos,vel,acc)
      implicit none

      integer np
      integer nd
      real*8  box(nd)
      real*8  pos(nd,np)
      real*8  vel(nd,np)
      real*8  acc(nd,np)

      integer i, j
      real*8 x

      do i=1,np
        do j=1,nd
          call random_number(x)
          pos(j,i) = box(j)*x
          vel(j,i) = 0.0
          acc(j,i) = 0.0
        enddo
      enddo

      return
      end

! Compute the displacement vector (and its norm) between two particles.
      subroutine dist(nd,box,r1,r2,dr,d)
      implicit none

      integer nd
      real*8 box(nd)
      real*8 r1(nd)
      real*8 r2(nd)
      real*8 dr(nd)
      real*8 d

      integer i

      d = 0.0
      do i=1,nd
        dr(i) = r1(i) - r2(i)
        d = d + dr(i)**2.
      enddo
      d = sqrt(d)

      return
      end

! Return the dot product between two vectors of type real*8 and length n
      real*8 function dotr8(n,x,y)
      implicit none

      integer n
      real*8 x(n)
      real*8 y(n)

      integer i

      dotr8 = 0.0
      do i = 1,n
        dotr8 = dotr8 + x(i)*y(i)
      enddo

      return
      end

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Perform the time integration, using a velocity Verlet algorithm
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      subroutine update(np,nd,pos,vel,f,a,mass,dt)
      implicit none

      integer np
      integer nd
      real*8  pos(nd,np)
      real*8  vel(nd,np)
      real*8  f(nd,np)
      real*8  a(nd,np)
      real*8  mass
      real*8  dt

      integer i, j
      real*8  rmass

      rmass = 1.0/mass

      ! The time integration is fully parallel
!$omp parallel do &
!$omp default(shared) &
!$omp private(i,j)
      do i = 1,np
        do j = 1,nd
          pos(j,i) = pos(j,i) + vel(j,i)*dt + 0.5*dt*dt*a(j,i)
          vel(j,i) = vel(j,i) + 0.5*dt*(f(j,i)*rmass + a(j,i))
          a(j,i) = f(j,i)*rmass
        enddo
      enddo
!$omp end parallel do

      return
      end

