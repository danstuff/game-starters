//=================BALL.H==================
// A circle with multiple animation
// features including velocity stretching,
// pulsing, color changing, and ghost
// trails.
//=========================================

#pragma once

#ifndef BALL_H
#define BALL_H

#include <cmath>

#include <SFML/Graphics.hpp>

#include "global.h"

#include "colorwheel.h"

const uint BALL_DEF_RADIUS = 16;

const float BALL_PULSE_SCALE_FAC = 1.4;

const float BALL_VEL_STRETCH_FAC = 0.07;

const uint BALL_GHOST_NUM = 10;
const uint BALL_MS_PER_GHOST = MS_PER_UPDATE*2;

class Ball{
    private:
        //SF Shape instance
        sf::CircleShape body;
        sf::CircleShape explode_body;
        sf::CircleShape ghosts[BALL_GHOST_NUM];

        uint first_ghost;
        uint last_ghost;

        uint prev_ghost_time;

        bool colored;

        float exp_radius_rate;
        float exp_outline_rate;

    public: 
        Ball(): body(), explode_body() {};

        void init(bool i_colored, 
                  float exp_radius_rate, 
                  float exp_outline_rate);

        void visual();
        void stretch(float vx, float vy);
        void ghostTrail();

        void pulse();
        void explode();

        void draw(sf::RenderWindow& window);

        sf::Vector2f getPosition();
        void setPosition(sf::Vector2f pos);

        float getRadius();
        void setRadius(float r);
};

#endif
