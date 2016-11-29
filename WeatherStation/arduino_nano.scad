/* arduino_nano.scad
 *
 * Copyright (C) Graham Jones, 2013 
 * (based on arduino.scad by Jestin Stoffel 2012)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the Free
 * Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/*
 * Usage - in your file do include <arduino_nano.scad>, then call
 * Arduino_Nano();
 */

/********************************************************************
 * Dimensions from 
 *   http://arduino.cc/en/uploads/Main/ArduinoNanoManual23.pdf
 *********************************************************************
 */
// Main board
x = 1.7 * 25.4;  // length of board
y = 0.73 * 25.4; // width of board in mm
th = 1.6;  // mm

// Mounting Holes
hole_off = 0.06 * 25.4; // offset from edges of board in mmm
hole_dia = 0.07 * 25.4; // hole diameter in mmm
hole_h   = 10;				// length of cylinder to make holes

// Headers
head_xoff = 0.15 * 25.4; // offset of first header pin along x axis.
head_yoff = 0.5*(0.73-0.6) * 25.4; // offset of header in y direction.
head_pinh = 5;           // height of pin in mm.
head_pind = 1;           // diameter of header pin in mm
head_pinsep = 0.1 * 25.4; // separation between header pins.
head_npin   = 15;         // number of pins. 

// ICSP
icsp_xoff = 0.06 * 25.4;  // my guess
icsp_nxpin = 2;           // number of pins in x direction
icsp_nypin = 3;           // number of pins in y direction.
icsp_pinsep = 0.1 * 25.4; // pin separation
icsp_pinh = 10;
icsp_pind  = 1;			  // icsp pin diameter
icsp_yoff = (y - icsp_pinsep * (icsp_nypin-1)) / 2;

pin_base_x = 0.1*25.4;  // size of square base around pins
pin_base_z = 0.1*25.4;  // height of square base around pins

usb_x = 5; 
usb_y = 7.5;
usb_z = 3;
usb_off = 2;  // How much it sticks out from the board in x direction.

// Misc
tol = 0.1;						// general tolerance to oversize things a bit.


/* Main module to draw the complete arduino nano from components */
module Arduino_Nano(headers=1, holes=0) {

	if (headers==1)
		union() {
			board(holes);
			headers();
		}
	else
		difference() {
			union() {
				board(holes);
			}
			headers();
		}
}


module usb() {
	translate([x+usb_off-usb_x,0.5*(y-usb_y),th-tol])
		cube([usb_x,usb_y,usb_z+tol]);

}

module icsp() {
	// Pins
	for (xpinNo = [0:icsp_nxpin-1]) {
		for (ypinNo = [0:icsp_nypin-1]) {
			translate([icsp_xoff+icsp_pinsep*xpinNo,
							icsp_yoff+icsp_pinsep*ypinNo,
							-tol])
				cylinder(r=icsp_pind/2, h=icsp_pinh+tol);
		}
	}
	// Plastic Base
	color([0,0,0])
		translate([icsp_xoff-pin_base_x/2,
						icsp_yoff-pin_base_x/2,
						th-tol])
			cube([icsp_nxpin*pin_base_x,
					icsp_nypin*pin_base_x,
					pin_base_z+tol]);
}

module headers() {
	// Pins
	for (pinNo = [0:head_npin-1]) {
		translate([head_xoff+head_pinsep*pinNo,head_yoff,-1*head_pinh])
			cylinder(r=head_pind/2, h=head_pinh+th+tol);
		translate([head_xoff+head_pinsep*pinNo,y-head_yoff,-1*head_pinh])
			cylinder(r=head_pind/2, h=head_pinh+th+tol);
	}
	// Plastic Base
	color([0,0,0])
		translate([head_xoff-pin_base_x/2,
						head_yoff-pin_base_x/2,
						-1*pin_base_z+tol])
			cube([head_npin*pin_base_x,pin_base_x,pin_base_z+tol]);
	color([0,0,0])
		translate([head_xoff-pin_base_x/2,
						y-head_yoff-pin_base_x/2,
						-1*pin_base_z+tol])
			cube([head_npin*pin_base_x,pin_base_x,pin_base_z+tol]);
}

module holes() {
	translate([hole_off,hole_off,-1*hole_h/2])
		cylinder(r=hole_dia/2, h=hole_h);
	translate([x-hole_off,hole_off,-1*hole_h/2])
		cylinder(r=hole_dia/2, h=hole_h);
	translate([x-hole_off,y-hole_off,-1*hole_h/2])
		cylinder(r=hole_dia/2, h=hole_h);
	translate([hole_off,y-hole_off,-1*hole_h/2])
		cylinder(r=hole_dia/2, h=hole_h);
	
}

module board(holes = 0) {
	if (holes==0)
		union() {
			// board itself
			color([0.1,0.1,0.5]) cube([x,y,th]);
			icsp();
			usb();
			holes();
		}
	else 
		difference() {
			// board itself
			union() {
				color([0.1,0.1,0.5]) cube([x,y,th]);
				icsp();
				usb();
			}
			holes();
		}
}