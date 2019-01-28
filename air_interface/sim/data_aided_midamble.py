#!/usr/bin/env python3


from math import *
import os
import sys
import random

if (len(sys.argv) == 2):
    data_dir = sys.argv[1]
else:
    data_dir = os.getcwd()
path = "verilog_out.txt"
f = open(os.path.join(data_dir,path),'r')
lines = f.read()

x = list(map((lambda x:str.split(x,' ')),str.split(lines,'\n')))
x.pop() #get rid of newline


i_samples = list(map(lambda x:int(x[1]), x))
q_samples = list(map(lambda x:int(x[2]), x))

samples = list(zip(i_samples,q_samples))

print(samples)

energy = list(map(lambda x: (x[0]-255)**2 + (x[1]-255)**2, samples))
print (energy)