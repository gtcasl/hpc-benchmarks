cpp_qsomp1.cpp:  OpenMP sorting implementation using a custom, iterative quicksort
                 and an insertion sort for small partitions.

cpp_qsomp2.cpp:  OpenMP sorting implementation using a custom, iterative quicksort
                 with local stacks (to reduce accesses to the global stack and therefore
                 critical sections) and an insertion sort for small partitions.

cpp_qsomp3.cpp:  OpenMP sorting implementation using a custom, iterative quicksort
                 with local stacks (to reduce accesses to the global stack and therefore critical
                 sections) and an insertion sort for small partitions.
                 THIS VERSION IS NOT SAFE ON ALL PLATTFORMS, AS IT DOES NOT PROPERLY
                 PROTECT THE CALL TO AN STL-FUNCTION (see comment in code)! ONLY USE, IF YOU
                 HAVE A THREAD-SAFE STL AVAILABLE! To put things in perspective, the code
                 should still do the right thing, when your STL is not thread-safe, but it
                 might not get you optimal performance, as the globalTodoStack might not
                 be managed properly. To make it more likely, that the code does "the right
                 thing (TM)", a flush has been added beforehand.

cpp_qsomp4.cpp:  OpenMP sorting implementation using a custom, iterative quicksort
                 with local stacks (to reduce accesses to the global stack and therefore
                 critical sections) and an insertion sort for small partitions.
                 THIS VERSION IS NOT SAFE ON ALL PLATTFORMS, AS IT DOES NOT PROPERLY
                 PROTECT THE CALL TO AN STL-FUNCTION (see comment in code)! OnLY USE, IF YOU
                 HAVE A THREAD-SAFE STL AVAILABLE! THE CODE HERE IS NOT CORRECT AND MIGHT
                 TO WRONG RESULTS, IF RUN WITH A NON-THREADSAFE STL. The reason that this
                 code exists at all is simple: if you have a threadsafe STL, it gets rid of
                 a critical section and should therefore make the code faster.

cpp_qsomp5.cpp:  OpenMP sorting implementation using a custom, recursive quicksort
                 with nesting and an insertion sort for small partitions.
                 Although this code will run on any specification-compliant
                 OpenMP-compiler, many compilers will serialize the nested parallel regions,
                 which means that you will not see a speedup bigger than 2 with them!
                 The only compiler I am presently aware of that has "proper" nesting support
                 is the Intel Compiler.

cpp_qsomp6.cpp:  OpenMP sorting implementation using a custom, iterative quicksort
                 with local stacks (to reduce accesses to the global stack and therefore
                 critical sections) and an insertion sort for small partitions. Also includes
                 checks to push the bigger partition on the stack and process the smaller
                 one, to reduce load on the stacks. 

cpp_qsomp7.cpp:  OpenMP sorting implementation using a custom, recursive quicksort
                 with a workqueue and an insertion sort for small partitions.
                 You need a compiler that supports the OpenMP--workqueuing model
                 (not part of the standard yet) such as the Intel Compiler 7.0 or later or
                 certain versions of the SUN-Compiler. Also note that the Intel compiler
                 has a special syntax (#pragma intel omp taskq) for the workqueuing model.



