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



def multisymbols(syms, x):
    tot = 0
    for pos,val in enumerate(syms):
        tot = tot + val * phase_shaping_pulse(x-pos)
    
    return tot


pulserange = np.linspace(-4,4,num=8*samples_per_symbol)

stored_pulse = np.vectorize(phase_shaping_pulse)(pulserange)

#plt.plot(stored_pulse)
#plt.show()
rangez = np.linspace(0,32,num=32*samples_per_symbol)
range_echoez = np.linspace(0,36,num=36*samples_per_symbol)

modu = np.vectorize(multisymbols, excluded=['syms'])

def add_pulse(victim, idx, val):

    victim[idx:idx+stored_pulse.shape[0] ] += val * stored_pulse;
    victim[    idx+stored_pulse.shape[0]:] += val * np.ones_like(victim[idx+stored_pulse.shape[0]:])*0.5
    return victim

def multisymbols_two(syms, x):
    tot = 0
    for pos,val in enumerate(syms):
        x = add_pulse(x, pos * samples_per_symbol, val)
    return x

def cost(z):
    echo_extended = np.zeros(len(z)+4*samples_per_symbol)
    echo_extended[0:z.shape[0]]       = z
#    echo_extended[80:80+z.shape[0]]   += 0.1*z
#    echo_extended[120:120+z.shape[0]] += 0.1*z
#    echo_extended[140:140+z.shape[0]] += 0.1*z
#    echo_extended[190:190+z.shape[0]] += 0.1*z
#    echo_extended[400:400+z.shape[0]] += 0.5*z
    cir = np.zeros(4*samples_per_symbol)
    cir[0]=0.3
    cir[1] =0.1
    cir[3] =0.1
    cir[7] = 0.1
    cir[14] = 0.4
    return np.convolve(echo_extended,cir,'same')

print(len(rangez))
for i in range(0,1):
    symbol_array = np.random.randint(0,2,22) * 2 - 1
    hadaka = np.zeros_like(rangez)
    z = multisymbols_two(symbol_array, hadaka)
    #plt.plot(rangez, z)
    isam = np.cos((np.pi)*z)
    qsam = np.sin((np.pi)*z)
    plt.plot(rangez,isam)
    plt.plot(rangez,qsam)
##    plt.plot(cost(isam),cost(qsam))

    plt.plot(range_echoez, cost(qsam)+4)
    plt.plot(range_echoez, cost(isam)+4)
#    plt.plot(rangez, qsam)

plt.show()
