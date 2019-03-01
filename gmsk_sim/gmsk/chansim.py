#!/usr/bin/env python3


import numpy as np


def cost(z, samples_per_symbol):
    microsecond = (samples_per_symbol / 270.8333333) * 1000
    echo_extended = np.zeros(len(z)+48*samples_per_symbol,dtype=complex)
    echo_extended[0:z.shape[0]]       = z
#    echo_extended[80:80+z.shape[0]]   += 0.1*z
#    echo_extended[120:120+z.shape[0]] += 0.1*z
#    echo_extended[140:140+z.shape[0]] += 0.1*z
#    echo_extended[190:190+z.shape[0]] += 0.1*z
#    echo_extended[400:400+z.shape[0]] += 0.5*z
    cir = np.zeros(48*samples_per_symbol, dtype=complex)
    cir[0                       ]=0.2
    cir[round(0.2 * microsecond)]=0.5
    cir[round(0.4 * microsecond)]=0.79
    cir[round(0.8 * microsecond)]=1
    cir[round(1.6 * microsecond)]=0.63
    cir[round(2.2 * microsecond)]=0.25
    cir[round(3.2 * microsecond)]=0.2
    cir[round(5.0 * microsecond)]=0.79
    cir[round(6.0 * microsecond)]=0.63
    cir[round(7.2 * microsecond)]=0.2
    cir[round(8.2 * microsecond)]=0.1
    cir[round(10.0* microsecond)]=0.03
    return np.convolve(echo_extended,cir,'full')
