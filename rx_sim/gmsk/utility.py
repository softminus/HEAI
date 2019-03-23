#!/usr/bin/env python3

import numpy as np


def gnuplotize(data):
    outf = open(os.path.join(data_dir, "python_out.txt"), 'w')
    for idx, val in enumerate(data):
        f = "{:f} {:f}"
        print (f.format(idx/samples_per_symbol, val), file=outf)

def prbs(length):
    return (np.random.randint(0,2,length) * 2 - 1)