#!/usr/bin/env python3


from gmsk import modulator, chansim, utility
import os
import sys
import matplotlib.pyplot as plt
import numpy as np
import scipy.signal as sp



samples_per_symbol = 8



if (len(sys.argv) == 2):
    data_dir = sys.argv[1]
else:
    data_dir = "../"

rangez = np.linspace(0,160,num=160*samples_per_symbol)
range_echoez = np.linspace(0,164,num=164*samples_per_symbol)

gmsk_modu = modulator.warmup(samples_per_symbol)

print(len(rangez))
cir = chansim.channel_ir(chansim.BU_1, samples_per_symbol)
print(cir)
for i in range(0,1):
    symbol_array = utility.prbs(150)
    hadaka = np.zeros_like(rangez)
    sig = modulator.modulate(symbol_array, samples_per_symbol, gmsk_modu)
    #plt.plot(np.real(z)+6)
    #plt.plot(np.imag(z)+6)

    #z = chansim.channel_sim(sig, cir, samples_per_symbol)
    z = chansim.awgn(sig, 18, 2, samples_per_symbol=samples_per_symbol)
    z = sp.decimate(z,16)
    sig = sp.decimate(sig,16)
    plt.plot(np.real(z), np.imag(z))
    plt.plot(np.real(sig)+0, np.imag(sig)+3)
    plt.show()
    plt.plot(np.real(z))
    plt.plot(np.imag(z))
    plt.plot(np.real(sig)+5)
    plt.plot(np.imag(sig)+5)

plt.show()
