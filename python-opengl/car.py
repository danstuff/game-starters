from pyglet.gl import *

import math
import util

import mesh
import door

CARLEN = 22.0
CARWID = 7.4

BENLEN = 7.4
BENWID = 1.5

OUT_OF_BOUNDS = -10000

MAX_SPD = 10.0

class Car:
    body = None
    seats = None
    windows = None
    doors = []

    offset = 0

    pos = 0.0
    speed = 0.0

    def load(self, foldername, offset):
        self.body = mesh.Mesh()
        self.body.load(foldername+"/body.obj", (255, 0, 0, 255))

        self.seats = mesh.Mesh()
        self.seats.load(foldername+"/bench.obj", (0, 255, 0, 255))

        self.windows = mesh.Mesh()
        self.windows.load(foldername+"/window.obj", (100, 0, 0, 10))

        self.doors.append(door.Door())
        self.doors[0].load(foldername, -CARWID/2-0.5)

        self.doors.append(door.Door())
        self.doors[1].load(foldername, CARWID/2-0.5)

        self.offset = offset

    def copy(self, o, offset):
        self.body = mesh.Mesh()
        self.body.copy(o.body)

        self.seats = mesh.Mesh()
        self.seats.copy(o.seats)

        self.doors.append(door.Door())
        self.doors[0].copy(o.doors[0], -CARWID/2+0.5)

        self.doors.append(door.Door())
        self.doors[1].copy(o.doors[1], CARWID/2-0.5)

        self.offset = offset

    def run(self, dt):
        if self.speed != 0:
            self.pos += self.speed*dt
            self.translate((0,0,self.speed*dt))

        for door in self.doors:
            door.run(self.speed, dt)

    def translate(self, fac):
        self.body.translate(fac)
        self.seats.translate(fac)
        self.windows.translate(fac)
        
        for door in self.doors:
            for mdl in door.mdl:
                mdl.translate(fac)

    def inbounds(self, pos):
        cz = self.pos+self.offset*CARLEN
        c00 = [-CARWID/2, -100, -CARLEN/2+cz]
        c10 = [CARWID/2, -100, -CARLEN/2+cz]
        c11 = [CARWID/2, 100, CARLEN/2+cz]
        c01 = [-CARWID/2, -100, CARLEN/2+cz]

        if util.inbox(pos, c00, c11):
            if ((pos[0] < -CARWID/2 + BENWID or
                pos[0] > CARWID/2 - BENWID) and
                (pos[1] < -CARLEN/2 + BENLEN or
                pos[1] > CARLEN/2 - BENLEN)): 
                    return 0.5
            return 1
        
        return OUT_OF_BOUNDS 

