//================LEVEL.H================
// Handles the actual game environment.
// A level contains the input-controlled
// player as well as up to 64 obstacles
// called boxes. Boxes are solid
// rectangular entities that can appear
// and disappear with the beat.
//=======================================

#pragma once

#ifndef LEVEL_H
#define LEVEL_H

#include <iostream>
#include <fstream>
#include <string>
#include <cassert>
#include <cmath>

#include <SFML/Graphics.hpp>

#include <neuroscapes/neunet.h>

#include "global.h"
#include "input.h"

#include "player.h"
#include "box.h"
#include "ball.h"

//maximum possible number of level obstacles
const uint LEVEL_MAX_BOXES = 8;

//maximum level data size
const uint LEVEL_DATA_SIZE = LEVEL_MAX_BOXES*3;

//bounds which the player can't go farther than
const uint LEVEL_BOUND_X = 320;
const uint LEVEL_BOUND_Y = 240;

//how long to wait before loading the next part of the level
const uint LEVEL_LOAD_DELAY_MS = 500; 
const uint LEVEL_TRANS_SIZE = 1000;

//goal explosion properties
const float LEVEL_GOAL_EXP_RAD_RATE = 1.2f;
const float LEVEL_GOAL_EXP_OUT_RATE = 1.5f;

//the amount of time a good level should to complete
const uint LEVEL_OPTIMAL_TIME = 15000; 
const float LEVEL_OPTIMAL_TIME_TOLERANCE = 0.5f;

//scaling value for score calculations
const float LEVEL_SCORE_SCALE = 10000.0f;

//how many times you'll try to generate a good level
const uint LEVEL_GEN_TRIES = 1024;

//neural net operates in range [-1, 1], so data must be scaled up to use
const uint LEVEL_ARC_SCALE = 65;
const uint LEVEL_BOX_SCALE = 50;

const uint LEVEL_ARC_MIN_TIME = 10;
const uint LEVEL_BOX_MIN_SIZE = 20;

const float LEVEL_JUMP_DIST_FAC = 0.8f;
const float LEVEL_JUMP_HEIGHT_FAC = 0.9f;

//number of trials to run before backpropagation
const uint LEVEL_NUM_TRIALS = 16;

//how long reset must be held to reset level
const uint LEVEL_RESET_TIME = 1000;

class Level{
    private:
        //raw level data for later evaluation
        float raw[LEVEL_NUM_TRIALS][LEVEL_DATA_SIZE];
        float quality[LEVEL_NUM_TRIALS];
        uint num_trials;

        //level objects
        Box boxes[LEVEL_MAX_BOXES];
        uint num_boxes;

        Player player;
        Ball goal;

        //whether or not the player won this level
        bool goal_hit;
        uint goal_time;

        //the time that the level was initiated
        uint start_time;

        //how long reset button has been held
        uint reset_time;

        //test if a circle intersects a box
        uint hitBox(sf::Vector2f pos, sf::Vector2f target);

    public: 
        Level(): goal(), player(),
                num_boxes(0), num_trials(0),
                goal_hit(false), goal_time(0),
                start_time(0), reset_time(0) {};

        //open, load each section, and close files
        void generate();
        void learn(bool won);
        
        //main loop
        void update();
        void visual();
        void input(InputState& istate);
        void beat();

        //render the level
        void draw(sf::RenderWindow& window);
};

#endif
