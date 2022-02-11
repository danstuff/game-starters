//================COLORWHEEL.H================
// Declares a function used for a rainbow
// strobe effect in several classes.
//============================================

#pragma once

#ifndef COLORWHEEL_H
#define COLORWHEEL_H

#include <cassert>

#include <SFML/Graphics.hpp>

#include "global.h"

const uint COL_MAX = 255;
const uint COL_SAMPLES = COL_MAX*3;
const uint COL_MS_PER_REV = 1000;

const uint  COL_DRK_SHI = 0;
const uint  COL_DRK_BRI = 0;
const float COL_DRK_SCA = 0.5f;

const uint  COL_REG_SHI = COL_MAX/4;
const uint  COL_REG_BRI = 0;
const float COL_REG_SCA = 1.0f;

const uint  COL_LHT_SHI = COL_MAX/10;
const uint  COL_LHT_BRI = 100;
const float COL_LHT_SCA = 1.0f;

const sf::Color COL_DRK_DEFAULT = sf::Color(0,0,0);
const sf::Color COL_REG_DEFAULT = sf::Color(100,100,100);
const sf::Color COL_LHT_DEFAULT = sf::Color(50,50,50);

enum ColType{
    COL_DARK,
    COL_REGULAR,
    COL_LIGHT
};

extern bool COL_DARK_ON;
extern bool COL_REGULAR_ON;
extern bool COL_LIGHT_ON;

void colorInit();
sf::Color colorWheel(ColType type);

#endif
