#!/usr/bin/env python3

import math

samples = 64
scale = 16
volume = 1.0


for i in range(0,samples):
    x = math.pi*(i+1)/(2 *samples)
    f = "6'b{:06b}: quarter_sin = 4'b{:04b};"
    val = int(math.sin(x)*scale)
    print(f.format(i, val))

print("""default: quarter_sin = 4'b0000; // should never happen """);
