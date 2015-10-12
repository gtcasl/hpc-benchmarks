#include <cmath>
#include <iostream>
#include <cstdlib>
#include <omp.h>

using namespace std;

int main(int argc, char* argv[]){
  if(argc != 2){
    cerr << "Usage: " << argv[0] << " <NUMITERS>\n";
    return -1;
  }

  long num_iters = atol(argv[1]);
  

#pragma omp parallel
{
  auto num_threads = omp_get_num_threads();
  auto tid = omp_get_thread_num();
  if(tid == 0){
    cout << "Starting parallel computation with " << num_threads << " threads\n";
  }
  //long tot_iters = num_iters * num_threads;
  float x = 0.0;
  for(long i = 0; i < num_iters; ++i){
    //sqrt(rand());
    x += 1.9f;
  }

}

  return 0;
}

