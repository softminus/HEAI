#!/usr/bin/env python3


from gmsk import modulator
import os
import sys
import matplotlib.pyplot as plt
import numpy as np



samples_per_symbol = 8



if (len(sys.argv) == 2):
    data_dir = sys.argv[1]
else:
    data_dir = "../"

rangez = np.linspace(0,160,num=160*samples_per_symbol)
range_echoez = np.linspace(0,164,num=164*samples_per_symbol)

gmsk_modu = modulator.warmup(samples_per_symbol)

print(len(rangez))

for i in range(0,1):
    symbol_array = np.random.randint(0,2,150) * 2 - 1
    hadaka = np.zeros_like(rangez)
    z = modulator.modulate(symbol_array, samples_per_symbol, gmsk_modu)
    plt.plot(np.imag(z))
    plt.plot(np.real(z))

plt.show()
