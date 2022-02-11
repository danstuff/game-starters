#include "include/material.h"

static float getFacBase() {
    return float(rand() % 2000) / 1000 + 0.5;
}

Material::Material(Rarity rarity, int seed) {
    srand(seed);

    float rarefac = float(rarity)/float(RARITY_MAX);

    weightFac = getFacBase() - rarefac;
    healthFac = getFacBase() + rarefac;
    energyCapacityFac = getFacBase() + rarefac;
    energyRateFac = getFacBase() + rarefac * 2;

}
