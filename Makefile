







CC:=gcc
OFLAGS:=--march=native -Ofast
CFLAGS:=-c -shared -fPIC -fopenmp


JULIA:=julia
MAIN:=src/main.jl


REDBENCH_NUM_THREADS?=1
OMP_NUM_THREADS?=$(REDBENCH_NUM_THREADS)
JULIA_NUM_THREADS:=$(REDBENCH_NUM_THREADS)



C_SOURCES:=src/c_native/c_native.cpp
C_LIBS:=$(FILES_IN:.cpp=.so)




run:
	$(JULIA) -t $(JULIA_NUM_THREADS) $(MAIN)




