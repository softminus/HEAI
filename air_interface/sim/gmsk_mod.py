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


bt = 0.3
sigma = sqrt(np.log(2) / (4 * np.pi * np.pi * (bt*bt)))
bigT = 1


def qfun(x):
    return (0.5 * erfc(x/(sqrt(2))))

def frequency_shaping_pulse(x):
    scale = 1/(2*bigT)
    firstQ  = qfun((x/bigT - 0.5)/sigma)
    secondQ = qfun((x/bigT + 0.5)/sigma)
    return (scale * (firstQ - secondQ))


def bigPhi(x):
    return (1.0 - qfun(x))

def bigG(x):
    first_half  = x * bigPhi(x/sigma)
    second_half = (sigma / sqrt(2*np.pi)) * np.exp(-(x*x)/(2*sigma*sigma))
    return first_half+second_half

def phase_shaping_pulse(x):
    foo = bigG((x / bigT) + 0.5) - bigG((x / bigT) - 0.5)
    return 0.5 * foo

def multisymbols(x):
    return phase_shaping_pulse(x) - phase_shaping_pulse(x-5) + phase_shaping_pulse(x-1)

x = np.linspace(-20,20,num=20*100)
z = np.vectorize(multisymbols)(x)


plt.plot(x,z)
plt.show()
