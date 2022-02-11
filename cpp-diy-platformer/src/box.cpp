#include "include/box.h"

void Box::init(float x, float y, float w, float h,
               bool i_enabled, uint i_beats){
    //initialize box with arguments
    body.setPosition(x, y+h/2);
    body.setSize(sf::Vector2f(w, h));
    body.setOrigin(w/2, h/2);
    body.setFillColor(colorWheel(COL_LIGHT));

    enabled = i_enabled;
    
    beats = i_beats;

    //make sure the box is on if it doesn't beat
    if(beats == 0){
        enabled = true;
    }

    beat_count = 0;
}

void Box::visual(){
    //update box color
    body.setFillColor(colorWheel(COL_LIGHT));
}

void Box::beat(){
    if(beats == 0){
        return;
    }

    //check if box should appear/disappear based on beat
    beat_count++;

    //toggle if count exceeds off or beats
    if(beat_count > beats){
        enabled = !enabled;
        beat_count = 0;
    }
}

void Box::draw(sf::RenderWindow& window){
    //render the box body
    if(enabled){ 
        window.draw(body);
    }
}

uint Box::collidesWith(sf::Vector2f p, sf::Vector2f t){
    //check if the box will collide with target position t
    //returns NO_COL if no collision
    //returns X_AXIS if collision on x axis
    //returns Y_AXIS if collision on y axis
    if(!enabled){ return NO_COL; }

    //fetch all required variables
    int bx = (int) body.getPosition().x;
    int by = (int) body.getPosition().y;

    int bw = (int) body.getSize().x;
    int bh = (int) body.getSize().y;

    //do a simple box/point intersection test
    if(bx-bw/2 < t.x && t.x < bx+bw/2 &&
       by-bh/2 < t.y && t.y < by+bh/2){
        if(bx-bw/2 < p.x && p.x < bx+bw/2){
            if(by < p.y){ return Y_AXIS_BOTTOM; } 
            else { return Y_AXIS_TOP; }
        }
        
        if(by-bh/2 < p.y && p.y < by+bh/2){
            return X_AXIS;
        }
    }

    return NO_COL;
}
