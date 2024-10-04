//
//  cristal.cpp
//  SimuladorCristal
//
//  Created by Federico Joselevich Puiggrós on 01/11/2018.
//

#include "cristal.hpp"

void Cristal::setup(ofVec3f _pos) {
    pos = _pos;

}
void Cristal::update() {
    if (r > dr) r--;
    else if (r < dr) r++;
}

void Cristal::draw()
{
    ofPushMatrix();    
    ofTranslate(pos);
    ofRotateYDeg(r);
    ofSetColor(c);
    ofDrawRectangle(-12,-250,24,250);
    ofTranslate(0,0,-1);
    ofSetColor(20);
    ofDrawRectangle(-12,-250,24,250);
    ofRotateYDeg(90);
    ofTranslate(ofVec3f(0,0,-12));
    ofDrawRectangle(-24,-250,24,250);
    ofTranslate(ofVec3f(0,0,24));
    ofDrawRectangle(-24,-250,24,250);
    ofPopMatrix();
}


void Cristal::goTo(float _dr) {
    dr = _dr;
}
