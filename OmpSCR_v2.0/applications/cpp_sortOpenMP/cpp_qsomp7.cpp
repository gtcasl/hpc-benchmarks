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
 * @file cpp_qsomp7.cpp
 *
 * @brief OpenMP sorting implementation using a custom, recursive quicksort
 * with a workqueue and an insertion sort for small partitions.
 *
 * Originally written for the EWOMP'04 in Stockholm, this program is part of
 * a larger collection of programs, which were written to discover some
 * problems with the present state of the OpenMP-specification.
 *
 * @attention You need a compiler that supports the OpenMP--workqueuing model
 * (not part of the standard yet) such as the Intel Compiler 7.0 or later or
 * certain versions of the SUN-Compiler. Also note that the Intel compiler
 * has a special syntax (#pragma intel omp taskq) for the workqueuing model.
 *
 */

/*******************************************************************************
  FILE:              cpp_qsomp7.cpp
  VERSION:           1.0
  DATE:              Nov 2004
  AUTHOR:            Michael Süß
  COMMENTS TO:       ompscr@etsii.ull.es
  DESCRIPTION:       OpenMP sorting implementation using a custom, recursive quicksort
                     with a workqueue and an insertion sort for small partitions.
  COMMENTS:          Version 7
  REFERENCES:        www.se.e-technik.uni-kassel.de/se/fileadmin/pm/publications/suess/sortOpenMP.pdf
  BASIC PRAGMAS:     parallel intel taskq
  USAGE:             ./cpp_qsomp7.par 1000000 2 1000
  INPUT:             The number of integers to sort, number of threads and switchThresh
  OUTPUT:            The code tests the correctness of the result for the input
  FILE FORMATS:      -
  RESTRICTIONS:      You need a compiler that supports the OpenMP--workqueuing model
                     (not part of the standard yet) such as the Intel Compiler 7.0 or later or
                     certain versions of the SUN-Compiler. Also note that the Intel compiler
                     has a special syntax (#pragma intel omp taskq) for the workqueuing model.
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
 * recursion a new workqueue is opened. Limiting the recursion depth did not
 * result in a performance increase.
 *
 * When the partition to be sorted is smaller than the parameter switchThresh,
 * insertion sort is called instead.
 */
template < typename T >
	void myQuickSort(std::vector < T > &myVec, int q, int r,
					 const int switchThresh)
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
	 * each recursive function call is marked as a task, making parallel
	 * processing of them possible.
	 * note that this is only possible, because all partitions can be
	 * processed independently of each other.
	 */
#	pragma intel omp taskq
	{
#		pragma intel omp task
		{
			myQuickSort(myVec, q, i - 1, switchThresh);
		}
#		pragma intel omp task
		{
			myQuickSort(myVec, i + 1, r, switchThresh);
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
	int numThreads;
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

	numEntries = OSCR_getarg_int(1);
	numThreads = OSCR_getarg_int(2);
	switchThresh = OSCR_getarg_int(3);

	/* and run with the specified number of threads */
	omp_set_num_threads(numThreads);

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
#	pragma omp parallel shared (myVec, switchThresh, numThreads)
	{
#		pragma intel omp taskq
		{
#			pragma intel omp task
			{
				myQuickSort(myVec, 0, myVec.size() - 1, switchThresh);
			}
		}
	}

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
