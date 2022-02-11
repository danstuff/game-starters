//================PART.H================
// Defines a dynamic physics body that can
// attach to multiple other bodies.
//===========================================

#ifndef PART_H
#define PART_H

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>

#include "imgui/imgui.h"
#include "imgui_impl/imgui_impl_glfw.h"
#include "imgui_impl/imgui_impl_opengl3.h"

#include "glad/gl.h"
#include "GLFW/glfw3.h"

#include "box2d/box2d.h"

const unsigned int PART_CHILD_MAX = 8;

const unsigned int PART_TEMP_MAX = 2;
const unsigned int PART_MAX = 32;

struct PartStats {
    float weight;
    float health;
    float healthMax;
    float energy;
    float energyMax;
    float energyRate;
};

class PartTemplate {
    public:
        const char* name;

        const char* trigger;
        unsigned int triggerLen;

        PartStats baseStats;
        
        b2Vec2 size;

        b2Vec2 childAnchors[PART_CHILD_MAX];
        unsigned int maxChildren;

        PartTemplate();

        void setName(const char* cname);
        void setTrigger(const char* ctrigger, unsigned int ctriggerLen);
        void setSize(b2Vec2 csize);

        bool addChildAnchor(b2Vec2 newChildAnchor);
};

class Part {
    private:
        void bindTo(b2Body* parentBody, b2Vec2 anchor);
        void unbind();
        
        int childIndex;
        
    public:
        Part* children[PART_CHILD_MAX];
        Part* parent;

        PartTemplate* temp;
        
        b2World* world;
        b2Body* body;
        b2RevoluteJoint* parentJoint;

        PartStats stats;

        Part();
        void setTemplate(PartTemplate* ctemp);
        void create(b2World* cworld, b2Vec2 pos);

        bool addChild(Part* newChild);
        bool removeChild(Part* oldChild);
        
        Part* walk();
        void resetWalk();
};

class PartList {
    private:
        PartTemplate cTemplates[PART_TEMP_MAX];
        Part parts[PART_MAX];

        unsigned int numTemplates;
        unsigned int numParts;

    public:
        PartList();

        PartTemplate* getNewTemplate();
        Part* getNewPart();

        Part* getNextRoot(unsigned int& i);

        void clear();
};

#endif
