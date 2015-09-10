all: compute idle memory

compute: compute.cpp
	g++ -O0 -std=c++11 -fopenmp -o compute compute.cpp

idle: idle.cpp
	g++ -O0 -std=c++11 -fopenmp -o idle idle.cpp

memory: memory.cpp
	g++ -O0 -std=c++11 -fopenmp -o memory memory.cpp

.PHONY: clean all

clean:
	@rm compute idle
