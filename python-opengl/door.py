from pyglet.gl import *

import math
import util

import mesh

class Door:
    mdl = []

    zt = 0.0
    z = 0.0

    state = False

    def load(self, foldername, x):
        self.mdl.append(mesh.Mesh())
        self.mdl[0].load(foldername+"/door.obj", (255, 255, 0, 255))
        
        self.mdl.append(mesh.Mesh())
        self.mdl[1].load(foldername+"/door.obj", (255, 255, 0, 255))
        self.mdl[1].scale((1, 1, -1))

        self.mdl[0].translate((x, 0, 0))
        self.mdl[1].translate((x, 0, 0))

    def copy(self, o, x):
        #WARNING: only copy from objects at the origin
        #otherwise, positions will be unpredictable
        self.mdl.append(mesh.Mesh())
        self.mdl[1].copy(o.mdl[1])
        
        self.mdl.append(mesh.Mesh())
        self.mdl[1].copy(o.mdl[1])

        self.translate((x, 0, 0))

    def run(self, speed, dt):
        if self.z != self.zt:
            vz = (self.zt-self.z)*dt
            self.z += vz

            self.mdl[0].translate((0, 0, speed*dt-vz))
            self.mdl[1].translate((0, 0, speed*dt+vz))

    def open(self):
        self.state = True
        self.zt = -3

    def close(self):
        self.state = False
        self.zt = 0

    def isopen(self):
        return self.state
