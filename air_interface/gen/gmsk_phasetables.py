#!/usr/bin/env python3


from math import *
import os
import sys
import random

rom_index_bits = 5
samples = 2**rom_index_bits
bitdepth = 5

beta = pi * 0.3 * sqrt(2 / log(2))

def erfint(normalised_time): # normalised time goes from 0 to 1 to represent 0 to T_b
    erfi = normalised_time * erf(beta * normalised_time) + (1 / ( beta *sqrt(pi))) * exp(-((beta*normalised_time)**2))
    return erfi


def traj_one(t):
    return 0.5 * pi * (erfint(t-1) -1)

def traj_two(t):
    return 0.5 * pi * (erfint(t) - erfint(0.0) - erfint(t-1) + 1 - t)

def traj_three(t):
    return 0.5 * pi * (erfint(t) - erfint(0.0))

def traj_seven(t):
    return 0.5 * pi * t

if (len(sys.argv) == 2):
    outdir = sys.argv[1]
else:
    outdir = os.getcwd()

curve_table_1 = open(os.path.join(outdir,"gmsk_curve_1.hex"),'w')
curve_table_2 = open(os.path.join(outdir,"gmsk_curve_2.hex"),'w')
curve_table_3 = open(os.path.join(outdir,"gmsk_curve_3.hex"),'w')
curve_table_7 = open(os.path.join(outdir,"gmsk_curve_7.hex"),'w')
half_mask     = open(os.path.join(outdir,"half_mask.hex"   ),'w')

curve_table_1_plain = open(os.path.join(outdir,"gmsk_curve_1.txt"),'w')
curve_table_2_plain = open(os.path.join(outdir,"gmsk_curve_2.txt"),'w')
curve_table_3_plain = open(os.path.join(outdir,"gmsk_curve_3.txt"),'w')
curve_table_7_plain = open(os.path.join(outdir,"gmsk_curve_7.txt"),'w')
half_mask_plain     = open(os.path.join(outdir,"half_mask.txt"   ),'w')



def fixup_phase_one(t):
    return (-traj_one(t))

def fixup_phase_two(t):
    return traj_two(t) + 2 * (sqrt(log(2)/(2*pi))/(4*0.3))

def fixup_phase_three(t):
    return traj_three(t) + 2 * (sqrt(log(2)/(2*pi))/(4*0.3))

def fixup_phase_seven(t):
    return traj_seven(t)


#### MASTER CURVES ####

def master_curve_one(t):
    return conv(sin(fixup_phase_one(t)))

def master_curve_two(t):
    return conv(sin(fixup_phase_two(t)))

def master_curve_three(t):
    return conv(sin(fixup_phase_three(t)))

def master_curve_seven(t):
    return conv(sin(fixup_phase_seven(t)))

#### float to binary ####

def scale(val, bits):
    norm = (2 ** (bits)-1)
    if (val < 0):
        val = 0
    return round(val * norm)

def conv(v):
    return scale(v, bitdepth)

#### power mask ####
def scale_prim(val, bits):
    norm = (2 ** (bits))
    if (val < 0):
        val = 0
    return round(val * norm)


def power_mask_raw(t):
    if (t > 1):
        return 1
    return pow(sin(t*pi/2),2)

def master_power_mask(t):
    return scale_prim(power_mask_raw(t),5)

for i in range(0,samples):  # from zero (inclusive) to 64 (EXCLUSIVE)
    time = i/samples        # time from 0 to 1 (to represent real time 0 to T_b)
    f = "{:04x}"
    print (f.format(master_curve_one(time))   , file=curve_table_1)
    print (f.format(master_curve_two(time))   , file=curve_table_2)
    print (f.format(master_curve_three(time)) , file=curve_table_3)
    print (f.format(master_curve_seven(time)) , file=curve_table_7)

    print (i,       master_curve_one(time)    , file=curve_table_1_plain)
    print (i,       master_curve_two(time)    , file=curve_table_2_plain)
    print (i,       master_curve_three(time)  , file=curve_table_3_plain)
    print (i,       master_curve_seven(time)  , file=curve_table_7_plain)

for i in range(0,256):
    time = i/256
    f = "{:04x}"
    print (f.format(master_power_mask(time))  , file=half_mask)
    print (i,       master_power_mask(time)   , file=half_mask_plain)
