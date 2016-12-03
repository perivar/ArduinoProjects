include <perfboard_send.scad>
include <Batteries.scad>
include <Generic_case_improved_revA.scad>

$fn = 20;
wall = box_wt;
height = 6;
shiftx = 5;
shifty = 5;
mountingHoleRadius = 2 / 2;

// 9 v battery
//color("red") translate([shiftx+80,shifty+50,2+wall]) rotate([90,-90,0]) 9V();

// the total height of the perfboard is 39 mm
translate([shiftx, shifty, wall+height]) perfboard_send();

// -------------------

// 9v battery wall
margin = 0;
color("white") translate([66,margin,0]) cube([wall,box_sy-2*margin,28]);

// standoffs
translate([shiftx+pb_hole_dia/2+pb_hole_edge, shifty+pb_hole_dia/2+pb_hole_edge, wall]) standoff();

translate([shiftx+pb_width-pb_hole_dia/2-pb_hole_edge,shifty+pb_hole_dia/2+pb_hole_edge,wall]) standoff();

translate([shiftx+pb_hole_dia/2+pb_hole_edge,shifty+pb_depth-pb_hole_dia/2-pb_hole_edge,wall]) standoff();

translate([shiftx+pb_width-pb_hole_dia/2-pb_hole_edge,shifty+pb_depth-pb_hole_dia/2-pb_hole_edge,wall]) standoff();

// box
difference() {
color("white") rounded_cube_case(generate_box=true, generate_lid=true);
    
    union() {
        // micro usb connection
        translate([-delta,23,20]) cube([wall+2*delta,12,8]);
        
        // BMP 180 vent holes
        ventholes = 4;
        ventsep = 2.5;
        for (ventNo = [0:ventholes-1]) {        translate([28+ventsep*ventNo,-delta,15]) cube([1,wall+2*delta,10]);    
        }
        
        // DHT11 vent holes
        for (ventNo = [0:ventholes-1]) {        translate([52+ventsep*ventNo,60-wall-delta,32]) cube([1,wall+2*delta,10]);    
        }

        // RF hole
        /*
        for (ventNo = [0:ventholes-1]) {        translate([9+ventsep*ventNo,60-wall-delta,20]) cube([1,wall+2*delta,10]);    
        }
        */
        
    }
}

module standoff(topRadius = mountingHoleRadius + 1, bottomRadius =  mountingHoleRadius + 2, holeRadius = mountingHoleRadius, height = height, wall = wall) {

union() {
      difference() {
        cylinder(r1 = bottomRadius, r2 = topRadius, h = height, $fn=32);
          cylinder(r =  holeRadius, h = height * 4, center = true, $fn=32);
      }
  }
    
}