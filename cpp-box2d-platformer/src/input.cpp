#include "include/input.h"

Input g_input;

Input::Input() {
    target = nullptr;

    bindings[INPUT_MOVE_LEFT].key = GLFW_KEY_A;
    bindings[INPUT_MOVE_RIGHT].key = GLFW_KEY_D;
    bindings[INPUT_MOVE_UP].key = GLFW_KEY_W;
    bindings[INPUT_MOVE_DOWN].key = GLFW_KEY_S;

    bindings[INPUT_BOOST].key = GLFW_KEY_LEFT_CONTROL;
    bindings[INPUT_DEFEND].key = GLFW_KEY_LEFT_SHIFT;

    for(unsigned int i = 0; i < INPUT_MAX; i++) {
        bindings[i].state = false;
    }
    
    moveAction.power = 30;
    moveAction.heading = b2Vec2(0.0f, 0.0f);

    followAction.target = b2Vec2(0.0f, 0.0f);
}

void Input::performAction(Action* a) {
    performAction(g_game.getPlayer(), a);
}

void Input::performAction(Part* root, Action* a) {
    root->resetWalk();

    if(a->match(root)) {
        a->fire(root);
    }

    Part* p = root->walk(); 

    while(p != nullptr) {
        performAction(p, a);
        p = root->walk(); 
    }
}

void Input::onKey(int key, int state) {
    for(unsigned int i = 0; i < INPUT_MAX; i++) {

        if(bindings[i].key == key) {

            if(state == GLFW_PRESS) {
                bindings[i].state = true;

            } else if(state == GLFW_RELEASE) {
                bindings[i].state = false;
            }
        }
    }
}

void Input::onMouseButton(int button, int state) {
    if(state == GLFW_PRESS) {
        if(button == GLFW_MOUSE_BUTTON_LEFT) {
            //performAction(&attackActionA);

        } else if(button == GLFW_MOUSE_BUTTON_RIGHT) {
            //performAction(&attackActionB);
        }
    }
}

void Input::onMouseMove(b2Vec2 position) { 
    followAction.target = position;
    performAction(&followAction);
}

void Input::step() {
    //ignore movement if defending
    if(bindings[INPUT_DEFEND].state) {
        //performAction(&defendAction);
        return;
    }

    //process left, right, up, and boost inputs
    b2Vec2 heading = b2Vec2(0.0f, 0.0f);

    if(bindings[INPUT_MOVE_LEFT].state) {
        heading.x -= 1.0f;
    } 
    
    if(bindings[INPUT_MOVE_RIGHT].state) {
        heading.x += 1.0f;
    }

    if(bindings[INPUT_MOVE_UP].state){
        heading.y += 1.0f;
    }

    if(bindings[INPUT_MOVE_DOWN].state){
        heading.y -= 1.0f;
    }

    if(bindings[INPUT_BOOST].state) {
        heading *= 1.5f;
    }

    moveAction.heading = heading;
    performAction(&moveAction);
}

