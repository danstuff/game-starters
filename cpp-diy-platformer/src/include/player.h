//================PLAYER.H=================
// A mobile circular entity for the user
// to control with keyboard or joystick
// input. Able to move left and right and
// jump. Jump height is determined by how
// closely the jump button was hit to the
// music beat. 
//=========================================

#pragma once

#ifndef PLAYER_H
#define PLAYER_H

#include <cmath>

#include <SFML/Graphics.hpp>

#include "global.h"

#include "ball.h"

//respawn time
const uint PLAYER_RESPAWN_MS = 500;

//death explosion appearance
const float PLAYER_EXP_RAD_RATE = 1.5f;
const float PLAYER_EXP_OUT_RATE = 0.92f;

//movement properties
const float PLAYER_MOVE_SPEED = 4 * M_PER_S;

const float PLAYER_JUMP_VEL = 6 * M_PER_S;

const float PLAYER_GRAVITY_ACC = 12 * M_PER_S_SQ;

const float PLAYER_X_FRICTION = 0.7;

//how many ms after leaving the ground can the player jump
const uint PLAYER_JUMP_TOL_MS = 100;

class Player{
    private:
        //player's starting position
        sf::Vector2f initial_pos;

        //Body instance
        Ball body;

        sf::Vector2f vel;

        //time when last beat occured, and time for next
        uint last_beat_time;
        uint next_beat_time;

        //time when player should respawn
        uint respawn_time;

        //whether or not the player is on the ground
        bool on_ground;
        uint time_on_ground;

    public: 
        Player(): body() {};

        void init(int i_initial_x, int i_initial_y);
        void update();
        void commit();
        void visual();
        void beat();

        void draw(sf::RenderWindow& window);

        sf::Vector2f getPosition();
        sf::Vector2f getTarget();

        uint getRadius();

        void setOnGround(bool state);
        bool onGround();

        void jump();
        void move(int dir);
        void stop(bool stop_x = true, bool stop_y = true);

        void kill();
};

#endif
