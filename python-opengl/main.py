import pyglet

from pyglet.gl import *

from pyglet.window import key
from pyglet.window import mouse

from pyglet.clock import *

import math
import util

import mesh
import entity
import player
import train

WINDOW = 0

WIDTH, HEIGHT = 640, 480
TITLE = "SUBWAY"

FOV = 100.0
ZNEAR, ZFAR = 0.01, 1000.0

ttrain = None

def init():
    man = entity.Entity()

    global ttrain
    ttrain = train.Train()

    util.seed(19230)
    
    color = [util.rand()%255,
            util.rand()%255, 
            util.rand()%255, 255]

    man.load("models/male",
            "models/heads/cube.obj",
            color)
    ttrain.load("models/subway car", 2)

def run(dt):
    train.run(dt)

    player.move(dt)

    for tcar in ttrain.cars:
        tcy = tcar.inbounds(player.pos)
        tcp = tcar.inbounds(player.pos+player.rvel*2)

        if tcy != car.OUT_OF_BOUNDS:
            player.vel = [0.0, tcar.speed*dt] 
            player.elevation = tcy

            if tcp == car.OUT_OF_BOUNDS:
                player.rvel = [0.0, 0.0]

    player.commit(dt)

def draw():
    gluLookAt( player.pos[0],player.pos[1],player.pos[2],
            player.look[0],player.look[1],player.look[2],
            0.0,1.0,0.0)

    mesh.batch.draw()

window = pyglet.window.Window(WIDTH, HEIGHT)

@window.event
def on_draw():
    glEnable(GL_DEPTH_TEST)
    glEnable(GL_ALPHA_TEST)
    #glEnable(GL_CULL_FACE)

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glLoadIdentity()

    glViewport(0, 0, WIDTH, HEIGHT)

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    gluPerspective(FOV, WIDTH/HEIGHT, ZNEAR, ZFAR)

    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()

    draw()

@window.event
def on_mouse_motion(x, y, dx, dy):
    player.mouse = [dx, dy]

@window.event
def on_key_press(s, mod):
    if s == key.W:
        player.go(0)
    elif s == key.S:
        player.go(1)
    elif s == key.A:
        player.go(2)
    elif s == key.D:
        player.go(3)
    elif s == key.E:
        global tcar
        tcar.doors[0].open() 

@window.event
def on_key_release(s, mod):
    if s == key.W:
        player.stop(0)
    elif s == key.S:
        player.stop(1)
    elif s == key.A:
        player.stop(2)
    elif s == key.D:
        player.stop(3)

init()
window.set_exclusive_mouse(True)
pyglet.clock.schedule_interval(run, 0.01)
pyglet.app.run()
