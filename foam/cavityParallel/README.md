Benchmarking for cluster environment with openFOAM and SLURM as job Scheduler

The environment should be run as follows:

1 - OpenMPI/3.0.0 or another MPI compiler (such as MPICH and Intel) configured;

2 - OpenFOAM tool;

3 - Cluster environment configured;

4 - scipy or matplotlib, numpy and pandas dependencies (python >= 2.7);

steps to test:

$ source /foam-directory/etc/bashrc 
$ ./Allclean

edit system/decomposeParDict where numberOfSubdomains = $number_of_processors_available

and

```
simpleCoeffs
{
        n               ( 4 4 1 );
            delta           0.0001;
}
```
for this example has been used n ( 4 4 ...) this parameters should be change as of total of your processors. In this case, the total is 4 x 4 = 16

$ blockMesh (to create mesh for processing)

$ decomposePar -force (to split the mesh as of total processors able)

Configure "jobslurm.sh" according to what your hardware and resources.

$ sbatch jobslurm.sh (to running simulation)


