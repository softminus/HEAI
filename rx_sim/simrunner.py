#!/usr/bin/env python3



from gmsk import modulator, chansim, utility, burstgen, feedforward
import sys
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider, Button, RadioButtons

import numpy as np
import math
import scipy.signal as signal


fig, ax = plt.subplots()
#plt.subplots_adjust(left=0.25, bottom=0.25)

samples_per_symbol = 8

#derotate_master = [1, -1j, -1, 1j]


derotate_master = np.exp(1j* (-np.pi/4 * np.arange(8)))
if (len(sys.argv) == 2):
    data_dir = sys.argv[1]
else:
    data_dir = "../"

gmsk_modu = modulator.warmup(samples_per_symbol)
ts = (0,1,0,0,0,0,0,1,0,0,1,1,0,1,0,1,0,0,1,1,1,1,0,0,1,1)

ts_cut = ts[5:26-5]



smol_modu = modulator.warmup(1)
modulated_ts = modulator.modulate(burstgen.diffencode(ts_cut), 1, smol_modu)



#modulated_ts =modulated_ts[28:95]

plt.rc('lines',marker='x',markersize=4,linewidth=1)

#plt.plot(np.real(modulated_ts))
#plt.plot(np.imag(modulated_ts))


#plt.tight_layout()
#plt.show()



cir = chansim.channel_ir(chansim.TE_1, samples_per_symbol)

nb = burstgen.normal_burst(utility.prbs(58),ts,utility.prbs(58))



def generate_waves(delay_val):
    differential_syms = burstgen.diffencode(nb)
    sig = modulator.modulate(differential_syms, samples_per_symbol, gmsk_modu)

    z = sig[delay_val:]
    #z = chansim.channel_sim(z, cir, samples_per_symbol)

    #z = chansim.awgn(z,20, bits_per_symbol=2, samples_per_symbol=samples_per_symbol)
    #z = chansim.freq_phase_error(z, np.random.random_sample() * 2 * np.pi, 0.001)

    z = signal.decimate(z,math.floor(samples_per_symbol/2))
    sig = signal.decimate(sig,math.floor(samples_per_symbol/2))

    derotate = np.tile(derotate_master, math.ceil(len(z)/4))

    z = z * derotate[0:len(z)]
    #realz = np.sign(np.real(z))
    #imagz = np.sign(np.imag(z))
    #pseudosyms = 2 * realz + imagz

    #headbits = np.zeros(8)
    #tailbits = np.zeros(8)
    #symbol_array = np.concatenate((headbits,differential_syms,tailbits))

    return (z, sig)

z, sig = generate_waves(0)

plt.plot(nb)
realz, = plt.plot(np.real(z)+6)
imagz, = plt.plot(np.imag(z)+12)
realsig, = plt.plot(np.real(sig)+16)
imagsig, = plt.plot(np.imag(sig)+18)
constellation = plt.plot(np.real(z), np.imag(z))
#corre, = plt.plot(24+np.abs(np.correlate(z,modulated_ts))/8)

def update(delay_val):
    z, sig = generate_waves(int(delay_val))
    
    realz.set_data(np.arange(len(z)),np.real(z)+6)
    imagz.set_data(np.arange(len(z)), np.imag(z)+12)

    realsig.set_data(np.arange(len(sig)), np.real(sig)+16)    
    imagsig.set_data(np.arange(len(sig)), np.imag(sig)+18)
    #corre.set_data(np.arange(len(np.correlate(z,modulated_ts))), 24+np.abs(np.correlate(z,modulated_ts))/8)

    #plt.step(np.linspace(0,len(symbol_array),len(symbol_array)),symbol_array +22 )
    #plt.plot(pseudosyms)
    constellation.set_data(np.real(z), np.imag(z))
    #print(np.argmax(np.abs(np.correlate(z,modulated_ts))))
    fig.canvas.draw_idle()



axcolor = 'lightgoldenrodyellow'
axdelay = plt.axes([0.2,0.02,0.65,0.03], facecolor=axcolor)

delayslider = Slider(axdelay, 'Delay', 0, 256, valinit=0, valstep=1)
delayslider.on_changed(update)
#plt.axes([0.1,0.2,0.8,0.65])
#plt.xlim(0,600)
#plt.ylim(0,30)
plt.show()
