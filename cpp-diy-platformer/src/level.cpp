#include "include/level.h"

void Level::generate(){
    //load in a neural net
    NeuNet net;
    net.read("testNet.dat");

    //generate random level data
    float est = 1;
    uint tries = 0;

    do{
        float data[LEVEL_DATA_SIZE];
        for(uint i = 0; i < LEVEL_DATA_SIZE; i++){
            data[i] = randf(0.0f,2.0f) - 1.0f;
        }

        Matrix m(data, LEVEL_DATA_SIZE);

        net.feedfwd(m);

        //if level is better than the previously stored one
        if(abs(m.data[0][0]) < est){
            est = abs(m.data[0][0]);

            //copy data into raw
            for(uint i = 0; i < LEVEL_DATA_SIZE; i++){
                raw[num_trials][i] = data[i];
            }
        }

        tries++;
    } while(est > LEVEL_OPTIMAL_TIME_TOLERANCE && tries < LEVEL_GEN_TRIES);

    cout << "Level generated! Estimated score: " << est << endl;
    
    //start building the level
    num_boxes = 0;

    float x = 0;
    float y = 0;
    float fh = 0;

    //for each box in the level
    for(uint i = 0; i <= LEVEL_DATA_SIZE-3; i += 3){
        //make a box at x, y
        float w = LEVEL_BOX_SCALE*abs(raw[num_trials][i])+LEVEL_BOX_MIN_SIZE;
        float h = LEVEL_BOX_SCALE*abs(raw[num_trials][i+1])+LEVEL_BOX_MIN_SIZE;

        if(i == 0){ fh = h; }

        boxes[i/3].init(x, y, w, h, true, 0);
        num_boxes++;

        //calculate parabolic jump path of player
        float t = (LEVEL_ARC_SCALE*abs(raw[num_trials][i+2]))+LEVEL_ARC_MIN_TIME;
        float d = raw[num_trials][i+2]/abs(raw[num_trials][i+2]);

        float vx = PLAYER_MOVE_SPEED*d*LEVEL_JUMP_DIST_FAC;
        float vy = -PLAYER_JUMP_VEL*LEVEL_JUMP_HEIGHT_FAC;
        float a = PLAYER_GRAVITY_ACC;

        float tx = vx*t;
        float ty = vy*t + 0.5*a*t*t;
        
        //if vertical bounds were exceeded, reduce time
        while(abs(y + ty) > LEVEL_BOUND_Y){
            t /= 2;

            tx = vx*t;
            ty = vy*t + 0.5*a*t*t;
        }

        //if horizontal bounds were exceeded, reverse direction
        if(abs(x + tx) > LEVEL_BOUND_X){ tx = -tx; }
        
        x += tx;
        y += ty;
    }

    //create player and goal
    player.init(0, -fh/2-10);
    
    goal_hit = false;
    goal.init(false, 
              LEVEL_GOAL_EXP_RAD_RATE, 
              LEVEL_GOAL_EXP_OUT_RATE);

    goal.setPosition(sf::Vector2f(x, y));

    assert(num_boxes <= LEVEL_MAX_BOXES);

    //set the start time to the current time
    start_time = CTIME;
}

void Level::learn(bool won){
    assert(num_trials+1 <= LEVEL_NUM_TRIALS);

    //score represents how close you were to the optimal time:
    //0 -> exactly on time
    //1 -> your time - optimal time = infinity

    float ela = (float)(CTIME - start_time);
    float score = 1 - exp(-abs(LEVEL_OPTIMAL_TIME - ela)/LEVEL_SCORE_SCALE);

    //score defaults to 1 if level was skipped
    quality[num_trials] = (won) ? score : 1;

    cout << "Level completed! Actual score: " << quality[num_trials] << endl;

    num_trials++;

    if(num_trials >= LEVEL_NUM_TRIALS){
        Matrix a[LEVEL_NUM_TRIALS];
        Matrix y[LEVEL_NUM_TRIALS];

        for(uint i = 0; i < LEVEL_NUM_TRIALS; i++){
            a[i] = Matrix(raw[i], LEVEL_DATA_SIZE);
            y[i] = Matrix(&quality[i], 1);
        }
        
        NeuNet net;
        net.read("testNet.dat");

        net.backprop(a, y, num_trials, 1000, 0.25, 0.0001);

        cout << "Training completed!" << endl;

        net.write("testNet.dat");

        num_trials = 0;
    }
}

uint Level::hitBox(sf::Vector2f position, sf::Vector2f target){
    //loop over all boxes and check if they collided with the circle
    uint ostate = NO_COL;

    for(uint i = 0; i < num_boxes; i++){
        uint state = boxes[i].collidesWith(position, target);

        if(state != NO_COL){
            if(ostate != NO_COL && ostate != state){
                ostate = BOTH_AXES;
            } else {
                ostate = state;
            }
        }
    }

    return ostate;
}

void Level::update(){
    //update the player and collision test
    player.update();

    //if player is outside level bounds, reset them
    if(abs(player.getTarget().x) > LEVEL_BOUND_X*1.5f ||
       abs(player.getTarget().y) > LEVEL_BOUND_Y*1.5f){
        player.kill();
    }

    //if player collided with a box, negate its velocity in that direction
    player.setOnGround(false);
    uint player_col = hitBox(player.getPosition(), player.getTarget());

    if(player_col == X_AXIS){
        player.stop(true, false);

    } else if(player_col == Y_AXIS_BOTTOM){
        player.stop(false, true);

    } else if(player_col == Y_AXIS_TOP){
        player.stop(false, true);
        player.setOnGround(true);

    } else if(player_col == BOTH_AXES){
        player.stop(true, true);
        player.setOnGround(true);
    }

    //if player reached the goal, wait then load next section
    sf::Vector2f linear_dist = player.getTarget() - goal.getPosition();
    float pg_dist = sqrt(pow(linear_dist.x,2) + pow(linear_dist.y,2));
    float goal_thresh = player.getRadius() + goal.getRadius(); 

    if(pg_dist < goal_thresh && goal_hit == false){
        goal.explode();
        goal_hit = true;
        goal_time = CTIME + LEVEL_LOAD_DELAY_MS;
    }

    if(goal_hit && goal_time <= CTIME){
        learn(true);
        generate();
    }

    //finally, add player velocity to position
    player.commit();
}

void Level::visual(){
    //update the visual components of player, goal and boxes
    player.visual();

    for(uint i = 0; i < num_boxes; i++){
        boxes[i].visual();
    }

    goal.visual();
}

void Level::input(InputState& istate){
    //make E/W move the player right and left, and JMP jump 
    if(istate.E.down != istate.W.down){
        if(istate.E.down){
            player.move(1);
        } else {
            player.move(-1);
        }
    }

    //jump on JMP down 
    if(istate.JMP.down && player.onGround()){
        player.jump();
    }

    if(istate.RST.down){
        reset_time += MS_PER_UPDATE;

        if(reset_time >= LEVEL_RESET_TIME){
           learn(false);
           generate();

           reset_time = 0;
        }
    } else {
        reset_time = 0;
    }
}

void Level::beat(){
    //call beat for each block and the player
    player.beat();

    for(uint i = 0; i < num_boxes; i++){
        boxes[i].beat();
    }

    //pulse goal radius along with beat
    goal.pulse();
}

void Level::draw(sf::RenderWindow& window){
    //render each block, goal, and the player
    for(uint i = 0; i < num_boxes; i++){
        boxes[i].draw(window);
    }

    player.draw(window);

    goal.draw(window);
}
