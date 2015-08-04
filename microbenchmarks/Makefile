all: compute idle

compute: compute.cpp
	g++ -O0 -std=c++11 -fopenmp -o compute compute.cpp

idle: idle.cpp
	g++ -O0 -std=c++11 -fopenmp -o idle idle.cpp

.PHONY: clean all

clean:
	@rm compute idle
