from pyglet.gl import *

import math
import util

import mesh

class Entity:
    head = None
    torso = None
    arms = []
    legs = []

    def load(self, foldername, headname, color):
        self.head = mesh.Mesh()
        self.head.load(headname, color)

        self.torso = mesh.Mesh()
        self.torso.load(foldername+"/torso.obj", color)

        self.arms.append(mesh.Mesh())
        self.arms[0].load(foldername+"/arm top.obj", color)

        self.arms.append(mesh.Mesh())
        self.arms[1].load(foldername+"/arm bottom.obj", color)

        self.arms.append(mesh.Mesh())
        self.arms[2].load(foldername+"/arm top.obj", color)
        self.arms[2].scale((-1, 1, 1))

        self.arms.append(mesh.Mesh())
        self.arms[3].load(foldername+"/arm bottom.obj", color)
        self.arms[3].scale((-1, 1, 1))

        self.legs.append(mesh.Mesh())
        self.legs[0].load(foldername+"/leg top.obj", color)

        self.legs.append(mesh.Mesh())
        self.legs[1].load(foldername+"/leg bottom.obj", color)

        self.legs.append(mesh.Mesh())
        self.legs[2].load(foldername+"/leg top.obj", color)
        self.legs[2].scale((-1, 1, 1))

        self.legs.append(mesh.Mesh())
        self.legs[3].load(foldername+"/leg bottom.obj", color)
        self.legs[3].scale((-1, 1, 1))

    def run():
        pass
