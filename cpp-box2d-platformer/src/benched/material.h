//================MATERIAL.H================
// Allows the generation of procedurally
// named and colored materials
// in the game world, could be a player
// or an AI.
//==========================================

#pragma once

#include <stdio.h>
#include <stdlib.h>

#include "box2d/box2d.h"
#include "draw.h"

const int PREFIX_COUNT = 12;
const int MIDDLE_COUNT = 8;
const int SUFFIX_COUNT = 4;

char[PREFIX_COUNT][4] prefixes = {
    "argo",
    "phot",
    "meld",
    "isto",
    "eins",
    "prol",
    "fero",
    "bohs",
    "darg",
    "wobo",
    "wiff",
    "roto"
};

char[MIDDLE_COUNT][2] middles = {
    "",
    "st",
    "sh",
    "wo",
    "re",
    "ur",
    "on",
    "le"
}

char[SUFFIX_COUNT][3] suffixes = {
    "ium",
    "num",
    "lum",
    "ite"
};

enum Rarity {
    RARITY_COMMON,
    RARITY_UNCOMMON,
    RARITY_RARE,
    RARITY_LEGENDARY,
    RARITY_COSMIC,
    RARITY_MAX
};

class Material {
public:
    const char* name;

    Rarity rarity;

    float weightFac;
    float healthFac;
    float energyCapacityFac;
    float energyRateFac;

    Material(Rarity rarity, int seed);
};

