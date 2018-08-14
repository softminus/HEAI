#!/usr/bin/env python3


from math import *

samples = 1024

delta = sqrt(2/log(2)) * pi * 0.337

def erfint(normalised_time): # normalised time goes from 0 to 1 to represent 0 to T_b
    erfi = pi/2 * normalised_time * erf( delta * normalised_time ) + (1/2) * (sqrt(pi) / delta) * exp(-(normalised_time**2))
    return erfi

def traj_three(t):
    return erfint(t) - erfint(0.0)

def traj_two(t):
    return erfint(t) - erfint(0.0) - erfint(t-1) + 1 - t

for i in range(0,samples+1):  # from zero (inclusive) to 64 (EXCLUSIVE)
    time = i/samples        # time from 0 to 1 (to represent real time 0 to T_b)
    print (time, traj_two(time))

    

