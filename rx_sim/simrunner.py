#!/usr/bin/env python3


from gmsk import modulator, chansim, utility, burstgen
import os
import sys
import matplotlib.pyplot as plt
import numpy as np
import scipy.signal as sp



samples_per_symbol = 16



if (len(sys.argv) == 2):
    data_dir = sys.argv[1]
else:
    data_dir = "../"

nb = burstgen.normal_burst(utility.prbs(58),utility.prbs(26),utility.prbs(58))
orig_syms = burstgen.diffencode(nb)

print(len(orig_syms))

#orig_syms =  #np.array([1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,-1,1,1,1,1,1,1,1,1,1,1,1,-1,1,-1,1,-1,1,-1,1,-1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]) #utility.prbs(150)

gmsk_modu = modulator.warmup(samples_per_symbol)
cir = chansim.channel_ir(chansim.RA_1, samples_per_symbol)
for i in range(0,4):
    symbol_array = orig_syms
    sig = modulator.modulate(symbol_array, samples_per_symbol, gmsk_modu)
    #plt.plot(np.real(z)+6)
    #plt.plot(np.imag(z)+6)

    #z = chansim.channel_sim(sig, cir, samples_per_symbol)
    z=sig
    z = chansim.awgn(z,9, bits_per_symbol=2, samples_per_symbol=samples_per_symbol)
    z = sp.decimate(z,samples_per_symbol)

    sig = sp.decimate(sig,samples_per_symbol)

    realz = np.sign(np.real(z))
    imagz = np.sign(np.imag(z))

    pseudosyms = 2 * realz + imagz
#    plt.plot(np.real(z), np.imag(z))
#    plt.plot(np.real(sig)+0, np.imag(sig)+3)
#    plt.show()
    headbits = np.zeros(8)
    tailbits = np.zeros(8)
    symbol_array = np.concatenate((headbits,symbol_array,tailbits))
    plt.plot(np.real(z)+6)
    plt.plot(np.imag(z)+12)
    plt.plot(np.real(sig)+16)
    plt.plot(np.imag(sig)+18)
    plt.plot(symbol_array + 20)
    plt.plot(pseudosyms )
#    ax = plt.axes()
#    ax.xaxis.set_major_locator(plt.MultipleLocator(1))


plt.show()
