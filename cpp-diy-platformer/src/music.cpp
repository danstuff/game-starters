#include "include/music.h"

void Music::load(){
    //load in all the sounds from file
    for(uint i = 0; i < BEAT_LAYER_NUM; i++){
        string fn = BEAT_LAYER_FILES[i]; 

        //ensure that the sound buffer loads properly
        if(layers[i].sound_buffer.loadFromFile(fn)){
            
            //link sound to buffer
            layers[i].sound.setBuffer(layers[i].sound_buffer);

            //calculate number of beats for each sound play
            uint dur = (uint) layers[i].sound_buffer
                                .getDuration()
                                .asMilliseconds();
            layers[i].beat_steps = dur /  MS_PER_BEAT;

            //all layers but the 0th default to not enabled
            if(i == 0){
                layers[i].enabled = true;
            } else {
                layers[i].enabled = false;
            }
        }
    }
}

void Music::beat(){
    //play each beat layer as beats are hit
    for(uint i = 0; i < BEAT_LAYER_NUM; i++){
        uint bs = layers[i].beat_steps;

        if(layers[i].enabled && total_beats % bs == 0){
            assert(layers[i].sound.getBuffer());
            layers[i].sound.setVolume(volume);
            layers[i].sound.play();
        }
    }

    total_beats++;
}

void Music::setVolume(uint nvol){
    volume = ((float) nvol / 8.0f) * 100;
}

void Music::toggleLayer(uint layer_index){
    //enable/disable layer based on current state
    assert(layer_index < BEAT_LAYER_NUM);
    layers[layer_index].enabled = !layers[layer_index].enabled;
}

void Music::enableLayer(uint layer_index){
    //start playing a layer
    assert(layer_index < BEAT_LAYER_NUM);
    layers[layer_index].enabled = true;
}

void Music::disableLayer(uint layer_index){
    //stop playing a layer
    assert(layer_index < BEAT_LAYER_NUM);
    layers[layer_index].enabled = false;
}
