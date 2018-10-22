#!/usr/bin/env python3


from math import *

samples = 128
bitdepth = 7

curve_table_1 = open("gmsk_curve_1.hex",'w')
curve_table_2 = open("gmsk_curve_2.hex",'w')
curve_table_3 = open("gmsk_curve_3.hex",'w')
curve_table_7 = open("gmsk_curve_7.hex",'w')

curve_table_1_plain = open("gmsk_curve_1.txt",'w')
curve_table_2_plain = open("gmsk_curve_2.txt",'w')
curve_table_3_plain = open("gmsk_curve_3.txt",'w')
curve_table_7_plain = open("gmsk_curve_7.txt",'w')

#### MASTER CURVES ####

def master_curve_one(t):
    return conv(t+0.1)
def master_curve_two(t):
    return conv(t+0.2)
def master_curve_three(t):
    return conv(t+0.3)
def master_curve_seven(t):
    return conv(t+0.4)

#### float to binary ####

def scale(val, bits):
    norm = (2 ** (bits-1)-1)
    if (val < 0):
        val = 0
    return ceil(val * norm)

def conv(v):
    return scale(v, bitdepth)

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

    
