//================GAME.H================
// The main window and event manager for
// the program. Enables dynamic window
// resizing, keeps track of beats,
// handles input, and handles drawing.
//======================================

#pragma once

#ifndef GAME_H
#define GAME_H

#include <string>
#include <time.h>

#include <SFML/Graphics.hpp>

#include "global.h"

#include "input.h"

#include "level.h"
#include "music.h"
#include "menu.h"
#include "title.h"

//default window size and title
const uint DEFAULT_W = 640;
const uint DEFAULT_H = 480;

const string DEFAULT_TITLE = "Boom\nSlap";

const string CRT_SHADER_FILE = "res/crt.frag";

//how long to wait before resizing the draw area
const uint RESIZE_DELAY = 600;

//applied to the window position after resize
const int RESIZE_SHIFT_X = 0;
const int RESIZE_SHIFT_Y = 0;

//amount of antialiasing to use
const uint AA_LEVEL = 8;

//the brightness of the window clear color
const uint WINDOW_CLEAR_BRIGHT = 0;
const float WINDOW_CLEAR_DARKFAC = 0.5f;

class Game{
    private:
        //sf window and window properties
        sf::ContextSettings settings;
        sf::RenderWindow window;

        //sf views
        sf::View level_view;
        sf::View menu_view;

        sf::Shader crt_shader;

        //values that constitute a resize timer
        uint resize_time;
        bool resize_triggered;

        //passed to level for input processing
        InputState ipt_state;

        //game objects
        Level level;
        Music music;
        Menu menu;
        Title title;

        //synchronize window size
        void createWindow();
        void syncWindow();

        //resize timer handling
        void triggerResize();
        void resizeCheck();

        //synchronize menu options w/ actual settings
        void syncOptions();

    public: 
        Game(): level(), music(), menu(), crt_shader(),
                ipt_state(INPUT_PROFILES[0]) {};

        //main loop functions
        void init();

        void events();
        void update();
        void beat();
        void input();
        void draw();

        void quit();
        
        //check if window still open
        bool isOpen();
};

#endif
