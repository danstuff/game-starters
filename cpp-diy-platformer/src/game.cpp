#include "include/game.h"

//globals visible to every file
uint W, H;
float CTIME;

void Game::init() {
    //immutables
    W = DEFAULT_W;
    H = DEFAULT_H;

    //resize timer
    resize_time = 0;
    resize_triggered = false;

    //generate the rainbows used by visible objects
    colorInit();

    //set antialiasing on
    settings.antialiasingLevel = AA_LEVEL;

    //initialize and load game objects
    menu.init();
    title.init(DEFAULT_TITLE);

    //music.load();

    //use a neural net to generate a good level
    level.generate();

    //create window
    createWindow();

    //load shaders
    if(sf::Shader::isAvailable()){
        crt_shader.loadFromFile(CRT_SHADER_FILE, sf::Shader::Fragment);
    }
}

bool Game::isOpen(){
    return window.isOpen();
}

void Game::createWindow(){
    window.create(sf::VideoMode(W, H), DEFAULT_TITLE,
                  sf::Style::Default, settings);

    //center the level view around 0,0
    level_view.setCenter(sf::Vector2f(0,0));
    level_view.setSize(sf::Vector2f(W,H));

    //menu view starts at the top left
    menu_view.reset(sf::FloatRect(0,0,W,H));
    
    //reposition menu elements to be at top left
    menu.reposition();

    //sync options with their settings
    syncOptions();
}

void Game::syncWindow(){
    //if resize timer triggered, update draw area
    if(resize_time <= CTIME and resize_triggered){
        sf::Vector2u size = window.getSize();

        //get new window size
        W = size.x;
        H = size.y;

        //get current window position and shift it
        sf::Vector2i pos = window.getPosition();
        pos.x += RESIZE_SHIFT_X;
        pos.y += RESIZE_SHIFT_Y;

        //re-create window
        createWindow();

        window.setPosition(pos);

        resize_triggered = false;
    }
}

void Game::triggerResize(){
    //push back the resize timer and set resize flag
    resize_time = CTIME + RESIZE_DELAY;
    resize_triggered = true;
}

void Game::syncOptions(){
    //sync all menu settings with actual settings

    //WINDOW_SCALE
    level_view.setSize(sf::Vector2f(W, H));
    level_view.zoom(menu.getWindowScale());

    //VSYNC
    window.setVerticalSyncEnabled(menu.getVSync());

    //VOLUME
    music.setVolume(menu.getVolume());

    //INPUT_PROFILE
    bool joy_good = sf::Joystick::isConnected(0) && 
                   (sf::Joystick::getButtonCount(0) >= 2);
    ipt_state = INPUT_PROFILES[menu.getInputProfile(joy_good)];
    inputSync(ipt_state);

    //COLOR_LEVEL
    uint lev = menu.getColorLevel();
    COL_REGULAR_ON = (lev >= 1);
    COL_LIGHT_ON = (lev >= 2);
    COL_DARK_ON = (lev >= 3);
}

void Game::events(){
    sf::Event event;
    while(window.pollEvent(event)){
        switch(event.type){
            //call quit on window close
            case sf::Event::Closed:
                quit();
            break;

            //trigger the resize timer on resize event
            case sf::Event::Resized:
                if(event.size.width != W or
                   event.size.height != H)
                    triggerResize(); 
            break;
        }
    }
}

void Game::input(){
    //only sync input if window has focus
    if(!window.hasFocus()){ return; }
    inputSync(ipt_state);
    
    //INPUT
    if(!menu.isEnabled()){
        level.input(ipt_state);
    }

    title.input(ipt_state);

    bool menu_was_en = menu.isEnabled();
    menu.input(ipt_state);

    //if menu was closed, resync options
    if(menu_was_en && ipt_state.ESC.pressed){
        syncOptions();
    }
}

void Game::update(){
    syncWindow(); 

    //UPDATE
    if(!menu.isEnabled()){
        level.update();
    }

    //VISUAL
    level.visual();
    title.visual();
}

void Game::beat(){
    //BEAT
    level.beat();
    title.beat();
    //music.beat();
}

void Game::draw(){
    //clear, draw, and push to screen
    //window.clear();
    window.clear(colorWheel(COL_DARK));

    crt_shader.setUniform("iResolution", sf::Vector2f(W, H));
    sf::Shader::bind(&crt_shader);

    //DRAW
    window.setView(level_view);
    level.draw(window);

    window.setView(menu_view);
    title.draw(window);
    menu.draw(window);

    sf::Shader::bind(NULL);

    //push to screen
    window.display();
}

void Game::quit(){
    window.close();
}
