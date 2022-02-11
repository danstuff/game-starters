//================BOX.H================
// Rectangular structural element of a
// level for the player to collide
// with. May disappear/reappear along
// with the beat if on_beats and
// off_beats are set to non-zero
// values. If kill is set to true,
// when the box is hit it will reset
// the player to their starting
// position.
//=====================================

#pragma once

#ifndef BOX_H
#define BOX_H

#include <SFML/Graphics.hpp>

#include "global.h"
#include "colorwheel.h"

enum BoxCollisionAxis{
    NO_COL,
    X_AXIS,
    Y_AXIS_TOP,
    Y_AXIS_BOTTOM,
    BOTH_AXES
};

class Box{
    private:
        sf::RectangleShape body;
        
        //if true, box will reset player when collided
        bool kill;

        //if true, box will be visible and collideable
        bool enabled;

        //number of beats box will be enabled/disabled for
        uint beats;

        //keep a tally of beats since last state change
        uint beat_count;

    public: 
        Box(): body() {};

        void init(float x, float y, float w, float h,
                  bool i_enabled, uint i_beats);

        void visual();
        void beat();    
        
        void draw(sf::RenderWindow& window);

        uint collidesWith(sf::Vector2f p, sf::Vector2f t);
        bool isKill();
};

#endif
