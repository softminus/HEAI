#!/usr/bin/env python3


# inputs are a samples_per_symbol parameter and a message string
# composed of {-1,1} symbols. 

# output is an array of complex samples.

from math import *
import os
import sys
import random
import matplotlib.pyplot as plt
import numpy as np

samples_per_symbol = 16

def gnuplotize(data):
    outf = open(os.path.join(data_dir, "python_out.txt"), 'w')
    for idx, val in enumerate(data):
        f = "{:f} {:f}"
        print (f.format(idx/samples_per_symbol, val), file=outf)

if (len(sys.argv) == 2):
    data_dir = sys.argv[1]
else:
    data_dir = "../.."



def qfun(x):
    return (0.5 * erfc(x/(sqrt(2))))

x = np.linspace(-10,10)

z = np.vectorize(qfun)(x)


plt.plot(x,z)
plt.show()
