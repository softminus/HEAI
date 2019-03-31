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



#orig_syms = # np.array([1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,-1,1,1,1,1,1,1,1,1,1,1,1,-1,1,-1,1,-1,1,-1,1,-1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]) #utility.prbs(150)

gmsk_modu = modulator.warmup(samples_per_symbol)
cir = chansim.channel_ir(chansim.RA_1, samples_per_symbol)
for i in range(0,16):

    nb = burstgen.normal_burst(utility.prbs(58),(0,0,1,0,0,1,0,1,1,1,0,0,0,0,1,0,0,0,1,0,0,1,0,1,1,1),utility.prbs(58))
    orig_syms = burstgen.diffencode(nb)
    symbol_array = orig_syms
    sig = modulator.modulate(symbol_array, samples_per_symbol, gmsk_modu)
    #plt.plot(np.real(z)+6)
    #plt.plot(np.imag(z)+6)
    z = sig

    #z = chansim.channel_sim(z, cir, samples_per_symbol)

    z = chansim.awgn(z,6, bits_per_symbol=2, samples_per_symbol=samples_per_symbol)
    #z = chansim.freq_phase_error(z, np.random.random_sample() * 2 * np.pi, 0.01)
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

    plt.step(np.linspace(0,len(symbol_array),len(symbol_array)),symbol_array +22 )
    plt.plot(pseudosyms )
#    ax = plt.axes()
#    ax.xaxis.set_major_locator(plt.MultipleLocator(1))


plt.show()
