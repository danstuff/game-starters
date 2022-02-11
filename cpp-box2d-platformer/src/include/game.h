//================GAME.H================
// Links a list of parts and
// static physics objects with
// various interfaces.
//======================================

#pragma once

#include <stdio.h>
#include <stdlib.h>

#include "box2d/box2d.h"

#include "draw.h"
#include "part.h"

class Game {
    private:
        b2World* world;
        b2Body* ground;

        PartList cList;
        Part* player;

    public:
        Game();

        Part* getPlayer();
        PartList* getPartList();

        void create();
        void step();
        void destroy();
};

extern Game g_game;
