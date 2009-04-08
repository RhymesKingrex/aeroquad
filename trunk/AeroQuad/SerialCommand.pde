/*
  AeroQuad v1.0 - April 2009
  www.AeroQuad.info
  Copyright (c) 2009 Ted Carancho.  All rights reserved.
  An Arduino based quadrocopter using the Sparkfun 5DOF IMU and IDG300 Dual Axis Gyro
  This version will be able to use gyros for stability (acrobatic mode) or accelerometers (experimental stable mode).
 
  This program is free software: you can redistribute it and/or modify 
  it under the terms of the GNU General Public License as published by 
  the Free Software Foundation, either version 3 of the License, or 
  (at your option) any later version. 

  This program is distributed in the hope that it will be useful, 
  but WITHOUT ANY WARRANTY; without even the implied warranty of 
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
  GNU General Public License for more details. 

  You should have received a copy of the GNU General Public License 
  along with this program. If not, see <http://www.gnu.org/licenses/>. 
*/

void readSerialCommand() {
  // Check for serial message
  if (Serial.available()) {
    digitalWrite(LEDPIN, LOW);
    queryType = Serial.read();
    if (queryType == 'C') {
      // Configure user defined values
      PID[ROLL].P = readFloatSerial();
      PID[ROLL].I = readFloatSerial();
      PID[ROLL].D = readFloatSerial();
      PID[ROLL].lastPosition = 0;
      PID[ROLL].integratedError = 0;
      PID[PITCH] = PID[ROLL];
      PID[LEVELROLL].P = readFloatSerial();
      PID[LEVELROLL].I = readFloatSerial();
      PID[LEVELROLL].D = readFloatSerial();
      PID[LEVELROLL].lastPosition = 0;
      PID[LEVELROLL].integratedError = 0;
      PID[LEVELPITCH] = PID[LEVELROLL];
      PID[YAW].P = readFloatSerial();
      PID[YAW].I = readFloatSerial();
      PID[YAW].D = readFloatSerial();
      PID[YAW].lastPosition = 0;
      PID[YAW].integratedError = 0;
      windupGuard = readFloatSerial();
      levelLimit = readFloatSerial();
      levelInterval = readFloatSerial();
      xmitFactor = readFloatSerial();
      smoothFactor[GYRO] = readFloatSerial();
      smoothFactor[ACCEL] = readFloatSerial();
      timeConstant = readFloatSerial();
    }
    else if (queryType == 'W') {
      writeFloat(PID[ROLL].P, PGAIN_ADR);
      writeFloat(PID[ROLL].I, IGAIN_ADR);
      writeFloat(PID[ROLL].D, DGAIN_ADR);
      writeFloat(PID[LEVELROLL].P, LEVEL_PGAIN_ADR);
      writeFloat(PID[LEVELROLL].I, LEVEL_IGAIN_ADR);
      writeFloat(PID[LEVELROLL].D, LEVEL_DGAIN_ADR);
      writeFloat(PID[YAW].P, YAW_PGAIN_ADR);
      writeFloat(PID[YAW].I, YAW_IGAIN_ADR);
      writeFloat(PID[YAW].D, YAW_DGAIN_ADR);
      writeFloat(windupGuard, WINDUPGUARD_ADR);  
      writeFloat(levelLimit, LEVELLIMIT_ADR);   
      writeFloat(levelInterval, LEVELINTERVAL_ADR); 
      writeFloat(xmitFactor, XMITFACTOR_ADR);
      writeFloat(smoothFactor[GYRO], GYROSMOOTH_ADR);
      writeFloat(smoothFactor[ACCEL], ACCSMOOTH_ADR);
      writeFloat(timeConstant, FILTERTERM_ADR);
      zeroIntegralError();
      
      // Complementary filter setup
      configureFilter(timeConstant);
    }
    /*else if (queryType =='M') { // remotely configure receiver order
      for (channel = ROLL; channel < LASTCHANNEL; channel++) {
        orderCh[channel] = readFloatSerial();
        writeFloat(orderCh[channel], ROLLCH_ADR + (channel * 4));
      }
      for (channel = ROLL; channel < LASTCHANNEL; channel++) {
        xmitCh[channel] = readFloatSerial();
        writeFloat(xmitCh[channel], ROLLPIN_ADR + (channel * 4));
      }
    }*/
  digitalWrite(LEDPIN, HIGH);
  }
}

// Used to read floating point values from the serial port
float readFloatSerial() {
  byte index = 0;
  byte timeout = 0;
  char data[128] = "";

  do {
    if (Serial.available() == 0) {
      delay(10);
      timeout++;
    }
    else {
      data[index] = Serial.read();
      timeout = 0;
      index++;
    }
  }  while ((data[limitRange(index-1, 0, 128)] != ';') && (timeout < 5) && (index < 128));
  return atof(data);
}
