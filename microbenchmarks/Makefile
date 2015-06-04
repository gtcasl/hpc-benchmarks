all: compute

compute: compute.cpp
	g++ -O0 -std=c++11 -fopenmp -o compute compute.cpp

.PHONY: clean all

clean:
	@rm compute
