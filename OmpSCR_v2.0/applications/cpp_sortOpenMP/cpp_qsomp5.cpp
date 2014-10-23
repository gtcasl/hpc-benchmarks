/*
 * Copyright (c) 2004 Michael Süß  All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/**
 * @author Michael Süß
 *
 * @file cpp_qsomp5.cpp
 *
 * @brief OpenMP sorting implementation using a custom, recursive quicksort
 * with nesting and an insertion sort for small partitions.
 *
 * Originally written for the EWOMP'04 in Stockholm, this program is part of
 * a larger collection of programs, which were written to discover some
 * problems with the present state of the OpenMP-specification.
 *
 * @attention Although this code will run on any specification-compliant
 * OpenMP-compiler, many compilers will serialize the nested parallel regions,
 * which means that you will not see a speedup bigger than 2 with them!
 * The only compiler I am presently aware of that has "proper" nesting support
 * is the Intel Compiler.
 *
 */

/*******************************************************************************
  FILE:              cpp_qsomp5.cpp
  VERSION:           1.0
  DATE:              Nov 2004
  AUTHOR:            Michael Süß
  COMMENTS TO:       ompscr@etsii.ull.es
  DESCRIPTION:       OpenMP sorting implementation using a custom, recursive quicksort
                     with nesting and an insertion sort for small partitions.
  COMMENTS:          Version 5: Although this code will run on any specification-compliant
                     OpenMP-compiler, many compilers will serialize the nested parallel regions,
                     which means that you will not see a speedup bigger than 2 with them!
                     The only compiler I am presently aware of that has "proper" nesting support
                     is the Intel Compiler.
  REFERENCES:        www.se.e-technik.uni-kassel.de/se/fileadmin/pm/publications/suess/sortOpenMP.pdf
  BASIC PRAGMAS:     parallel sections atomic
  USAGE:             ./cpp_qsomp5.par 1000000 2 1000
  INPUT:             The number of integers to sort, number of threads and switchThresh
  OUTPUT:            The code tests the correctness of the result for the input
  FILE FORMATS:      -
  RESTRICTIONS:   
  REVISION HISTORY:
**************************************************************************/

#include <iostream>
#include <vector>
#include <utility>
#include <ctime>
#include <cstring>

#include "OmpSCR.h"


/**
 * This is needed for calculating seconds from microseconds for measurements of
 * the wall-clock time.
 */
#define NUM_ARGS	3
#define NUM_TIMERS	1


/** An insertion sort.
 * This kicks in for small partitions (<switchThresh) and sequentially sorts
 * the partition of myVec between the indices q and r. Used here, because it is
 * faster than quicksort for small partitions.
 *
 * @param myVec the vector to be sorted
 * @param q index of the left border of the partition to be sorted
 * @param r index of the right border of the partition to be sorted
 */
template < typename T >
	void inline myInsertSort(std::vector < T > &myVec, int q, int r)
{
	int i, j;

	if (q >= r)
		return;

	i = q + 1;
	do {
		j = i;
		while ((j > q) && (myVec[j - 1] > myVec[j])) {
			std::swap(myVec[j - 1], myVec[j]);
			--j;
		}
		++i;
	} while (i <= r);
}


/** A quicksort function.
 * This sorts the partition of myVec between the indices q and r using an
 * recursive version of quicksort. At the moment, for each new level of
 * recursion a new nested parallel region is opened, if and only if
 * numBusyThreads is still smaller than numThreads. Note that this way of
 * limiting the recursion depth is still suboptimal, as with this way of doing
 * things not all threads might be busy all the time.
 *
 * When the partition to be sorted is smaller than the parameter switchThresh,
 * insertion sort is called instead.
 */
