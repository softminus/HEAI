#!/usr/bin/env python3


from math  import *
import cmath
import numpy as np
import os
import sys
import random


samples_per_symbol = 64

def gnuplotize(data):
    outf = open(os.path.join(data_dir, "python_out.txt"), 'w')
    for idx, val in enumerate(data):
        f = "{:f} {:f}"
        print (f.format(idx/samples_per_symbol, val), file=outf)

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


energy = list(map(lambda x: abs(x), samples))


#gnuplotize(energy)

def conj(x):
    z = x.real - x.imag * 1j
    return z

def corr_amp(needle, haystack):
    assert(len(needle) == len(haystack))
    return abs(sum(list(map(lambda x, y: x * conj(y), needle, haystack))))

hajime = 580

syoff=60
def shift_eye(seq, offset):
    return samples[hajime + (syoff *samples_per_symbol) + offset: hajime+(syoff+16)*samples_per_symbol +offset]

def phase_error(phase_offset, z):
    ph = cmath.exp(1j*phase_offset)
    return list(map(lambda x:x*ph, z)) 

def freq_error(freq_error, z):
    slide = [cmath.exp(1j*freq_error*x) for x in range(len(z))]
    return list(map(lambda x,y:x*y, slide, z))

pseudomidamble = shift_eye(samples, 0)
print(len(pseudomidamble))

noise = np.random.normal(0,0.08,len(samples)) + 1j * np.random.normal(0,0.08,(len(samples)))
samples_noisy = list(sum(x) for x in zip(samples, np.ndarray.tolist(noise)))
#gnuplotize(samples_noisy)
corrs = []
loose = freq_error(-0.2,phase_error(0.21,samples_noisy))

for i in range(-2000,2000):
    corrs.append(corr_amp(pseudomidamble,shift_eye(loose,i)))

gnuplotize(corrs)