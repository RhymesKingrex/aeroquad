/*
  AeroQuad v3.0 - May 2011
  www.AeroQuad.com
  Copyright (c) 2011 Ted Carancho.  All rights reserved.
  An Open Source Arduino based multicopter.
 
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

#ifndef _AEROQUAD_ACCELEROMETER_CHR6DM_H_
#define _AEROQUAD_ACCELEROMETER_CHR6DM_H_

#include <Accelerometer.h>
#include <Platform_CHR6DM.h>

CHR6DM *accelChr6dm;

void initializeAccel() {
  accelScaleFactor = 0;
  accelSmoothFactor = 1.0;
}

void measureAccel() {
  float accelADC[3];
  accelADC[XAXIS] = accelChr6dm->data.ax - accelZero[XAXIS];
  accelADC[YAXIS] = accelChr6dm->data.ay - accelZero[YAXIS];
  accelADC[ZAXIS] = accelChr6dm->data.az - accelOneG;

  meterPerSec[XAXIS] = filterSmooth(accelADC[XAXIS], meterPerSec[XAXIS], accelSmoothFactor); //to get around 1
  meterPerSec[YAXIS] = filterSmooth(accelADC[YAXIS], meterPerSec[YAXIS], accelSmoothFactor);
  meterPerSec[ZAXIS] = filterSmooth(accelADC[ZAXIS], meterPerSec[ZAXIS], accelSmoothFactor);
}

void calibrateAccel() {
  float zeroXreads[FINDZERO];
  float zeroYreads[FINDZERO];
  float zeroZreads[FINDZERO];

  for (int i=0; i<FINDZERO; i++) {
    accelChr6dm->requestAndReadPacket();
    zeroXreads[i] = accelChr6dm->data.ax;
    zeroYreads[i] = accelChr6dm->data.ay;
    zeroZreads[i] = accelChr6dm->data.az;
  }

  accelZero[XAXIS] = findMedianFloat(zeroXreads, FINDZERO);
  accelZero[YAXIS] = findMedianFloat(zeroYreads, FINDZERO);
  accelZero[ZAXIS] = findMedianFloat(zeroZreads, FINDZERO);
   
  // store accel value that represents 1g
  accelOneG = accelZero[ZAXIS];
}

#endif
