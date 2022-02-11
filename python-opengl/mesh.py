from pyglet.gl import *

import math
import os.path

import util

batch = pyglet.graphics.Batch()

class Mesh:
    content = None 

    def destroy(self):
        self.content.delete()

    def load(self, filename, color):
        vrts, inds, cols = [], [], []
        num = 0

        if os.path.isfile(filename):
            with open(filename) as file:
                for line in file:
                    if line[0] == "v" or line[0] == "f":
                        a = line.split(" ")
                        x = float(a[1])
                        y = float(a[2])
                        z = float(a[3])

                        if line[0] == "v":
                            vrts.extend((x, y, z))
                            cols.extend(color)
                            num += 1
                        elif line[0] == "f":
                            inds.extend((int(x-1), int(y-1), int(z-1)))
        else:
            print("[ERROR] File not found: " + filename)

        self.content = batch.add_indexed(
                num, 
                GL_TRIANGLES, 
                None,
                inds,
                ("v3f", vrts),
                ("c4B", cols))

    def copy(self, o):
        num = len(o.content.vertices)/3
        self.content = batch.add_indexed(
                num, 
                GL_TRIANGLES, 
                None,
                o.content.indices,
                ("v3f", o.content.vertices),
                ("c4B", o.content.colors))

    def translate(self, fac):
        vts = self.content.vertices
        for i in util.lp3(self.content.vertices):
            vts[i*3] += fac[0]
            vts[i*3+1] += fac[1]
            vts[i*3+2] += fac[2]

    def scale(self, fac):
        vts = self.content.vertices
        for i in util.lp3(self.content.vertices):
            vts[i*3] *= fac[0]
            vts[i*3+1] *= fac[1]
            vts[i*3+2] *= fac[2]

    def rotate(self, a, axis):
        m = []
        if axis == "x":
            m = [1, 0, 0,
                    0, math.cos(a), -math.sin(a),
                    0, math.sin(a), math.cos(a)]
        elif axis == "y":
            m = [math.cos(a), 0, math.sin(a),
                    0, 1, 0,
                    -math.sin(a), 0, math.cos(a)]
        elif axis == "z":
            m = [math.cos(a), -sin(a), 0,
                    math.sin(a), math.cos(a), 0,
                    0, 0, 1]

        vts = self.content.vertices
        for i in util.lp3(vts):
            util.mult3x3(vts[i*3:i*3+2], m)
