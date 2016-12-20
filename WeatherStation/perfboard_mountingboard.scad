include <perfboard_send.scad>
include <Utils\SnapLib.0.20.scad>
use <Utils\roundCornersCube.scad>

//Select height of the main body,  mm
BaseHeight = 7; 

//Select height of the top, mm
TopHeight = 4;  
//Select margin for the holes in the pcb, mm
TopMargin = 2.1; 

// bottom plate thickness
thickness = 2;

module perfboard_mountingboard() {
    
    difference() {
        
    union() {
    // bottom plate
    translate([pb_width/2,pb_depth/2,thickness/2])
    roundCornersCube( pb_width, pb_depth, thickness, 2);

    // standoffs
    for (dx=[TopMargin, pb_width-TopMargin]) 
        for (dy=[TopMargin, pb_depth-TopMargin]) {
                translate([dx,dy,BaseHeight/2-0.25]) cube([4,4,BaseHeight+2*0.25], center=true);
            translate([dx,dy,BaseHeight-0.25]) cylinder(r = TopMargin/2-0.2, h = TopHeight+0.25, $fn = 20);
        }
    
     // bars to position it within weather send box
     translate([5,-8.5,0]) cube([4,58.3,thickness]);
     translate([55,-8.5,0]) cube([4,58.3,thickness]);

     translate([-4.5,0,0]) cube([64,4,thickness]);
     translate([-4.5,40,0]) cube([64,4,thickness]);
    }
    
        // remove a circle    
        scale([1.5,1,1]) translate([20,22,-5]) cylinder(r=17, h=thickness+10);
    }
    
    // perf board
    //translate([0,0,BaseHeight]) perfboard_send();
}

perfboard_mountingboard();

snap_w = 6; // width of snap
snap_h = 3;
snap_a = 35;
clearance = 0.2;
translate([pb_width/2+snap_w/2,-clearance,0])
rotate([0,-90,0]) SnapY(l=BaseHeight+pb_height+clearance,h=snap_h,a=snap_a,b=snap_w);
translate([pb_width/2,0,0]) cylinder(r=7, h=thickness);

translate([pb_width/2-snap_w/2,pb_depth+clearance,0])
rotate([180,-90,0]) SnapY(l=BaseHeight+pb_height+clearance,h=snap_h,a=snap_a,b=snap_w);