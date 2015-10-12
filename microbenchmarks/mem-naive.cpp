#include <cmath>
#include <iostream>
#include <cstdlib>
#include <omp.h>
#include <unistd.h>

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
  for(long j = 0; j < num_iters; ++j){
    long long bytes = 256 * 1024 * 1024;
    long long stride = 4096;
    long long i;
    char *ptr = 0;
    char c;

    ptr = (char *) malloc (bytes * sizeof (char));

    for (i = 0; i < bytes; i += stride)
      ptr[i] = 'Z';           /* Ensure that COW happens.  */

    for (i = 0; i < bytes; i += stride){
      c = ptr[i];
      if (c != 'Z')
        {
          cerr << "WOOOOPSIES\n";
        }
    }

    free (ptr);
  }

}

  return 0;
}

