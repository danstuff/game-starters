//================MENU.H================
// The options menu for the game. A UI
// structure that enables the user to
// toggle vsync, change the window
// scale, and adjust the volume. The
// game is paused while this menu is
// open.
//======================================

#pragma once

#ifndef MENU_H
#define MENU_H

#include <SFML/Graphics.hpp>
#include <string>
#include <cassert>
#include <iostream>
#include <fstream>

#include "global.h"
#include "input.h"
#include "colorwheel.h"

#include "option.h"

const string MENU_OPTION_FONT_FN = "res/UAV-OSD.ttf";

const string MENU_SAVE_FN = "settings.dat";

enum MENU_OPTION {
    WINDOW_SCALE,
    VSYNC,
    VOLUME,
    INPUT_PROFILE,
    COLOR_LEVEL,
    MENU_OPTION_NUM
};

class Menu{
    private:
        sf::Font option_font;
        sf::RectangleShape sel_box;

        Option options[MENU_OPTION_NUM];

        uint current_selection;

        bool enabled;

    public: 
        Menu(){};

        void init();

        void write();
        void read();

        void reposition();
        void input(InputState& i_state);


        void draw(sf::RenderWindow& window);

        bool isEnabled();

        float getWindowScale();
        bool getVSync();
        uint getVolume();
        uint getInputProfile(bool joy_good);
        uint getColorLevel();
};

#endif
