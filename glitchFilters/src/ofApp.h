#pragma once

#include "ofxiOS.h"

class ofApp : public ofxiOSApp{
    
public:
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    ofVideoGrabber grabber;
    ofTexture tex;
    unsigned char * pix; //note: pointer, not a var
    
    ofVec2f pos0, pos1;
    int glitchSize;
    int modeCount;
    int totalPix;
    int myWidth, offSet, offSet2;
};
