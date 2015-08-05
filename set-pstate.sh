#!/bin/bash

cpupower -c all frequency-set -g userspace
cpupower -c all frequency-set -f 2.0GHz
