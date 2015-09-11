#!/bin/bash

#programs[0]="./microbenchmarks/compute 2000000000"
programs[0]="./HPCCG-1.0/HPCCG.x.mpi 64 64 64"
programs[1]="./miniFE-2.0/miniFE-2.0_ref/src/miniFE.x nx=100 ny=100 nz=100"
programs[2]="./lulesh2.0.3/lulesh2.0.mpi "
programs[3]="./graph500-2.1.4/mpi/graph500_mpi_simple 20"
programs[4]="./NPB3.3/NPB3.3-MPI/bin/bt.A "
programs[5]="./NPB3.3/NPB3.3-MPI/bin/cg.A "
#programs[6]="./NPB3.3/NPB3.3-OMP/bin/dc.A "
programs[6]="./NPB3.3/NPB3.3-MPI/bin/ep.A "
programs[7]="./NPB3.3/NPB3.3-MPI/bin/ft.A "
programs[8]="./NPB3.3/NPB3.3-MPI/bin/is.A "
programs[9]="./NPB3.3/NPB3.3-MPI/bin/lu.A "
programs[10]="./NPB3.3/NPB3.3-MPI/bin/mg.A "
programs[11]="./NPB3.3/NPB3.3-MPI/bin/sp.A "
#programs[13]="./NPB3.3/NPB3.3-OMP/bin/ua.A "
#programs[12]="./microbenchmarks/idle "

last_idx=`expr ${#programs[@]} - 1`
for program_idx in `seq 0 $last_idx`
do
    name=`echo "${programs[$program_idx]}" | awk '{print $1}' | awk -F "/" '{print $NF}'`
    echo "name: $name"
    max_threads=`nproc`
    for nthreads in `seq 1 $max_threads`
    do
        if [ $nthreads -eq 1 ]
        then
            /home/eric/intel_pcm/IntelPerformanceCounterMonitorV2.8/pcm.x -nc -nsys -csv=tmp.pcm.csv -- mpirun -np 1 --bycore --bind-to-core ${programs[$program_idx]} 
            if [ -f raw.pcm.csv ]
            then
                tail -1 tmp.pcm.csv >> raw.pcm.csv
            else
                cp tmp.pcm.csv raw.pcm.csv
            fi
            echo "$name" >> raw.pcm.csv
            rm tmp.pcm.csv
        fi
        /home/eric/eaudit/tracing/eaudit-wrapper \
            -t \
            -i "threads=$nthreads" \
            -p "PAPI_L3_TCM" \
            -p "PAPI_TOT_INS" \
            -p "PAPI_LD_INS" \
            -p "PAPI_SR_INS" \
            -p "PAPI_BR_INS" \
            -g "rapl:::PACKAGE_ENERGY:PACKAGE0" \
            -g "rapl:::DRAM_ENERGY:PACKAGE0" \
            -g "rapl:::PACKAGE_ENERGY:PACKAGE1" \
            -g "rapl:::DRAM_ENERGY:PACKAGE1" \
            mpirun -np $nthreads --bycore --bind-to-core ${programs[$program_idx]} &> /dev/null
    done
    paste -d "," <(echo -e "application\n$name") wrapped.csv >> results.csv
    rm wrapped.csv
    chmod 666 results.csv
done
