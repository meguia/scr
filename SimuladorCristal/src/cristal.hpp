//
//  cristal.hpp
//  SimuladorCristal
//
//  Created by Federico Joselevich Puiggrós on 01/11/2018.
//

#ifndef cristal_hpp
#define cristal_hpp

#include <stdio.h>
#include "ofMain.h"

class Cristal {
public:
    void setup(ofVec3f _pos);
    void draw();
    void update();
    
    void goTo(float _dr);
    
    
    ofVec3f pos;
    float r, dr;
    ofColor c;
    ofLight light;
    ofMaterial material;
    ofBoxPrimitive geometry;
};

#endif /* cristal_hpp */
