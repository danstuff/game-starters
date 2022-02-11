//================ACTION.H================
// Allow various interfaces to interact
// with parts.
//========================================

#ifndef ACTION_H
#define ACTION_H

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>

#include "part.h"

class Action {
    public:
        char identifier;

        Action() {
            identifier = ' ';
        };

        bool match(Part* part);
        virtual void fire(Part* part);
};

class MoveAction : public Action {
    public:
        b2Vec2 heading;
        float power;

        MoveAction() {
            identifier = 'm';
        };

        void fire(Part* part) override;
};

class FollowAction : public Action {
    public:
        b2Vec2 target;

        FollowAction() {
            identifier = 'f';
        };

        void fire(Part* part) override;
};

class ShootAction : public Action {
    public:
        float power;

        ShootAction() {
            identifier = 's';
        };

        void fire(Part* part) override;
};

#endif
