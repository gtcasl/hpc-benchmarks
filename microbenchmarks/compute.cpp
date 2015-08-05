#include <iostream>
#include <cstdlib>
#include <omp.h>
#include <random>

// the number of 64bit words in 1gb
#define BUFSIZE 15625000

using namespace std;

int main(int argc, char* argv[]){
  if(argc != 5){
    cerr << "Usage: " << argv[0] << " <compute_factor> <memory_factor> <granularity> <max_iters>\n";
    return -1;
  }

  long compute_factor = atol(argv[1]);
  long memory_factor = atol(argv[2]);
  long granularity = atol(argv[3]);
  long max_iters = atol(argv[4]);
  long compute_iters = compute_factor * granularity;
  long memory_iters = memory_factor * granularity;
  long iterations = max_iters / granularity;


#pragma omp parallel
{
  auto num_threads = omp_get_num_threads();
  auto tid = omp_get_thread_num();
  if(tid == 0){
    cout << "Starting parallel computation with " << num_threads << " threads\n";
  }
  double* buffer = (double*)malloc(BUFSIZE * sizeof(double));
  random_device rd;
  mt19937 mt(rd());
  uniform_real_distribution<double> real_dist(0,1);
  uniform_int_distribution<int> int_dist(0,BUFSIZE);
  for(long i = 0; i < BUFSIZE; ++i){
    buffer[i] = real_dist(mt);
  }

#pragma omp for
  for(long i = 0; i < iterations; ++i){
    // Compute
    for(long c = 0; c < compute_iters; ++c){
      long x = c * long{23453};
    }
    // Memory
    for(long m = 0; m < memory_iters; ++m){
      double x = buffer[int_dist(mt)];
    }
  }
}

  return 0;
}

