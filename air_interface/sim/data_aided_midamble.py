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
    data_dir = os.getcwd()

path = "verilog_out.txt"
f = open(os.path.join(data_dir,path),'r')

lines = f.read()
x = list(map((lambda x:str.split(x,' ')),str.split(lines,'\n')))

x.pop() #get rid of newline


i_samples = list(map(lambda x:(int(x[1])-255), x))
q_samples = list(map(lambda x:(int(x[2])-255), x))

samples = list(map(lambda x,y: x+y*1j, i_samples, q_samples))

print(samples)

energy = list(map(lambda x: abs(x), samples))


gnuplotize(energy)

