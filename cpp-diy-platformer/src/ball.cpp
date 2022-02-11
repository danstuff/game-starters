#include "include/ball.h"

void Ball::init(bool i_colored,
                float i_exp_radius_rate, 
                float i_exp_outline_rate){
    //create ball object at given position
    prev_ghost_time = CTIME;
    
    colored = i_colored;
    
    exp_radius_rate = i_exp_radius_rate;
    exp_outline_rate = i_exp_outline_rate;

    body.setRadius(0);
    visual();
}

void Ball::visual(){
    //strobe ball color if colored is set
    if(colored){
        body.setFillColor(colorWheel(COL_REGULAR));
    }

    //gradually move ball radius back to default
    float crad = body.getRadius();
    if(crad != BALL_DEF_RADIUS){
        body.setRadius(crad - (crad-BALL_DEF_RADIUS)*0.1f);
    }

    //re-center the origin
    body.setOrigin(body.getRadius(), body.getRadius());

    //explosion animation; increase radius while shrinking outline
    if(explode_body.getOutlineThickness() > 0){
        float ebot = explode_body.getOutlineThickness()*exp_outline_rate;
        float ebra = explode_body.getRadius()*exp_radius_rate;

        explode_body.setRadius(ebra);
        explode_body.setOutlineThickness(ebot);
        explode_body.setOrigin(ebra, ebra);

        if(ebot < 0.0001f || ebra > 1000000){
            explode_body.setOutlineThickness(0);
        }
    }
}

void Ball::stretch(float vx, float vy){
    //stretch the player body in the direction of the velocity
    float vmag = sqrt(pow(vx, 2)+pow(vy,2));
    float vang = atan((vx == 0) ? 1000000000 : vy/vx)*180/M_PI;
    
    float cang = body.getRotation();
    if(cang > 180){ cang -= 360; }

    body.setRotation(cang + (vang-cang)*0.1);

    float cscl = body.getScale().x;
    float tscl = (vmag*BALL_VEL_STRETCH_FAC)+1;

    body.setScale(cscl + (tscl-cscl)*0.1, 1);
}

void Ball::ghostTrail(){
    //create a new ghost that trails the player every X ms
    if(CTIME-prev_ghost_time >= BALL_MS_PER_GHOST){
        prev_ghost_time = CTIME;

        last_ghost++;

        if(last_ghost - first_ghost >= BALL_GHOST_NUM-1){
            first_ghost++;
        }

        //loop the counts around if they exceed ghost num
        first_ghost %= BALL_GHOST_NUM;
        last_ghost %= BALL_GHOST_NUM;
        
        //make the last ghost a copy of the player body
        ghosts[last_ghost] = body;

        //make the ghosts fade as they get older
        for(uint i = first_ghost; i < BALL_GHOST_NUM; i++){
            if(i > last_ghost && first_ghost < last_ghost){ break; }

            sf::Color c = ghosts[i].getFillColor();
            uint a = ((float)(i - first_ghost)/(float)BALL_GHOST_NUM)*COL_MAX;

            ghosts[i].setFillColor(sf::Color(c.r,c.g,c.b,a));
        }

        if(first_ghost > last_ghost){
            for(uint i = 0; i < last_ghost; i++){
                sf::Color c = ghosts[i].getFillColor();
                uint a = (((float)(i+BALL_GHOST_NUM) - first_ghost)/
                         (float)BALL_GHOST_NUM)*COL_MAX;

                ghosts[i].setFillColor(sf::Color(c.r,c.g,c.b,a));
            }
        }
    }
}


void Ball::pulse(){
    //pulse ball radius
    body.setRadius(body.getRadius()*BALL_PULSE_SCALE_FAC);
    body.setOrigin(body.getRadius(), body.getRadius());
}

void Ball::explode(){
    explode_body = body;

    if(colored){
        explode_body.setOutlineColor(explode_body.getFillColor());
    }

    explode_body.setOutlineThickness(explode_body.getRadius());
    explode_body.setRadius(0.001);
    explode_body.setFillColor(sf::Color(0,0,0,0));
    explode_body.setOrigin(explode_body.getRadius(), explode_body.getRadius());

    body.setRadius(0);
}

void Ball::draw(sf::RenderWindow& window){
    //draw the ghosts
    for(uint i = first_ghost; i < BALL_GHOST_NUM; i++){
        if(i > last_ghost && first_ghost < last_ghost){ break; }

        window.draw(ghosts[i]);
    }

    if(first_ghost > last_ghost){
        for(uint i = 0; i < last_ghost; i++){
            window.draw(ghosts[i]);
        }
    }

    //render the death animation
    window.draw(explode_body);

    //render the circular player body
    window.draw(body);
}

sf::Vector2f Ball::getPosition(){
    //return ball's position
    return body.getPosition();
}

void Ball::setPosition(sf::Vector2f pos){
    body.setPosition(pos);
}

float Ball::getRadius(){
    return BALL_DEF_RADIUS;
}

void Ball::setRadius(float r){
    body.setRadius(r);
}


