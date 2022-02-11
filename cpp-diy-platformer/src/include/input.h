//================INPUT.H================
// Contains structures used to store and
// transfer input data between objects.
// Input data consists of 4 directional
// buttons N/S/E/W as well as a pause
// button ESC. If use_joystick is true,
// each button id will point to a joy
// button. If not, they will point to
// keyboard buttons. 
//=======================================

#pragma once

#ifndef INPUT_H
#define INPUT_H

#include "global.h"

const uint INPUT_PROFILE_NUM = 3;

const float INPUT_JOY_THRESHOLD = 0.75;

struct Button {
    int id;
    bool down;
    bool pressed;
};

struct InputState {
    //keyboard/joystick input options
    bool use_joystick;

    Button N;
    Button S;
    Button E;
    Button W;
    
    Button JMP;
    Button ESC;
    Button RST;
};

const InputState INPUT_PROFILES[] = {
    //WASD
    { 
        false,
        { sf::Keyboard::W, false, false },
        { sf::Keyboard::S, false, false },
        { sf::Keyboard::D, false, false },
        { sf::Keyboard::A, false, false },

        { sf::Keyboard::Space, false, false },
        { sf::Keyboard::Escape, false, false },
        { sf::Keyboard::R, false, false }
    },

    //Arrow Keys
    { 
        false,
        { sf::Keyboard::Up, false, false },
        { sf::Keyboard::Down, false, false },
        { sf::Keyboard::Right, false, false },
        { sf::Keyboard::Left, false, false },
        
        { sf::Keyboard::Space, false, false },
        { sf::Keyboard::Escape, false, false },
        { sf::Keyboard::R, false, false }
    },

    //Controller
    { 
        true,
        { -1, false, false },
        { -1, false, false },
        { -1, false, false },
        { -1, false, false },

        { 1, false, false },
        { 3, false, false },
        { 2, false, false }
    }
};

void inputButton(bool state, Button& button);

void inputKey(Button& button);

void inputJoyBtn(Button& button);

void inputJoy(sf::Joystick::Axis axis, int dir, Button& button);

void inputSync(InputState& ipt_state);

#endif
