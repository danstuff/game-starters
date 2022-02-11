#include "include/option.h"

void Option::init(string i_name, uint i_position, uint def_value, sf::Font &font){
    //initialize variables
    name = i_name;
    
    position = i_position;
    cur_value = def_value;

    body.setFont(font);
    body.setCharacterSize(MENU_OPTION_TEXT_SIZE);
    body.setString(name + " > " + get() + " < ");
    reposition();
}

void Option::reposition(){
    body.setPosition(sf::Vector2f((MENU_OPTION_OFFSET_X),
                                  (MENU_OPTION_OFFSET_Y +
                                  ((int)position*MENU_OPTION_HEIGHT))));
}

void Option::draw(sf::RenderWindow& window){
    //render text object body
    window.draw(body);
}

void Option::left(){
    //decrement currently selected option value
    if(cur_value > 0){ cur_value--; }
    body.setString(name + " > " + get() + " < ");
}

void Option::right(){
    //increment currently selected option value
    if(cur_value < MENU_OPTION_VAL_NUM-1){ cur_value++; }
    body.setString(name + " > " + get() + " < ");
}

string Option::get(){
    //return option value
    assert(cur_value < MENU_OPTION_VAL_NUM);
    return MENU_OPTION_VALUES[position][cur_value];

}

uint Option::getIndex(){
    return cur_value;
}

void Option::setIndex(uint i){
    assert(i < MENU_OPTION_VAL_NUM);
    cur_value = i;
    body.setString(name + " > " + get() + " < ");
}
