//================INPUT.H================
// Allows the user's input to control
// the movement of parts in a 
// level via actions.
//=======================================
#ifndef INPUT_H
#define INPUT_H

#include "game.h"
#include "action.h"

enum InputType {
    INPUT_MOVE_LEFT,
    INPUT_MOVE_RIGHT,
    INPUT_MOVE_UP,
    INPUT_MOVE_DOWN,
    INPUT_DEFEND,
    INPUT_BOOST,
    INPUT_MAX
};

struct InputBinding {
    int key;
    bool state;
};

class Input {
    private:
        InputBinding bindings[INPUT_MAX];
        Part* target;

        MoveAction moveAction;
        FollowAction followAction;
        ShootAction shootAction;
        
        void performAction(Action* a);
        void performAction(Part* root, Action* a);

    public:
        Input();

        void onKey(int key, int state);
        void onMouseButton(int button, int state);
        void onMouseMove(b2Vec2 position);

        void step();
};

extern Input g_input;

#endif
