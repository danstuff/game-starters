import math
import util

MOVE_SPD = 10.0
LOOK_SPD = 1.0
HEIGHT = 1.0

#forward, back, right, left
head = [False, False, False, False]

mouse = [0.0, 0.0]
deg = [0.0, 0.0]

pos = [0.0, 0.0, 0.0]
look = [0.0, 0.0, 0.0]
vel = [0.0, 0.0]
rvel = [0.0, 0.0]

elevation = 0.0

def go(fblr):
    global head
    head[fblr] = True

def stop(fblr):
    global head
    head[fblr] = False

def move(dt):
    global rvel
    
    #determine rvelocity vector (vx, vz)
    rvel = [0.0, 0.0]

    if head[0] != head[1]:
        if head[0]:
            rvel[0] = MOVE_SPD*(look[0]-pos[0])*dt
            rvel[1] = MOVE_SPD*(look[2]-pos[2])*dt
        else:
            rvel[0] = -MOVE_SPD*(look[0]-pos[0])*dt
            rvel[1] = -MOVE_SPD*(look[2]-pos[2])*dt

    if head[2] != head[3]:
        if head[2]:
            rvel[0] = -MOVE_SPD*(-(look[2] - pos[2]))*dt
            rvel[1] = -MOVE_SPD*(look[0] - pos[0])*dt
        else:
            rvel[0] = MOVE_SPD*(-(look[2] - pos[2]))*dt
            rvel[1] = MOVE_SPD*(look[0] - pos[0])*dt

def commit(dt):
    global mouse, deg, look, pos

    #commit rvelocity to position
    pos[0] += vel[0]+rvel[0]
    pos[1] = elevation+HEIGHT
    pos[2] += vel[1]+rvel[1]

    #determine look vector 
    deg[0] -= mouse[0]*LOOK_SPD*dt
    deg[1] += mouse[1]*LOOK_SPD*dt

    mouse = [0.0, 0.0]

    if deg[1] < -1: deg[1] = -1
    elif deg[1] > 1: deg[1] = 1

    look[0] = pos[0] + math.sin(deg[0])
    look[1] = pos[1] + math.tan(deg[1])
    look[2] = pos[2] + math.cos(deg[0])
