#!/bin/bash

programs[0]="./microbenchmarks/compute"
#programs[1]="./HPCCG-1.0/HPCCG.x 64 64 64"
#programs[2]="./miniFE-2.0/miniFE-2.0_openmp_opt/src/miniFE.x nx=100 ny=100 nz=100"
#programs[3]="./lulesh2.0.3/lulesh2.0 "
#programs[4]="./graph500-2.1.4/omp-csr/graph500.x -s 20"
#programs[5]="./NPB3.3/NPB3.3-OMP/bin/bt.A "
#programs[6]="./NPB3.3/NPB3.3-OMP/bin/cg.A "
#programs[7]="./NPB3.3/NPB3.3-OMP/bin/dc.A "
#programs[8]="./NPB3.3/NPB3.3-OMP/bin/ep.A "
#programs[9]="./NPB3.3/NPB3.3-OMP/bin/ft.A "
#programs[10]="./NPB3.3/NPB3.3-OMP/bin/is.A "
#programs[11]="./NPB3.3/NPB3.3-OMP/bin/lu.A "
#programs[12]="./NPB3.3/NPB3.3-OMP/bin/mg.A "
#programs[13]="./NPB3.3/NPB3.3-OMP/bin/sp.A "
#programs[14]="./NPB3.3/NPB3.3-OMP/bin/ua.A "
#programs[1]="./microbenchmarks/idle "

last_idx=`expr ${#programs[@]} - 1`
for program_idx in `seq 0 $last_idx`
do
    for work in 100000000 200000000 400000000 800000000 1600000000 3200000000 6400000000 
    do
        export OMP_NUM_THREADS=12
        export OMP_PLACES=sockets
        export OMP_PROC_BIND=TRUE
        /home/eric/eaudit/tracing/eaudit-wrapper \
            -t \
            -i "threads=12" \
            -p "PAPI_L3_TCM" \
            -p "PAPI_TOT_INS" \
            -p "PAPI_LD_INS" \
            -p "PAPI_SR_INS" \
            -p "PAPI_BR_INS" \
            -g "rapl:::PACKAGE_ENERGY:PACKAGE0" \
            -g "rapl:::DRAM_ENERGY:PACKAGE0" \
            -g "rapl:::PACKAGE_ENERGY:PACKAGE1" \
            -g "rapl:::DRAM_ENERGY:PACKAGE1" \
            ${programs[$program_idx]} $work
    done
    name=`echo "${programs[$program_idx]}" | awk '{print $1}' | awk -F "/" '{print $NF}'`
    paste <(echo -e "application\n$name") wrapped.csv >> results.csv
    rm wrapped.csv
    chmod 666 results.csv
done
