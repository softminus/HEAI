#!/usr/bin/env python3

import math

samples = 64
scale = 32
volume = 1.0


for i in range(0,samples):
    x = math.pi*(i+1)/(2 *samples)
    f = "{:04x}"
    val = int(math.sin(x)*scale)
    print(f.format(val))

