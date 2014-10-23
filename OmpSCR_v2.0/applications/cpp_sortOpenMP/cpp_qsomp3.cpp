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
 * @file cpp_qsomp3.cpp
 *
 * @brief OpenMP sorting implementation using a custom, iterative quicksort
 * with local stacks (to reduce accesses to the global stack and therefore
 * critical sections) and an insertion sort for small partitions.
 *
 * @warning THIS VERSION IS NOT SAFE ON ALL PLATTFORMS, AS IT DOES NOT PROPERLY
 * PROTECT THE CALL TO AN STL-FUNCTION (see comment in code)! ONLY USE, IF YOU
 * HAVE A THREAD-SAFE STL AVAILABLE! To put things in perspective, the code
 * should still do the right thing, when your STL is not thread-safe, but it
 * might not get you optimal performance, as the globalTodoStack might not
 * be managed properly. To make it more likely, that the code does "the right
 * thing (TM)", a flush has been added beforehand.
 *
 * Originally written for the EWOMP'04 in Stockholm, this program is part of
 * a larger collection of programs, which were written to discover some
 * problems with the present state of the OpenMP-specification.
 *
 *
 */
/*******************************************************************************
  FILE:              cpp_qsomp3.cpp
  VERSION:           1.0
  DATE:              Nov 2004
  AUTHOR:            Michael Süß
  COMMENTS TO:       ompscr@etsii.ull.es
  DESCRIPTION:       OpenMP sorting implementation using a custom, iterative quicksort 
                     with local stacks (to reduce accesses to the global stack and therefore critical 
                     sections) and an insertion sort for small partitions.
  COMMENTS:          Version 3
  REFERENCES:        www.se.e-technik.uni-kassel.de/se/fileadmin/pm/publications/suess/sortOpenMP.pdf
  BASIC PRAGMAS:     parallel critical flush
  USAGE:             ./cpp_qsomp3.par 1000000 2 1000
  INPUT:             The number of integers to sort, number of threads and switchThresh
  OUTPUT:            The code tests the correctness of the result for the input
  FILE FORMATS:      -
  RESTRICTIONS:      THIS VERSION IS NOT SAFE ON ALL PLATTFORMS, AS IT DOES NOT PROPERLY
                     PROTECT THE CALL TO AN STL-FUNCTION (see comment in code)! ONLY USE, IF YOU
                     HAVE A THREAD-SAFE STL AVAILABLE! To put things in perspective, the code
                     should still do the right thing, when your STL is not thread-safe, but it
                     might not get you optimal performance, as the globalTodoStack might not
                     be managed properly. To make it more likely, that the code does "the right
                     thing (TM)", a flush has been added beforehand.
  REVISION HISTORY:
**************************************************************************/

#include <iostream>
#include <vector>
#include <utility>
#include <stack>
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
 * iterative version of quicksort. For every iteration, one resulting partition
 * is processed in the next iteration, while the other gets pushed either on a
 * global stack (if that is near empty) or on a thread-local stack.
 *
 * When the partition to be sorted is smaller than the parameter switchThresh,
 * insertion sort is called instead.
 *
 * numBusyThreads marks the number of threads doing any work atm., which is used
 * to determine, when all threads are done and are therefore supposed to exit
 * the function.
 *
 * globalstackWrite is used for debugging purposes, it logs the number of times
 * that a value was put on the stack. globalStackRead logs the same thing for
 * reads of the global stack. Whenever a local stack is accessed, localStackOp
 * is increased.
 */
