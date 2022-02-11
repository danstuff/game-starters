#include "include/action.h"

bool Action::match(Part* part) {
    unsigned int l = part->temp->triggerLen;

    for(unsigned int i = 0; i < l; i++) {
        if(part->temp->trigger[i] == identifier) {
            return true;
        }
    }

    return false;
}

void Action::fire(Part* part) {}

void MoveAction::fire(Part* part) {
    part->body->ApplyLinearImpulseToCenter(
            power*heading, true);

}

void FollowAction::fire(Part* part) {
    part->body->SetFixedRotation(true);

    b2Vec2 pos = part->body->GetPosition();
    b2Vec2 delta = target - pos;

    float ang = atan2(delta.y, delta.x);

    part->body->SetTransform(pos, ang);
}

void ShootAction::fire(Part* part) {
    part->resetWalk();
    Part* projectile = part->walk();
    part->resetWalk();

    part->removeChild(projectile);

    float angle = part->body->GetAngle();
    b2Vec2 dir = b2Vec2(cos(angle), sin(angle));

    projectile->body->ApplyLinearImpulseToCenter(
            power*dir, true);
}

