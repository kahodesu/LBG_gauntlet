
import ioio.lib.api.*;
import ioio.lib.api.exception.*;
import com.pinkhatproductions.pioio.*;

// for connection to pc host
static {
  // leave commented out to auto-discover serial port (SLOW!)  
  //System.setProperty("ioio.SerialPorts", "/dev/tty.usbmodem1411");
}
PwmOutput[] pinArray = new PwmOutput[8];
DigitalOutput[] digPinArray = new DigitalOutput[8];
int mode = 0;

int[] row={29,30,31,32,34,35,36,37};
int[] rowMixed={34,37,30,36,31,35,32,29};
  
void setup() {
  
  size(displayWidth, displayHeight);
  noStroke();

  textAlign(CENTER, CENTER);
  textSize(128);

  new PIOIOManager(this).start();
}

void draw() {
  fill(0);
  rect(0, 0, width, height);
}

void ioioSetup(IOIO ioio) throws ConnectionLostException {
  
}

void ioioLoop(IOIO ioio) throws ConnectionLostException {
  fill(255);
  text(mode, width/2, height/2);
  
////BLACKOUT-----------------------------  
  if (mode == 0){
    for(int i=0;i<digPinArray.length;i++) {
      digPinArray[i]= ioio.openDigitalOutput(row[i], true);
    }
    for(int i=0;i<digPinArray.length;i++) {
      digPinArray[i].write(false);
      digPinArray[i].close(); 
    }
    delay(3000);
    mode = 1;
  }
  
////SHIMMER---------------------------   
  else if (mode == 1) {
    for(int i=0;i<pinArray.length;i++) {
      pinArray[i] = ioio.openPwmOutput(rowMixed[i],1000);
      for (int j = 0; j < 10; j++) {
        pinArray[i].setDutyCycle(0.5-(sin(j/5.0))/2); // status LED is active low, hence the "1.0 -" 
        delay(200);
      } 
      pinArray[i].close(); 
    }
    mode = 2;
  }
  
////POWER------------------------------------   
  else if (mode == 2) {
    for(int i=0;i<digPinArray.length;i++) {
      digPinArray[i]= ioio.openDigitalOutput(row[i], false);
    }
    for(int i=0;i<digPinArray.length;i++) {
      digPinArray[i].write(true); // status LED is active low, hence the "1.0 -" 
      delay(1000);
    }
    for(int i=0;i<digPinArray.length;i++) {
      digPinArray[i].write(false);
      digPinArray[i].close();
    }
    delay(500);
    mode = 3; //goes to shoot!!!
  }
  
////SHOOT------------------------------------   
  else if (mode == 3) {
    for(int i=0;i<digPinArray.length;i++) {
      digPinArray[i]= ioio.openDigitalOutput(row[i], true);
    }
    delay(3000);
    for(int i=0;i<digPinArray.length;i++) {
      digPinArray[i].write(false);
      digPinArray[i].close();
    }
    mode = 0; //goto black out
  }
//-----------------------------------------------  
  try {
    Thread.sleep(20);
  }
  catch(InterruptedException e) {
  }
}
