#pragma once

#include "ofMain.h"
#include "cristal.hpp"
#include "ofxOsc.h"

#define MODULE_ALL      0
#define MODULE_ELEMENT  1
#define MODULE_ROW      2
#define MODULE_COL      3
#define MODULE_GROUP    4
#define MODULE_ELEMENTS 5

// listening port
#define PORT 8000



class ofApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();

		void keyPressed(int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void mouseEntered(int x, int y);
		void mouseExited(int x, int y);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);

    ofEasyCam cam; // add mouse controls for camera movement
    bool bHelpText;
    ofLight light;

    Cristal cristales[5][4][5];
    
    void doCommand(string command, int module, int moduleidx, int r, int g, int b, int t);

    ofxOscReceiver receiver;

};


