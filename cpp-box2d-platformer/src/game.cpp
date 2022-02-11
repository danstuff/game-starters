#include "include/game.h"

Game g_game;

Game::Game() {
    world = nullptr;
    ground = nullptr;
    player = nullptr;
}

Part* Game::getPlayer() {
    return player;
}

PartList* Game::getPartList() {
    return &cList;
}

void Game::create() {
    //create the world with some gravity
    b2Vec2 gravity;
    gravity.Set(0.0f, -1.0f);

    world = new b2World(gravity);
    world->SetDebugDraw(&g_debugDraw);

    //create a straight line to represent the ground
    {
        b2BodyDef bodyDef;
        ground = world->CreateBody(&bodyDef);

        b2EdgeShape shape;
        shape.SetTwoSided(b2Vec2(-20.0f, -1.0f), b2Vec2(20.0f, -1.0f));

        ground->CreateFixture(&shape, 2.0);
    }

    //make a player and attatch a basic fixture to it
    Part* fixture;

    {
        PartTemplate* ct = cList.getNewTemplate();
        ct->setName("player");
        ct->setSize(b2Vec2(5.0f, 5.0f));
        ct->addChildAnchor(b2Vec2(2.5f, 2.5f));
        ct->setTrigger("m", 1);

        player = cList.getNewPart();
        player->setTemplate(ct);
        player->create(world, b2Vec2(0.0f, 40.0f));
    }

    {
        PartTemplate* ct = cList.getNewTemplate();
        ct->setName("fixture");
        ct->setSize(b2Vec2(1.0f, 1.0f));
        ct->setTrigger("f", 1);

        fixture = cList.getNewPart();
        fixture->setTemplate(ct);
        fixture->create(world, b2Vec2(0.0f, 50.0f));

        Part *f2 = cList.getNewPart();
        f2->setTemplate(ct);
        f2->create(world, b2Vec2(20.0f, 20.0f));
    }

    player->addChild(fixture);    
}

void Game::step() {
    uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
    flags += b2Draw::e_jointBit;
    flags += b2Draw::e_aabbBit;
    flags += b2Draw::e_centerOfMassBit;
    g_debugDraw.SetFlags(flags);

    world->Step(0.1, 8, 3);
    world->DebugDraw();
    g_debugDraw.Flush();
}

void Game::destroy() {
    cList.clear();

    delete world;
    world = nullptr;
    ground = nullptr;
    player = nullptr;
}
