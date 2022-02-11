#include "include/menu.h"

void Menu::init(){
    //initialize menu objects and variables
    if(!option_font.loadFromFile(MENU_OPTION_FONT_FN)){
        return;
    }

    options[WINDOW_SCALE].init("Window Scale    ", WINDOW_SCALE, 0, option_font);

    options[VSYNC].init("V-Sync          ", VSYNC, 0, option_font);

    options[VOLUME].init("Volume          ", VOLUME, 4, option_font);

    options[INPUT_PROFILE].init("Input Profile   ", INPUT_PROFILE, 0, option_font);

    options[COLOR_LEVEL].init("Color Level     ", COLOR_LEVEL, 1, option_font);

    reposition();

    current_selection = 0;
    enabled = false;

    read();
}

void Menu::write(){
    ofstream file(MENU_SAVE_FN, ios::out | ios::binary);

    for(uint i = 0; i < MENU_OPTION_NUM; i++){
        assert(options[i].getIndex() < 255);

        char idx = (char)options[i].getIndex();
        file.write(&idx, 1);
    }

    file.close();
}

void Menu::read(){
    ifstream file(MENU_SAVE_FN, ios::in | ios::binary);

    if(!file.is_open()){ return; }

    for(uint i = 0; i < MENU_OPTION_NUM; i++){
        char idx = 0;
        file.read(&idx, 1);
        options[i].setIndex((uint)idx);
    }

    file.close();
}

void Menu::reposition(){
    sel_box.setPosition(sf::Vector2f(0,
                        (int)current_selection*MENU_OPTION_HEIGHT));
    sel_box.setSize(sf::Vector2f(W,
                    (MENU_OPTION_HEIGHT+MENU_OPTION_OFFSET_Y)));

    for(uint i = 0; i < MENU_OPTION_NUM; i++){
        options[i].reposition();
    }
}

void Menu::input(InputState& istate){
    //navigate up/down the menu with N/S, change options with E/W, toggle on ESC
    if(istate.ESC.pressed){
        enabled = !enabled;

        reposition();

        //write to file in case something changed
        write();
    }

    //don't control menu if it's not open
    if(!enabled){ return; }

    //go up/down the menu on N/S presses
    if(istate.N.pressed != istate.S.pressed){
        //add or subtract from current selection
        if(istate.N.pressed){
            current_selection--;
        } else {
            current_selection++;
        }

        //loop selection
        current_selection %= MENU_OPTION_NUM;
        
        //update the selection box position
        reposition();
    }
    
    //rainbow strobe the selection box color
    sel_box.setFillColor(colorWheel(COL_REGULAR));

    //adjust the selected option on left/right input
    if(istate.E.pressed != istate.W.pressed){
        if(istate.E.pressed){
            options[current_selection].right();
        } else {
            options[current_selection].left();
        }
    }
}

void Menu::draw(sf::RenderWindow& window){
    if(!enabled){ return; }

    window.draw(sel_box);

    //call draw() for each menu option
    for(uint i = 0; i < MENU_OPTION_NUM; i++){
        options[i].draw(window);
    }
}

bool Menu::isEnabled(){
    //return true if the menu is currently being displayed
    return enabled;
}

float Menu::getWindowScale(){
    //return the current value of window scale option
    return 1/(float)stoi(options[WINDOW_SCALE].get());
}

bool Menu::getVSync(){
    //return the current value of vsync option
    return (options[VSYNC].get() == "Y");
}

uint Menu::getVolume(){
    //return the current value of volume option
    return stoi(options[VOLUME].get());
}

uint Menu::getInputProfile(bool joy_good){
    string ip = options[INPUT_PROFILE].get();

    if(ip == "Controller" && !joy_good){
        options[INPUT_PROFILE].right();
    }

    ip = options[INPUT_PROFILE].get();

    if(ip == "   WASD   "){ return 0; }
    else if(ip == "Arrow Keys"){ return 1; }
    else if(ip == "Controller"){ return 2; }

    return 0;
}

uint Menu::getColorLevel(){
    return stoi(options[COLOR_LEVEL].get());
}
