#!/bin/bash

programs[0]="./NPB3.3.1-MZ/NPB3.3-MZ-MPI/bin/bt-mz.A"
programs[1]="./NPB3.3.1-MZ/NPB3.3-MZ-MPI/bin/lu-mz.A"
programs[2]="./NPB3.3.1-MZ/NPB3.3-MZ-MPI/bin/sp-mz.A"

serial[0]="./NPB3.3.1-MZ/NPB3.3-MZ-SER/bin/bt-mz.A.x"
serial[1]="./NPB3.3.1-MZ/NPB3.3-MZ-SER/bin/lu-mz.A.x"
serial[2]="./NPB3.3.1-MZ/NPB3.3-MZ-SER/bin/sp-mz.A.x"

threads_per_core=`lscpu | grep "Thread(s)" | awk '{print $4}'`
tot_threads=`nproc`
max_threads=`echo "$tot_threads / $threads_per_core" | bc`
echo "max threads: $max_threads"

# check idle power
echo "=== Checking idle power"
/home/eric/eaudit/tracing/eaudit-wrapper \
            -t \
            -p "PAPI_BR_INS" \
            -g "rapl:::PACKAGE_ENERGY:PACKAGE0" \
            -g "rapl:::DRAM_ENERGY:PACKAGE0" \
            -g "rapl:::PACKAGE_ENERGY:PACKAGE1" \
            -g "rapl:::DRAM_ENERGY:PACKAGE1" \
            ./microbenchmarks/idle
mv wrapped.csv idle.csv
chmod 666 idle.csv


last_idx=`expr ${#programs[@]} - 1`
for program_idx in `seq 0 $last_idx`
do
    name=`echo "${programs[$program_idx]}" | awk '{print $1}' | awk -F "/" '{print $NF}'`
    echo "name: $name"
    for nthreads in `seq 1 $max_threads`
    do
        #command="/usr/bin/mpirun -np $nthreads --bycore --bind-to-core ${programs[$program_idx]}"
        export OMP_NUM_THREADS=$nthreads
        export OMP_PLACES=sockets
        export OMP_PROC_BIND=TRUE
        #if [[ $command == *"NPB"* ]]
        #then
        #    command=$command.$nthreads
        #fi
        if [ $nthreads -eq 1 ]
        then
            echo "=== Executing serial"
            command=${serial[$program_idx]}
        else
            echo "=== Executing parallel, Nthreads = $nthreads"
            command=${programs[$program_idx]}.1
        fi
        echo "=== Command: $command"
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
            $command
    done
    echo "=== Done with program $name, appending to results"
    paste -d "," <(echo -e "application\n$name") wrapped.csv >> results.csv
    rm wrapped.csv
    chmod 666 results.csv
    chmod 666 raw.pcm.csv
done
