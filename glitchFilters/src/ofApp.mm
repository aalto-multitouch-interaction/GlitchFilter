#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetFrameRate(30);
    
    //Initialise Video Grabber
    grabber.setup(1280,720, OF_PIXELS_BGRA);
    //Create texture map
    tex.allocate(grabber.getWidth(), grabber.getHeight(), GL_RGB);
    
    //Pixel array with the amount of pixels times 3 (for channels R,G,B)
    pix = new unsigned char[ (int)( grabber.getWidth() * grabber.getHeight() * 3) ];
    
    modeCount = 1;
    glitchSize = 200000; //original size of glitch filter
    offSet = 1;
    offSet2 = 1;
}

//--------------------------------------------------------------
void ofApp::update(){
  
    ofBackground(0);
    grabber.update(); //update video
    
    myWidth = int(grabber.getWidth()*3); //the width of one line of pixels on the screen (3 channels)
    int touchPos= pos0.x+pos0.y*myWidth; //position of touch related to pixel array
    
    
    //Load and store pixels into "src" every time there's a new frame
    if(grabber.isFrameNew() == true) {
        ofPixels & pixels = grabber.getPixels();
        unsigned char * src = pixels.getData();
        totalPix = grabber.getWidth() * grabber.getHeight() * 3;
        
        //Set the original "normal" image as a base
        for(int k = 0; k < totalPix; k++){
            pix[k] = src[k];
        }
        
        
        //**** GLITCH FILTERS ****//
        
        //MODE 01 GRAINY INVERT
        if (glitchSize>0 && glitchSize<totalPix && modeCount == 1){
            
            if(pos1.y > pos0.y){    //Pinch: if second touch is below first
                for (int j = touchPos; j < touchPos + glitchSize; j+=3) {
                    if(j<0)j=0;
                    if(j>totalPix)j=totalPix;
                    
                    pix[j] = ofRandom(240,250) - src[j];
                    pix[j-20] = ofRandom(1000)*j - src[j];
                }
            }else if(pos1.y < pos0.y){  //Pinch: if second touch is above first
                for (int j = touchPos; j > (touchPos - glitchSize); j-=3) {
                    if(j<0)j=0;
                    if(j>totalPix)j=totalPix;
                    
                    pix[j] = ofRandom(240,250)  - src[j];
                    pix[j-20] = ofRandom(1000) - src[j];
                }
            }
        }
        
        //MODE 02 MIRRORED COLOR OFFSET
        if (glitchSize>0 && glitchSize<totalPix && modeCount == 2){
            
            if(pos1.y > pos0.y){    //Pinch: if second touch is below first
                for (int j = touchPos; j < (touchPos + glitchSize); j+=3) {
                    if(j<0)j=0;
                    if(j>totalPix)j=totalPix;
                    
                    pix[j  ] = src[totalPix-j];
                    pix[j+1] = src[totalPix-(j+1)];
                    pix[j+2] = src[totalPix-(j+2)];
                    if(pix[j]%200) pix[j] = 255- src[j];
                }
            }else if(pos1.y < pos0.y){  //Pinch: if second touch is above first
                for (int j = touchPos; j > (touchPos - glitchSize); j-=3) {
                    if(j<0)j=0;
                    if(j>totalPix)j=totalPix;
                    
                    pix[j  ] = src[totalPix -j];
                    pix[j+1] = src[totalPix -(j+1)];
                    pix[j+2] = src[totalPix -(j+2)];
                    if(pix[j]%200) pix[j] = 255-src[j];
                }
            }
        }
        
        //MODE 03 EXTEND PIXEL
        if (glitchSize>0 && glitchSize<totalPix && modeCount == 3){
            
            if(pos1.y > pos0.y){    //Pinch: if second touch is below first
                for (int j = touchPos; j < touchPos + glitchSize/3; j+=3) { //1st third of area
                    if(j<0)j=0;
                    if(j>totalPix)j=totalPix;
                    pix[j  ] = src[j % myWidth + offSet];
                    pix[j+1] = src[j % myWidth + offSet +1];
                    pix[j+2] = src[j % myWidth + offSet +2];
                }
                for (int j = touchPos + glitchSize/3; j < touchPos + 2*(glitchSize/3); j+=3) { //2nd third of area
                    if(j<0)j=0;
                    if(j>totalPix)j=totalPix;
                    pix[j  ] = src[j % myWidth + offSet + 5];
                    pix[j+1] = src[j % myWidth + offSet + 10];
                    pix[j+2] = src[j % myWidth + offSet + 15];
                }
                for (int j = touchPos + 2*(glitchSize/3); j < touchPos + glitchSize; j+=3) { //3rd third of area
                    if(j<0)j=0;
                    if(j>totalPix)j=totalPix;
                    pix[j  ] = src[j % myWidth + offSet - 10];
                    pix[j+1] = src[j % myWidth + offSet - 10];
                    pix[j+2] = src[j % myWidth + offSet - 10];
                }
            }else if(pos1.y < pos0.y){  //Pinch: if second touch is above first
                for (int j = touchPos; j > touchPos - glitchSize/3; j-=3) {
                    if(j<0)j=0;
                    if(j>totalPix)j=totalPix;
                    pix[j  ] = src[j % myWidth + offSet2];
                    pix[j+1] = src[j % myWidth + offSet2 +1];
                    pix[j+2] = src[j % myWidth + offSet2 +2];
                }
                for (int j = touchPos - glitchSize/3; j > touchPos - 2*(glitchSize/3); j-=3) { //2nd third of area
                    if(j<0)j=0;
                    if(j>totalPix)j=totalPix;
                    pix[j  ] = src[j % myWidth + offSet2 + 5];
                    pix[j+1] = src[j % myWidth + offSet2 + 10];
                    pix[j+2] = src[j % myWidth + offSet2 + 15];
                }
                for (int j = touchPos - 2*(glitchSize/3); j > touchPos - glitchSize; j-=3) { //3rd third of area
                    if(j<0)j=0;
                    if(j>totalPix)j=totalPix;
                    pix[j  ] = src[j % myWidth + offSet2 - 10];
                    pix[j+1] = src[j % myWidth + offSet2 - 10];
                    pix[j+2] = src[j % myWidth + offSet2 - 10];
                }
            }
        }
        
        //MODE 04 LINES
        int lineLen = 25;
        if (glitchSize>0 && glitchSize<totalPix && modeCount == 4){
            if(pos1.y > pos0.y){    //Pinch: if second touch is below first
                for (int j = touchPos; j < (touchPos + glitchSize); j+=lineLen*3) {
                    if(j<0)j=0;
                    if(j>totalPix)j=totalPix;
                    
                    int firstPix = src[j];
                    for (int i=j; i<j+lineLen*3; i+=3){
                        if(i<0)i=0;
                        if(i>totalPix)i=totalPix;
                        pix[i  ] = firstPix;
                        pix[i+1] = firstPix+10;
                    }
                }
            }else if(pos1.y < pos0.y){  //Pinch: if second touch is above first
                for (int j = touchPos; j > (touchPos - glitchSize); j-=lineLen*3) {
                    if(j<0)j=0;
                    if(j>totalPix)j=totalPix;
                    
                    int firstPix = src[j];
                    for (int i=j; i<j+lineLen*3; i+=3){
                        if(i<0)i=0;
                        if(i>totalPix)i=totalPix;
                        pix[i  ] = firstPix;
                        pix[i+1] = firstPix+10;
                    }
                }
            }
        }
        
        //MODE 05 BLOCKS
        if (glitchSize>0 && glitchSize<totalPix && modeCount == 5){
            int blockLen = 20;
            if(pos1.y > pos0.y){    //Pinch: if second touch is below first
                for (int j = touchPos; j < (touchPos + glitchSize); j+=blockLen*3) {
                    if(j<0)j=0;
                    if(j>totalPix)j=totalPix;
                    
                    int firstPix = src[j];
                    for (int i=j; i<j+blockLen*3; i+=3){
                        if(i<0)i=0;
                        if(i>totalPix)i=totalPix;
                        pix[i  ] = firstPix;
                        pix[i+1] = firstPix;
                    }
                }
            }else if(pos1.y < pos0.y){  //Pinch: if second touch is above first
                for (int j = touchPos; j > (touchPos - glitchSize); j-=blockLen*3) {
                    if(j<0)j=0;
                    if(j>totalPix)j=totalPix;
                    
                    int firstPix = src[j];
                    for (int i=j; i<j+blockLen*3; i+=3){
                        if(i<0)i=0;
                        if(i>totalPix)i=totalPix;
                        pix[i  ] = firstPix;
                        pix[i+1] = firstPix;
                    }
                }
            }
        }
        
        
    }
    //Load all pixels into the texture
    tex.loadData(pix, grabber.getWidth(), grabber.getHeight(), GL_RGB);
    
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    //Draw original camera input
    //grabber.draw(0, 0);
    
    //Draw the texture
    tex.draw(57, 0, tex.getWidth(), tex.getHeight());
}

//--------------------------------------------------------------
void ofApp::exit(){
    
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    if(touch.id==0)pos0.set(touch);
    if(touch.id==1)pos1.set(touch);
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    
    if(touch.id==0) {pos0.set(touch);
        offSet = pos0.y*myWidth;}    //Position of first touch for modes 4 & 5
      
    if(offSet>totalPix)offSet=totalPix;
        if(offSet<0)offSet=0;
    
    if(touch.id==1){
        pos1.set(touch);
        glitchSize = ofDist(pos0.x, pos0.y, pos1.x, pos1.y)*myWidth;
        offSet2 = pos1.y*myWidth;   //Position of second touch for modes 4 & 5
      
        if(offSet2>totalPix)offSet2=totalPix;
        if(offSet2<0)offSet2=0;
    }
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    modeCount<5? modeCount++ : modeCount=1;
    
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
    
}


