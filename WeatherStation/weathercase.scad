use <Utils\roundCornersCube.scad>
include <arduino.scad>

//enclosure(boardType = 4);

epsilon = 0.1;
mountingHeight = 8;
mountingHoleRadius = 1.5;

height = 57;
length = 70;
thickness = 2;
rad = 3;
offsetx = 2;

tab_hole_radius = 3;
tab_margin = 7;

//translate([-offsetx,0,0])
//cube([height, length, thickness]);

translate([height/2-offsetx,length/2,thickness/2])
difference() {
    roundCornersCube( height, length, thickness, rad);
    
    // holes
    translate([-height/2+tab_margin,length/2-2*tab_margin,0]) cylinder(r=tab_hole_radius, h=thickness+2*epsilon,center=true);
    
    translate([height/2-tab_margin,length/2-2*tab_margin,0]) cylinder(r=tab_hole_radius, h=thickness+2*epsilon,center=true);
    
    translate([height/2-tab_margin,-length/2+tab_margin,0]) cylinder(r=tab_hole_radius, h=thickness+2*epsilon,center=true);
    
    translate([-height/2+tab_margin,-length/2+tab_margin,0]) cylinder(r=tab_hole_radius, h=thickness+2*epsilon,center=true);    
}

standoffs( 
  boardType = UNO, 
  height = mountingHeight, 
  topRadius = mountingHoleRadius + 1, 
  bottomRadius =  mountingHoleRadius + 2, 
  holeRadius = mountingHoleRadius,
  mountType = TAPHOLE
);

//translate([0,0,standoff_height]) arduino(boardType = 4);
