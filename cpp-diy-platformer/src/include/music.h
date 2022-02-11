//================MUSIC.H================
// Composes several rythmic sound files 
// into a dynamically generated song.
// Each beat layer is a rythmic sound
// that can be turned on or off as the
// game is played.
//=======================================

#pragma once

#ifndef MUSIC_H
#define MUSIC_H

#include <cassert>

#include <SFML/Audio.hpp>

#include "global.h"

const string BEAT_LAYER_FILES[] = {
    "res/sound/test1.wav",
    "res/sound/test2.wav",
    "res/sound/test3.wav",
    "res/sound/test4.wav"
};

const uint BEAT_LAYER_NUM = 4;

struct BeatLayer{
    //SF sound/buffer instances
    sf::Sound sound;
    sf::SoundBuffer sound_buffer;

    //true if beat layer is currently playing
    bool enabled;

    //how many beats until sound plays again
    uint beat_steps;
};

class Music{
    private:
        BeatLayer layers[BEAT_LAYER_NUM];

        //number of beats since game started
        uint total_beats;

        //voulme of all played sounds
        uint volume;

    public: 
        Music(){};

        //main loop funciton
        void load();
        void beat();

        //volume control
        void setVolume(uint nvol);

        //control whether a layer should play
        void toggleLayer(uint layer_index);
        void enableLayer(uint layer_index);
        void disableLayer(uint layer_index);
};

#endif
