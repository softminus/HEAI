#!/usr/bin/env python3

import numpy as np
import scipy.signal as signal
import scipy.linalg as linalg



#training_sequence_symbols = burstgen.diffencode(ts[5:(16+5)])
#cirmat = np.asmatrix(linalg.circulant(training_sequence_symbols))
#print(linalg.pinv(cirmat))








#modulated_ts = modulator.modulate(burstgen.diffencode(ts), samples_per_symbol, gmsk_modu)

#modulated_ts[0:110]=0
#modulated_ts[540:]=0
#modulated_ts = signal.decimate(modulated_ts, samples_per_symbol)
#    plt.plot(np.abs(np.correlate(z, modulated_ts))+28)
