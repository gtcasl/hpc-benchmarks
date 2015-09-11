#!/bin/bash

#programs[0]="./microbenchmarks/compute 2000000000"
#programs[1]="./microbenchmarks/memory 50000000"
programs[0]="./HPCCG-1.0/HPCCG.x.openmp 64 64 64"
programs[1]="./miniFE-2.0/miniFE-2.0_openmp_opt/src/miniFE.x nx=100 ny=100 nz=100"
#programs[1]="./miniFE-2.0/miniFE-2.0_ref/src/miniFE.x nx=100 ny=100 nz=100"
#programs[2]="./lulesh2.0.3/lulesh2.0.mpi "
programs[2]="./lulesh2.0.3/lulesh2.0.openmp "
programs[3]="./graph500-2.1.4/omp-csr/graph500.x -s 20"
#programs[3]="./graph500-2.1.4/mpi/graph500_mpi_simple -s 20"
programs[4]="./NPB3.3/NPB3.3-OMP/bin/bt.A "
programs[5]="./NPB3.3/NPB3.3-OMP/bin/cg.A "
programs[6]="./NPB3.3/NPB3.3-OMP/bin/dc.A "
programs[7]="./NPB3.3/NPB3.3-OMP/bin/ep.A "
programs[8]="./NPB3.3/NPB3.3-OMP/bin/ft.A "
programs[9]="./NPB3.3/NPB3.3-OMP/bin/is.A "
programs[10]="./NPB3.3/NPB3.3-OMP/bin/lu.A "
programs[11]="./NPB3.3/NPB3.3-OMP/bin/mg.A "
programs[12]="./NPB3.3/NPB3.3-OMP/bin/sp.A "
programs[13]="./NPB3.3/NPB3.3-OMP/bin/ua.A "
#programs[14]="./microbenchmarks/idle "

last_idx=`expr ${#programs[@]} - 1`
for program_idx in `seq 0 $last_idx`
do
    export OMP_NUM_THREADS=1
    export OMP_PROC_BIND=TRUE
    /home/eric/intel_pcm/IntelPerformanceCounterMonitorV2.8/pcm.x -nc -nsys -csv=tmp.csv -- ${programs[$program_idx]} 
    cat tmp.csv >> base.pcm.csv
    rm tmp.csv
#    max_threads=`nproc`
#    for nthreads in `seq 1 $max_threads`
#    do
#        export OMP_NUM_THREADS=$nthreads
#        export OMP_PLACES=sockets
#        export OMP_PROC_BIND=TRUE
#        /home/eric/intel_pcm/IntelPerformanceCounterMonitorV2.8/pcm.x -nc -nsys -csv=tmp.csv -- ${programs[$program_idx]} 
#        if [ -f raw.pcm.csv ]
#        then
#            echo "" >> raw.pcm.csv
#            tail -1 tmp.csv >> raw.pcm.csv
#            rm tmp.csv
#        else
#            mv tmp.csv raw.pcm.csv
#        fi
#    done
#    chmod 666 raw.pcm.csv
    #name=`echo "${programs[$program_idx]}" | awk '{print $1}' | awk -F "/" '{print $NF}'`
    #echo "name: $name"
    #paste -d "," <(echo -e "application\n$name") wrapped.csv >> results.csv
    #rm wrapped.csv
    #chmod 666 results.csv
done
