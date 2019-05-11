#!/usr/bin/env python3



from gmsk import modulator, chansim, utility, burstgen, feedforward
import sys
import matplotlib.pyplot as plt
import numpy as np
import scipy.signal as signal



samples_per_symbol = 16



if (len(sys.argv) == 2):
    data_dir = sys.argv[1]
else:
    data_dir = "../"
gmsk_modu = modulator.warmup(samples_per_symbol)
ts = (0,0,1,0,0,1,0,1,1,1,0,0,0,0,1,0,0,0,1,0,0,1,0,1,1,1)

ts_cut =       (1,0,1,1,1,0,0,0,0,1,0,0,0,1,0,0)
smol_modu = modulator.warmup(2)

modulated_ts = modulator.modulate(burstgen.diffencode(ts_cut), 2, smol_modu)
modulated_ts =modulated_ts[14:49]

plt.rc('lines',marker='x',markersize=4,linewidth=1)
plt.tight_layout()

plt.plot(np.real(modulated_ts))
plt.plot(np.imag(modulated_ts))


plt.tight_layout()
plt.show()


cir = chansim.channel_ir(chansim.TE_1, samples_per_symbol)
for i in range(0,32):

    nb = burstgen.normal_burst(utility.prbs(58),ts,utility.prbs(58))
    differential_syms = burstgen.diffencode(nb)
    sig = modulator.modulate(differential_syms, samples_per_symbol, gmsk_modu)

    z = sig[70:]
    z = chansim.channel_sim(z, cir, samples_per_symbol)

    z = chansim.awgn(z,20, bits_per_symbol=2, samples_per_symbol=samples_per_symbol)
    z = chansim.freq_phase_error(z, np.random.random_sample() * 2 * np.pi, 0.001)

    z = signal.decimate(z,8)
    sig = signal.decimate(sig,8)

    realz = np.sign(np.real(z))
    imagz = np.sign(np.imag(z))
    pseudosyms = 2 * realz + imagz

    headbits = np.zeros(8)
    tailbits = np.zeros(8)
    symbol_array = np.concatenate((headbits,differential_syms,tailbits))

    plt.plot(np.real(z)+6)
    plt.plot(np.imag(z)+12)
    plt.plot(np.real(sig)+16)
    plt.plot(np.imag(sig)+18)
    plt.step(np.linspace(0,len(symbol_array),len(symbol_array)),symbol_array +22 )
    plt.plot(pseudosyms)
    plt.plot(24+np.abs(np.correlate(z,modulated_ts))/8)
    print(np.argmax(np.abs(np.correlate(z,modulated_ts))))


plt.tight_layout()

plt.show()
