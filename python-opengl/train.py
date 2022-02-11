from pyglet.gl import *

import math
import util

import car

class Train:
    cars = []

    def load(self, carpath, carnum):
        cars.append(car.Car())

        for i in range(carnum-1):
            nc = car.Car()
            nc.copy(cars[0], i+1)
            cars.append(nc)

    def run(self, dt):
        for car in cars:
            speed += 0.01*dt
            car.run(dt)
