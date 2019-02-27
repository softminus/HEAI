#!/usr/bin/env python3


def cost(z):
    echo_extended = np.zeros(len(z)+4*samples_per_symbol,dtype=complex)
    echo_extended[0:z.shape[0]]       = z
#    echo_extended[80:80+z.shape[0]]   += 0.1*z
#    echo_extended[120:120+z.shape[0]] += 0.1*z
#    echo_extended[140:140+z.shape[0]] += 0.1*z
#    echo_extended[190:190+z.shape[0]] += 0.1*z
#    echo_extended[400:400+z.shape[0]] += 0.5*z
    cir = np.zeros(4*samples_per_symbol, dtype=complex)
    cir[0]=0.3
    cir[19]=0.3
    cir[26]=1j
    cir[31]=0.3
    return np.convolve(echo_extended,cir,'same')
