//================TITLE.H================
// Displays an oscillating title card,
// version information, creator name,
// and "press SPACE", which initiates
// the game.
//=======================================

#pragma once

#ifndef TITLE_H
#define TITLE_H

#include <string>
#include <cmath>

#include <SFML/Graphics.hpp>

#include "global.h"
#include "input.h"
#include "colorwheel.h"

const float TITLE_SCALE_FAC = 1.25f;
const float TITLE_ROT_FAC = 5.0f;

const int TITLE_OFF_TARGET = -4000;

const string TITLE_FONT_FN = "res/AusweisHollow.ttf";

class Title{
    private:
        sf::Font font;
        sf::Text body;

        bool enabled;

    public: 

        //main loop functions
        void init(string body_text);

        void visual();
        void beat();
        void input(InputState& istate);
        void draw(sf::RenderWindow& window);
};

#endif
