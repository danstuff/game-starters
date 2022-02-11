//================ENTITY.H================
// Represents a single modular "robot"
// in the game world, could be a player
// or an AI.
//========================================

#pragma once

#include <stdio.h>
#include <stdlib.h>

#include "box2d/box2d.h"
#include "draw.h"

class Entity {
    private:
        Component core;

    public:
        Entity(b2Vec2 pos, bool randomize);

        Component* swapArmor(Component* newArmor) {
            Component* oldArmor = armor;
            armor = newArmor;

            newArmor->body->bind(&core);
            oldArmor->body->unbind();

            return oldArmor;
        }

        void performAction(Action a) {
            armor->fire(a);
        }
};