template < typename T >
	void myQuickSort(std::vector < T > &myVec, int q, int r,
					 const int switchThresh, int &numBusyThreads,
					 const int numThreads)
{
	T pivot;
	int i, j;


	/* done with this part of the vector? -> exit function */
	if (q >= r)
		return;

	/* is the partition to be processed smaller than a certain threshhold?
	 * -> then use insertion sort and exit function afterwards */
	if (r - q < switchThresh) {
		myInsertSort(myVec, q, r);
		return;
	}

	/* now actually sort our partition */

	/* choose pivot, initialize borders */
	pivot = myVec[r];
	i = q - 1;
	j = r;

	/* partition step, which moves smaller numbers to the left
	 * and larger numbers to the right of the pivot */
	while (true) {
		while (myVec[++i] < pivot);
		while (myVec[--j] > pivot);
		if (i >= j)
			break;
		std::swap(myVec[i], myVec[j]);
	}

	std::swap(myVec[i], myVec[r]);

	/* recursively call yourself with new subpartitions,
	 * i is index of pivot
	 * when not all threads are busy, create new nesting level, else just call
	 * the functions in the same thread. this might lead to unemployed threads!
	 *
	 * Attention: numBusyThreads is not the real number of busy threads, but
	 * a number that is 2 times the number of real threads -1! This comes from
	 * the way we add to it further down, for each new section we are adding
	 * 2 to its value, but only one new thread is created, the other section is
	 * carried out by the same thread! Nevertheless, we must count like this,
	 * because we have no way of knowing, in which thread to count down the
	 * variable, so we are counting down in both.
	 */
	if (numBusyThreads >= 2 * numThreads - 1) {
		myQuickSort(myVec, q, i - 1, switchThresh, numBusyThreads,
					numThreads);
		myQuickSort(myVec, i + 1, r, switchThresh, numBusyThreads,
					numThreads);
	} else {
		/* we have one more working thread now, but need to increase this value
		 * by two, since we do not know, which parallel section will be
		 * processed by the current thread. This leads to severe
		 * underutilization of the threads involved, but I do not know a better
		 * way to handle this atm. Can be worked around by increasing the
		 * threadnumber to check against in the outer if-clause to 2*numThreads
		 */
#		pragma omp atomic
		numBusyThreads += 2;

#		pragma omp parallel shared(myVec, numThreads, numBusyThreads, \
			switchThresh, q, i, r)
		{
#			pragma omp sections nowait
			{
#				pragma omp section
				{
					myQuickSort(myVec, q, i - 1, switchThresh,
								numBusyThreads, numThreads);

#					pragma omp atomic
					numBusyThreads--;
				}

#				pragma omp section
				{
					myQuickSort(myVec, i + 1, r, switchThresh,
								numBusyThreads, numThreads);

#					pragma omp atomic
					numBusyThreads--;
				}
			}
		}
	}
}


/** checks, if the vector myVec is sorted by size.
  *
  * @return true, if sorted ok, false if not.
  */
template < typename T > bool vectorValidate(std::vector < T > &myVec)
{
	T temp = myVec[0];

	for (typename std::vector < T >::size_type i = 1; i < myVec.size();
		 ++i) {
		if (myVec[i] < temp)
			return false;
		temp = myVec[i];
	}

	return true;
}


/** main function with initialization, command line argument parsing,
  * memory allocation, OpenMP setup, wall--clock time measurement.
  */
int main(int argc, char *argv[])
{

	std::vector < int >myVec;
	int numThreads, numBusyThreads = 1;
	int numEntries;
	int switchThresh;
	char *PARAM_NAMES[NUM_ARGS] = {"Number of integer to sort:", "Number of threads:", "SwitchThresh:"};
	char *TIMERS_NAMES[NUM_TIMERS] = {"Total_time" };
	char *DEFAULT_VALUES[NUM_ARGS] = {"10000000", "1", "1000"};
	/* used for time measurements */
	double accTime;


	numThreads = omp_get_max_threads();
	OSCR_init (numThreads, "QuickSort", "", NUM_ARGS,
		PARAM_NAMES, DEFAULT_VALUES , NUM_TIMERS, NUM_TIMERS, TIMERS_NAMES,
		argc, argv);

	/* check and assign  command line parameters */
	numEntries = OSCR_getarg_int(1);
	numThreads = OSCR_getarg_int(2);
	switchThresh = OSCR_getarg_int(3);


	/* this is special. for this version, we only want two threads per team,
	 * since we are nesting */
	omp_set_num_threads(2);

	/* initialize random number generator to fixed seed. this is done, so
	 * that every run of the algorithm is sorting the exact same vector.
	 * this way, we can compare runs easily */
	//std::srand( std::time(0) );
	std::srand(123);

	/* Reserve sufficient capacity for vector once and for all */
	myVec.reserve(myVec.size() + numEntries);

	/* fill the vector with random numbers */
	for (int i = 0; i < numEntries; ++i) {
		myVec.push_back(std::rand());
	}

	/* Start measuring the time */
	OSCR_timer_start(0);

	/* sort vector in parallel */
	myQuickSort(myVec, 0, myVec.size() - 1, switchThresh, numBusyThreads,
				numThreads);

	/* Finish time measurement */
	OSCR_timer_stop(0);

	/* calculate elapsed time */
	accTime = OSCR_timer_read(0);


	/* determine and print out, whether or not the vector was sorted ok */
	if (vectorValidate(myVec))
		std::cout << "\nSuccess, wall-clock time: " << accTime << "\n\n";
	else
		std::cout << "\nSorting FAILED!" << "\n\n";

	OSCR_report();
	return 0;
}
