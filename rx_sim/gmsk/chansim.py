#!/usr/bin/env python3


import numpy as np

RA_1 = [(0,1), (0.2,0.63), (0.4,0.1), (0.6,0.01)]
RA_2 = [(0,1), (0.1,0.4), (0.2,0.16), (0.3,0.06), (0.4,0.03), (0.5,0.01)]

TU_1 = [(0,0.4), (0.2,0.5), (0.4,1), (0.6,0.63),(0.8,0.5),(1.2,0.32),(1.4,0.2),(1.8,0.32),(2.4,0.25),(3.0,0.13),(3.2,0.08),(5.0,0.1)]
TU_2 = [(0,0.4), (0.1,0.5), (0.3,1), (0.5,0.55),(0.8,0.5),(1.1,0.32),(1.3,0.2),(1.7,0.32),(2.3,0.22),(3.1,0.14),(3.2,0.08),(5.0,0.1)]

BU_1 = [(0,0.2), (0.2,0.5), (0.4,0.79), (0.8,1),(1.6,0.63),(2.2,0.25),(3.2,0.2),(5.0,0.79),(6.0,0.63),(7.2,0.2),(8.2,0.1),(10.0,0.03)]
BU_2 = [(0,0.17), (0.1,0.46), (0.3,0.74), (0.7,1),(1.6,0.59),(2.2,0.28),(3.1,0.18),(5.0,0.72),(6.0,0.69),(7.2,0.21),(8.1,0.1),(10.0,0.03)]

HT_1 = [(0,0.1), (0.2,0.16), (0.4,0.25), (0.6,0.4),(0.8,1),(2.0,1),(2.4,0.4),(15.0,0.16),(15.2,0.13),(15.8,0.1),(17.2,0.06),(20.0,0.04)]
HT_2 = [(0,0.1), (0.1,0.16), (0.3,0.25), (0.5,0.4),(0.7,1),(1.0,1),(1.3,0.4),(15.0,0.16),(15.2,0.13),(15.7,0.1),(17.2,0.06),(20.0,0.04)]


def channel_ir(chantype, samples_per_symbol):
    microsecond = samples_per_symbol * (48.0/13.0)
    cir = np.zeros(74*samples_per_symbol,dtype=complex)

    for tap in chantype:
        position = round(tap[0] * microsecond)
        coefficient = tap[1]
        cir[position] = coefficient

    return cir


def channel_sim(signal, cir, samples_per_symbol):
    echo_extended = np.zeros(len(signal)+74*samples_per_symbol,dtype=complex)
    echo_extended[0:signal.shape[0]]       = signal
    return np.convolve(echo_extended,cir,'full')

# https://www.mathworks.com/help/comm/ref/comm.awgnchannel-system-object.html#buiamu7-1-SNR
# https://www.mathworks.com/help/comm/ug/awgn-channel.html

def awgn(signal, ebno, bits_per_symbol, samples_per_symbol):
    signal_amplitude = np.var(signal)
    noise_amplitude = (samples_per_symbol * signal_amplitude) / \
                (np.power(10, ebno/10))
    #print(noise_amplitude)
    #print(signal_amplitude)
    noise_r = np.random.randn(len(signal))
    noise_i = np.random.randn(len(signal))
    return signal + ((noise_r + 1j * noise_i) * (noise_amplitude/2.0))