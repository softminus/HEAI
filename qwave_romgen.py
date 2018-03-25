#!/usr/bin/env python3

import math

samples = 64
scale = 15


for i in range(0,samples):
    x = math.pi*(i+0.5)/(2*samples)
    f = "{:04x}"
    val = int(math.sin(x)*scale)
    print(f.format(val))

