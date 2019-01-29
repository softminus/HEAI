#!/usr/bin/env python3


from math import *
import os
import sys
import random


samples_per_symbol = 64

def gnuplotize(data):
    outf = open(os.path.join(data_dir, "python_out.txt"), 'w')
    for idx, val in enumerate(data):
        f = "{:d} {:f}"
        print (f.format(idx, val), file=outf)

if (len(sys.argv) == 2):
    data_dir = sys.argv[1]
else:
    data_dir = "../.."

path = "verilog_out.txt"
f = open(os.path.join(data_dir,path),'r')

lines = f.read()
x = list(map((lambda x:str.split(x,' ')),str.split(lines,'\n')))

x.pop() #get rid of newline


i_samples = list(map(lambda x:(int(x[1])-255), x))
q_samples = list(map(lambda x:(int(x[2])-255), x))

samples = list(map(lambda x,y: x/255.0+y/255.0*1j, i_samples, q_samples))

print(samples)

energy = list(map(lambda x: abs(x), samples))


gnuplotize(energy)

def conj(x):
    z = x.real - x.imag * 1j
    return z

def corr_amp(needle, haystack):
    assert(len(needle) == len(haystack))
    return abs(sum(list(map(lambda x, y: x * conj(y), needle, haystack))))

hajime = 641


def shift_eye(seq, offset):
    return samples[(hajime + 30)*samples_per_symbol + offset: (hajime+50)*samples_per_symbol +offset]

pseudomidamble = shift_eye(samples, 0)

print(len(pseudomidamble))

corrs = []
for i in range(-4000,4000):
    corrs.append(corr_amp(pseudomidamble,shift_eye(samples,i)))

gnuplotize(corrs)