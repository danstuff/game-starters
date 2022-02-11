#include "include/title.h"

void Title::init(string body_text){
    if(!font.loadFromFile(TITLE_FONT_FN)){ return; } 

    enabled = true;

    body.setFont(font);
    body.setString(body_text);
    body.setCharacterSize(64);
    //body.setLineSpacing(0.75f);
    //body.setLetterSpacing(1.25f);
    
    body.setPosition(W/2, H/2);

    //set origin to be the middle of the text
    sf::FloatRect r = body.getLocalBounds();
    body.setOrigin(r.width/2, r.height);
}

void Title::visual(){
    float sx = body.getScale().x;
    float sy = body.getScale().y;

    //gradually scale back to 1
    if(sx > 1 || sy > 1 && enabled){
        body.setScale(sx - (sx-1)*0.1f, sy - (sy-1)*0.1f);
    }

    if(enabled){
        //oscillate rotation
        body.setRotation(sin(CTIME/100)*TITLE_ROT_FAC);
        body.setPosition(W/2, H/2);
        body.setFillColor(colorWheel(COL_REGULAR));
    } else {
        //fly off the screen if disabled
        float y = body.getPosition().y; 
        body.setPosition(W/2, y - (y-TITLE_OFF_TARGET)*0.005f);
    }

    //set origin to be the middle of the text
    sf::FloatRect r = body.getLocalBounds();
    body.setOrigin(r.width/2, r.height);
}

void Title::beat(){
    if(!enabled){ return; }

    //pulse the title
    body.setScale(TITLE_SCALE_FAC, TITLE_SCALE_FAC); 

    //set origin to be the middle of the text
    sf::FloatRect r = body.getLocalBounds();
    body.setOrigin(r.width/2, r.height);
}

void Title::input(InputState& istate){
    if(istate.N.down || istate.S.down ||
       istate.E.down || istate.W.down ||
       istate.JMP.down || istate.ESC.down ||
       istate.RST.down){
        enabled = false;
    }
}

void Title::draw(sf::RenderWindow& window){
    window.draw(body);
}
