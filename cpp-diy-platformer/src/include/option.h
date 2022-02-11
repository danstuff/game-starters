//================OPTION.H================
// Contains data for each individual
// option in the options menu. Options
// can be increased with right() or
// decreased with left(), and their values
// fetched with get(). Each option can
// have up to 16 possible values. For
// example, values for vsync would be "ON"
// and "OFF".
//========================================

#pragma once

#ifndef OPTIONS_H
#define OPTIONS_H

#include <string>
#include <cassert>

#include <SFML/Graphics.hpp>

#include "global.h"
#include "input.h"

const uint MENU_OPTION_VAL_NUM = 8;

const int MENU_OPTION_OFFSET_X = 16;
const int MENU_OPTION_OFFSET_Y = 16;

const int MENU_OPTION_HEIGHT = 32;
const int MENU_OPTION_TEXT_SIZE = 18;

const string MENU_OPTION_VALUES[][MENU_OPTION_VAL_NUM] = {
    { "1", "2", "3", "4", "5", "6", "7", "8" },
    { "Y", "N", "Y", "N", "Y", "N", "Y", "N" },
    { "1", "2", "3", "4", "5", "6", "7", "8" },
    { "   WASD   ", "Arrow Keys", "Controller", "   WASD   ",
      "Arrow Keys", "Controller", "   WASD   ", "Arrow Keys" },
    { "1", "2", "3", "1", "2", "3", "1", "2" },
};

class Option{
    private:
        //the sf text object for this option
        sf::Text body;

        //what the option will be displayed as
        string name;

        //position in the overall options menu
        uint position;

        //the current selections for this option
        uint cur_value;

    public:
        //initialize and draw
        void init(string i_name, uint position, uint def_value, sf::Font &font);
        void reposition();

        void draw(sf::RenderWindow& window);

        //change current value
        void left();
        void right();

        //fetch current value
        string get();

        uint getIndex();
        void setIndex(uint i);
};

#endif
