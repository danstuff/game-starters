//================GLOBAL.H================
// Used to declare global constants, type
// definitions, etc. that are utilized
// across the entire program.
//========================================

#pragma once

#ifndef GLOBAL_H
#define GLOBAL_H

#include "stdio.h"
#include "stdlib.h"
#include <iostream>

using namespace std;

typedef unsigned int uint;

#define _USE_MATH_DEFINES

//unit constants
const float MS_PER_UPDATE = 16;
const float S_PER_UPDATE = MS_PER_UPDATE/1000;

const float BEATS_PER_M = 120;
const float MS_PER_BEAT = (60*1000)/BEATS_PER_M;

const float PX_PER_M = 64;
const float M_PER_S = PX_PER_M*S_PER_UPDATE;
const float M_PER_S_SQ = M_PER_S*S_PER_UPDATE;

//globals set by game class
extern uint W;
extern uint H;
extern float CTIME;

#endif
