#!/bin/bash

programs[0]="./microbenchmarks/compute 1000000000"
programs[1]="./HPCCG-1.0/HPCCG.x 64 64 64"
#programs[2]="./miniFE-2.0/miniFE-2.0_openmp_opt/src/miniFE.x nx=100 ny=100 nz=100"
#programs[13]="./lulesh2.0.3/lulesh2.0 "
#programs[14]="./graph500-2.1.4/omp-csr/graph500.x -s 20"
#programs[3]="./NPB3.3/NPB3.3-OMP/bin/bt.A "
#programs[4]="./NPB3.3/NPB3.3-OMP/bin/cg.A "
#programs[5]="./NPB3.3/NPB3.3-OMP/bin/dc.A "
#programs[6]="./NPB3.3/NPB3.3-OMP/bin/ep.A "
#programs[7]="./NPB3.3/NPB3.3-OMP/bin/ft.A "
#programs[8]="./NPB3.3/NPB3.3-OMP/bin/is.A "
#programs[9]="./NPB3.3/NPB3.3-OMP/bin/lu.A "
#programs[10]="./NPB3.3/NPB3.3-OMP/bin/mg.A "
#programs[11]="./NPB3.3/NPB3.3-OMP/bin/sp.A "
#programs[12]="./NPB3.3/NPB3.3-OMP/bin/ua.A "

last_idx=`expr ${#programs[@]} - 1`
for program_idx in `seq 0 $last_idx`
do
    for nthreads in `seq 1 8`
    do
        export OMP_NUM_THREADS=$nthreads
        export OMP_PLACES=cores
        export OMP_PROC_BIND=TRUE
        /home/eric/eaudit/tracing/eaudit-wrapper \
            -t \
            -i "threads=$nthreads" \
            -p "PAPI_L3_TCM" \
            -p "PAPI_TOT_INS" \
            -p "PAPI_LST_INS" \
            -p "PAPI_BR_INS" \
            -g "rapl:::PACKAGE_ENERGY:PACKAGE0" \
            -g "rapl:::PP0_ENERGY:PACKAGE0" \
            ${programs[$program_idx]}
    done
    name=`echo "${programs[$program_idx]}" | awk '{print $1}' | awk -F "/" '{print $NF}'`
    paste <(echo -e "application\n$name") wrapped.csv >> results.csv
    rm wrapped.csv
    chmod 666 results.csv
done
