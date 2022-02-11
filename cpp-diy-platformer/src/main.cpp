#include "include/game.h"

Game g;

int run(){
    //create a clock and intialize lag time
    sf::Clock loop_clock;
    double lag_time = 0;

    //keep track of how long its been since the last music beat
    double time_since_beat = 0;

    while(g.isOpen()){
        double elapsed = loop_clock.restart().asMicroseconds()/1000.0;

        //increment lag time, beat time, and global timer
        lag_time += elapsed;
        time_since_beat += elapsed;
        CTIME += elapsed;

        //process events
        g.events();

        //play a music beat if enough ms have elapsed
        if(time_since_beat >= MS_PER_BEAT){
            g.beat();

            time_since_beat -= MS_PER_BEAT;
        }

        //process input and update continuously to kill time
        while(lag_time >= MS_PER_UPDATE){
            g.input();
            g.update();
            
            lag_time -= MS_PER_UPDATE;
        }

        g.draw();
    }

    g.quit();

    return 0;
}

int main(){
    g.init();

    return run();
}