template < typename T >
	void myQuickSort(std::vector < T > &myVec, int q, int r,
					 const int switchThresh, std::stack < std::pair < int,
					 int > >&globalTodoStack, int &numBusyThreads,
					 const int numThreads,
					 std::vector < int >&globalStackWrite,
					 std::vector < int >&globalStackRead,
					 std::vector < int >&localStackOp)
{
	T pivot;
	int i, j;

	/* this pair consists of the new q and r values */
	std::pair < int, int >myBorder;

	/* local todo stack for each thread. we are using these extra stacks to
	 * avoid critical sections (in the critical path of the program)
	 * as much as possible */
	std::stack < std::pair < int, int > >localTodoStack;

	/* this variable indicates, whether the present thread does useful work atm */
	bool idle = true;

	/* only thread number 0 does useful work in the beginning */
	if (q != r)
		idle = false;

	while (true) {

		/* is the partition to be processed smaller than a certain threshhold?
		 * -> then use insertion sort */
		if (r - q < switchThresh) {
			myInsertSort(myVec, q, r);
			/* and mark the region as sorted, by setting q to r, which makes
			 * the thread run into the next while loop, where it requests
			 * new work
			 */
			q = r;
		}

		/* are we done with this part of the vector?
		 * -> then pop another one off one of the todo-stacks and process it
		 */
		while (q >= r) {

			/* something left on the local stack to do? */
			if (false == localTodoStack.empty()) {
				/* "idle = false" is not necessary here, since it must be set
				 * this way here already */
				myBorder = localTodoStack.top();
				localTodoStack.pop();
				q = myBorder.first;
				r = myBorder.second;
				localStackOp[omp_get_thread_num()]++;

				/* nothing left to do on the local stack */
			} else {
				/* only one thread at the time should access the todo-Stack and
				 * the numBusyThreads and idle variables */
#				pragma omp critical
				{
					/* something left on the global stack to do? */
					if (false == globalTodoStack.empty()) {
						if (true == idle)
							++numBusyThreads;
						idle = false;
						myBorder = globalTodoStack.top();
						globalTodoStack.pop();
						q = myBorder.first;
						r = myBorder.second;
						globalStackWrite[omp_get_thread_num()]++;

						/* nothing left to do on both stacks */
					} else {
						if (false == idle)
							--numBusyThreads;
						idle = true;

						/* busy wait here (not optimal) */
					}
				}	/* end critical section */

				/* if all threads are done, break out of this function
				 * note, that the value of numBusyThreads is current, as there
				 * is a flush implied at the end of the last critical section */
				if (numBusyThreads == 0) {
					return;
				}
			}	/* end else */

		}	/* end while ( q >= r ) */


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

		/* only push on the stack, if there is enough left to do */
		if (i - 1 - q > switchThresh) {
			myBorder = std::make_pair(q, i - 1);

			/* flush, cause we need an accurate value of the size of the global
			 * todo stack. we should have to flush only this variable, but
			 * at present this is not possible, as it is a reference variable.
			 *
			 * Note that this is not sufficient to produce an accurate value of
			 * the size of the globalTodoStack on a non-threadsafe STL, but on
			 * the other hand a mistake here does not make the code incorrect,
			 * but merely leads to a performance decrease.
			 */
#			pragma omp flush

			/* this border is basically just a guess, we want the global
			 * stack to be as full as necessary, yet as empty as possible */
			if (globalTodoStack.size() < numThreads) {
#				pragma omp critical
				{
					globalTodoStack.push(myBorder);
				}
				globalStackWrite[omp_get_thread_num()]++;
				globalStackRead[omp_get_thread_num()]++;

			} else {
				localTodoStack.push(myBorder);
				localStackOp[omp_get_thread_num()]++;
			}
		} else {
			/* for small partitions use insertion sort */
			myInsertSort(myVec, q, i - 1);
		}

		q = i + 1;
		/* r stays the same for the next iteration */
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
	std::stack < std::pair < int, int > >globalTodoStack;
	int numThreads;
	int numEntries;
	int switchThresh;
	char *PARAM_NAMES[NUM_ARGS] = {"Number of integer to sort:", "Number of threads:", "SwitchThresh:"};
	char *TIMERS_NAMES[NUM_TIMERS] = {"Total_time" };
	char *DEFAULT_VALUES[NUM_ARGS] = {"10000000", "1", "1000"};


	/* this number indicates, how many threads are doing useful work atm. */
	int numBusyThreads = 1;

	/* used for time measurements */
	double accTime;

	/* used for performance measurements */
	std::vector < int >globalStackWrite, globalStackRead, localStackOp;



	numThreads = omp_get_max_threads();
	OSCR_init (numThreads, "QuickSort", "", NUM_ARGS,
		PARAM_NAMES, DEFAULT_VALUES , NUM_TIMERS, NUM_TIMERS, TIMERS_NAMES,
		argc, argv);

	/* initialize the performance measures */
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
#	pragma omp parallel shared(myVec, globalTodoStack, numThreads, \
		switchThresh, numBusyThreads, globalStackWrite, globalStackRead, \
		localStackOp)
	{
		/* start sorting with only one thread, the others wait for the stack
		 * to fill up
		 */
		if (0 == omp_get_thread_num()) {
			myQuickSort(myVec, 0, myVec.size() - 1, switchThresh,
						globalTodoStack, numBusyThreads, numThreads,
						globalStackWrite, globalStackRead, localStackOp);
		} else {
			myQuickSort(myVec, 0, 0, switchThresh, globalTodoStack,
						numBusyThreads, numThreads, globalStackWrite,
						globalStackRead, localStackOp);
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

	int globalStackWriteSum = 0, globalStackReadSum = 0, localStackOpSum = 0;
	/* sum up and print out all performance measures */
	for (int i = 0; i < numThreads; ++i) {
		globalStackWriteSum += globalStackWrite[i];
		globalStackReadSum += globalStackRead[i];
		localStackOpSum += localStackOp[i];
		std::cout << i << ".: gSW: " << globalStackWrite[i] << " gSR: "
			<< globalStackRead[i] << " lSO: " << localStackOp[i] << "\n";
	}
	std::cout << std::
		endl << "Total: gSW: " << globalStackWriteSum << " gSR: " <<
		globalStackReadSum << " lSO: " << localStackOpSum << "\n\n";
	OSCR_report();
	return 0;
}
