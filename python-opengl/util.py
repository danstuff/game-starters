from pyglet.gl import *

import math
import random

Q = []
c = 0
i = 4095

def seed(x):
    global Q, c
    m = 2**32
    a = 22695477 

    c = x

    for i in range(4096):
        x = (a*x + 1) % m
        Q.append(x)

def rand():
    global i, c, Q
    #this is a CMWC adapted from a C program
    #by G. Marsaglia
    a = 18782
    r = 4294967294

    i = (i+1) & 4095
    t = a*Q[i]+c
    c = t>>32

    x = t+c

    if x < c:
        x += 1
        c += 1

    Q[i] = r-x

    return Q[i]

def roll(odds):
    rn = (rand() % 1000) / 1000.0

    for i in range(len(odds)):
        rn -= odds[i]

        if rn <= 0:
            return i

def interpolate(points, row, pos):
    #get interpolated z value from a lower-def grid of points
    #z and y values are swapped in this function
    gap = points[3] - points[0]

    x = pos[0] / gap
    y = pos[2] / gap 

    x0 = math.floor(x)
    y0 = math.floor(y)

    x1 = math.ceil(x)
    y1 = math.ceil(y)

    z00 = points[(x0+(y0*row))*3 + 1]
    z01 = points[(x0+(y1*row))*3 + 1]
    z11 = points[(x1+(y1*row))*3 + 1]
    z10 = points[(x1+(y0*row))*3 + 1]

    if ((x1 - x0)*(y1 - y0)) == 0:
        return 0

    return (z00*(x1 - x)*(y1- y) + 
            z10*(x - x0)*(y1 - y) + 
            z01*(x1 - x)*(y - y0) + 
            z11*(x - x0)*(y - y0)) / ((x1 - x0)*(y1 - y0))

def lp2(array):
    return range(int(len(array)/2))

def lp3(array):
    return range(int(len(array)/3))

def lp4(array):
    return range(int(len(array)/4))

def lock(var, btm, top):
    if var < btm:
        var = btm

    if type(top) != None:
        if var > top:
            var = top

    return var

def inbox(pos, bmn, bmx):
    return (pos[0] > bmn[0] and
        pos[0] < bmx[0] and
        pos[1] > bmn[1] and
        pos[1] < bmx[1] and
        pos[2] > bmn[2] and
        pos[2] < bmx[2])

def mult3x3(v, m):
    v[0] = m[0]*v[0] + m[1]*v[1] + m[2]*v[2]
    v[1] = m[3]*v[0] + m[4]*v[1] + m[5]*v[2]
    v[2] = m[6]*v[0] + m[7]*v[1] + m[8]*v[2]

