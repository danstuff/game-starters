#include "include/player.h"

void Player::init(int init_x, int init_y){
    //create player object at given position
    initial_pos = sf::Vector2f(init_x, init_y);

    on_ground = false;
    time_on_ground = 0;

    respawn_time = CTIME + PLAYER_RESPAWN_MS;

    body.init(true, PLAYER_EXP_RAD_RATE, PLAYER_EXP_OUT_RATE);
    body.setPosition(initial_pos);
}

void Player::update(){
    //skip if you haven't respawned yet
    if(respawn_time > CTIME){ return; }

    //apply friction to player
    vel.x *= PLAYER_X_FRICTION;

    //apply gravity to player 
    vel.y += PLAYER_GRAVITY_ACC;
}

void Player::commit(){
    //skip if you haven't respawned yet
    if(respawn_time > CTIME){ return; }

    //add velocity to position
    body.setPosition(body.getPosition()+vel);
}

void Player::visual(){
    body.visual();
    body.stretch(vel.x, vel.y);
    body.ghostTrail();
}

void Player::beat(){
    last_beat_time = CTIME;
    next_beat_time = CTIME + MS_PER_BEAT;

    //pulse player radius along with beat
    body.pulse();
}

void Player::draw(sf::RenderWindow& window){
    body.draw(window);    
}

sf::Vector2f Player::getPosition(){
    //return player's bottom position
    sf::Vector2f pos = body.getPosition();
    pos.y += body.getRadius();

    return pos;
}

sf::Vector2f Player::getTarget(){
    //return player's bottom position plus velocity
    return getPosition()+vel;
}

uint Player::getRadius(){
    return body.getRadius();
}

void Player::setOnGround(bool state){
    on_ground = state;
    
    if(on_ground){
        time_on_ground = CTIME;
    }
}
bool Player::onGround(){
    return on_ground || (CTIME - time_on_ground < PLAYER_JUMP_TOL_MS);
}

void Player::jump(){
    //add jump velocity to y velocity
    vel.y -= PLAYER_JUMP_VEL;

    //you're not on the ground anymore
    on_ground = false;
    time_on_ground = CTIME - PLAYER_JUMP_TOL_MS*10;
}

void Player::move(int dir){
    //skip if you haven't respawned yet
    if(respawn_time > CTIME){ return; }

    //add horizontal velocity to player based on dir
    vel.x = dir*PLAYER_MOVE_SPEED;
}

void Player::stop(bool stop_x, bool stop_y){
    //set player velocity to 0
    if(stop_x){ vel.x = 0; }
    if(stop_y){ vel.y = 0; }
}

void Player::kill(){
    //explosion animation
    body.explode();

    //reset the player to its initial position
    body.setPosition(initial_pos);

    //cut velocity
    stop();
    
    //you have to wait X ms before moving again
    respawn_time = CTIME + PLAYER_RESPAWN_MS;
}

