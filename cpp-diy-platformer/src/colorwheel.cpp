#include "include/colorwheel.h"

sf::Color drk_samples[COL_SAMPLES];
sf::Color reg_samples[COL_SAMPLES];
sf::Color lht_samples[COL_SAMPLES];

bool COL_DARK_ON = false;
bool COL_REGULAR_ON = false;
bool COL_LIGHT_ON = false;

void colorGenSamples(sf::Color* samp, uint shift, uint bright, float scale){
    //generate all the samples from the rainbow colors
    for(uint i = 0; i < COL_SAMPLES; i++){
        uint t = i + shift;

        uint lt = t % (COL_MAX*3);
        uint ct = t % COL_MAX;

        uint rise = (COL_MAX - ct)*scale;
        uint fall = (ct)*scale;

        rise = (rise > bright) ? rise : bright;
        fall = (fall > bright) ? fall : bright;
        
        if(lt < COL_MAX){
            //red turning into green
            samp[i] = sf::Color(rise, fall, bright);
        } else if(lt < COL_MAX*2){
            //green turning into blue
            samp[i] = sf::Color(bright, rise, fall);
        } else {
            //blue turning into red
            samp[i] = sf::Color(fall, bright, rise);
        }
    }
}

void colorInit(){
    //generate the rainbows used by visible objects
   colorGenSamples(drk_samples, COL_DRK_SHI, COL_DRK_BRI, COL_DRK_SCA);
   colorGenSamples(reg_samples, COL_REG_SHI, COL_REG_BRI, COL_REG_SCA);
   colorGenSamples(lht_samples, COL_LHT_SHI, COL_LHT_BRI, COL_LHT_SCA); 
}

sf::Color colorWheel(ColType type){
    //calculate what percentage of the wheel you've gone through so far
    uint t_ms = (uint) CTIME % COL_MS_PER_REV;
    float rev_pct = (float) t_ms / (float) COL_MS_PER_REV;
    
    //calculate the index of that percentage
    uint i = (uint)(rev_pct*COL_SAMPLES + 0.5);

    assert(i < COL_SAMPLES);

    //return color based on color type
    switch(type){
        case COL_DARK:
            return (COL_DARK_ON)    ? drk_samples[i] : COL_DRK_DEFAULT;
            break;
        case COL_REGULAR:
            return (COL_REGULAR_ON) ? reg_samples[i] : COL_REG_DEFAULT;
            break;
        case COL_LIGHT:
            return (COL_LIGHT_ON)   ? lht_samples[i] : COL_LHT_DEFAULT;
            break;
    }

    return reg_samples[i];
}
