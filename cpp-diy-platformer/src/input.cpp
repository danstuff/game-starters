#include "include/game.h"

//INPUT HELPER FUNCTIONS
void inputButton(bool state, Button& button){
    if(state){
        //down is only true for 1 cycle when button is first pressed
        if(!button.down){
            button.pressed = true;
        } else {
            button.pressed = false;
        }

        button.down = true;
    } else {
        button.down = false;
    }
}

void inputKey(Button& button){
    //apply keyboard button state to input button profile
    inputButton(sf::Keyboard::isKeyPressed((sf::Keyboard::Key) button.id), button);
}

void inputJoyBtn(Button& button){
    //apply keyboard button state to input button profile
    inputButton(sf::Joystick::isButtonPressed(0, button.id), button);
}

void inputJoy(sf::Joystick::Axis axis, int dir, Button& button){
    //if joystick position surpasses threshold, set button state
    inputButton(
        sf::Joystick::getAxisPosition(0, axis) > INPUT_JOY_THRESHOLD*dir,
        button);
}

void inputSync(InputState& ipt_state){
    //fetch input states and apply to current profile
    if(ipt_state.use_joystick){
        //parse joy position into NSEW
        inputJoy(sf::Joystick::Y,  1, ipt_state.N);
        inputJoy(sf::Joystick::Y, -1, ipt_state.S);

        inputJoy(sf::Joystick::X,  1, ipt_state.E);
        inputJoy(sf::Joystick::X, -1, ipt_state.W);

        //check jump and escape joy buttons
        inputJoyBtn(ipt_state.JMP);
        inputJoyBtn(ipt_state.ESC);
        inputJoyBtn(ipt_state.RST);
    } else {
        //check NSEW, jump and escape buttons
        inputKey(ipt_state.N);
        inputKey(ipt_state.S);
        inputKey(ipt_state.E);
        inputKey(ipt_state.W);

        inputKey(ipt_state.JMP);
        inputKey(ipt_state.ESC);
        inputKey(ipt_state.RST);
    }
}
