include <perfboard_send.scad>
include <Batteries.scad>
include <Generic_case_improved_revA.scad>
include <Utils\roundedcube.scad>
include <perfboard_mountingboard.scad>

$fn = 20;

wall = box_wt;
tol = 0.25; // small addition
height = 7;
shiftx = 5;
shifty = 11;
mountingHoleRadius = 2 / 2;

parts = "demo"; // all | box | lid | demo

// -------------------
module perfboard_support() {

    // perfboard standoffs
    topRadius = mountingHoleRadius + 1;
    bottomRadius =  mountingHoleRadius + 2;
    holeRadius = mountingHoleRadius;
    
    // position of the holes in the pcb
    pcbmntdx = pb_hole_dia/2+pb_hole_edge;
    pcbmntdy = pb_hole_dia/2+pb_hole_edge;
    
    // position within box
    // NB note that the thickness of the box floor is 1 mm less than the outer thickness
    translate([pb_width/2+shiftx,pb_depth/2+shifty,-1])

    difference() {
    
        union() {
    // standoffs
	for (dx=[pcbmntdx, -pcbmntdx]) 
        for (dy=[pcbmntdy, -pcbmntdy]) {
				translate([sign(dx)*pb_width/2-sign(dx)*pcbmntdx, sign(dy)*pb_depth/2-sign(dy)*pcbmntdy, wall-tol]) 
            cylinder(r1 = bottomRadius, r2 = topRadius, h = height+tol, $fn=20);
            
            // strengthening bars
            translate([sign(dx)*pb_width/2-sign(dx)*pcbmntdx, sign(dy)*(pb_depth/2+shifty-7.5), wall-tol])
            c_cube(wall, 15-tol, height+tol);             

    translate([sign(dx)*pb_width/2+sign(dx)*pcbmntdx, sign(dy)*(pb_depth/2)-sign(dy)*pcbmntdy, wall-tol])
            c_cube(5.5, wall, height+tol);             
        }
    }
    
    // screw holes in the standoffs
    // standoffs
	for (dx=[pcbmntdx, -pcbmntdx]) 
        for (dy=[pcbmntdy, -pcbmntdy]) {
				translate([sign(dx)*pb_width/2-sign(dx)*pcbmntdx, sign(dy)*pb_depth/2-sign(dy)*pcbmntdy, wall-tol]) 
            cylinder(r=(pb_hole_dia-tol)/2, h=height+2*tol, $fn=20);
                        
        }       
    }
}

module perfboard_standoff(topRadius = mountingHoleRadius + 1, bottomRadius =  mountingHoleRadius + 2, holeRadius = mountingHoleRadius, height = height+tol) {

	union() {
		difference() {
			cylinder(r1 = bottomRadius, r2 = topRadius, h = height, $fn=20);
			cylinder(r =  holeRadius, h = height * 4, center = true, $fn=20);
		}
	}	
}

module water_protector() {

    h = 20;
    w = 16;
    d = 2;
    
    top = 34;
    
    // http://daid.eu/~daid/3d/
    // https://github.com/OskarLinde/scad-utils
    difference() {
        linear_extrude(height=20, center=false) 
        polygon([[0,0],[8,w],[h,w],[h,h],[top,0]]);

        
        translate([-delta,2+delta,2])
        linear_extrude(height=16, center=false) 
        polygon([[0,0],[8,w],[h-d,w],[h-d,h],[top-8,0]]);
    }

}

module water_protector_old() {
        roof_h = 20;
        roof_w = 12;
        roof_d = 2;
    
        wall_h = 15;
        wall_w = 10;
        wall_d = roof_d;
    
        rounded_rad = 0.75;
    
        // roof
		translate([8,-roof_w+wall+0.75,0]) rotate([0,0,-20]) rcube([roof_d,roof_w,roof_h], radius=rounded_rad);
        
        // roof wall
        translate([0,-wall_w+wall,0]) rcube([wall_h,wall_w,wall_d], radius=rounded_rad);

        // roof wall
        translate([0,-wall_w+wall,roof_h-wall_d]) rcube([wall_h,wall_w,wall_d], radius=rounded_rad);
    
}


module c_cube(x, y, z) {
	translate([-x/2, -y/2, 0]) cube([x, y, z]);
}


// parts
if (parts == "demo") {
// 9 v battery
color("red") translate([shiftx+80,shifty+44,2+wall]) rotate([90,-90,0]) 9V();

// the total height of the perfboard is 39 mm
// NB note that the thickness of the box floor is 1 mm less than the outer thickness
translate([shiftx, shifty, wall+height-1]) perfboard_send();

}

if (parts == "all" || parts == "demo" || parts == "box") {
    // 9v battery wall
    margin = 0;
    color("white") translate([66,margin,0]) cube([wall,box_sy-2*margin,28]);
}

// box
difference() {
	union() {
        if (parts == "all" || parts == "demo") {
            color("white") rounded_cube_case(true,true);
		} else if (parts == "box") {
            color("white") rounded_cube_case(true,false);
        } else if (parts == "lid") {
            color("white") rounded_cube_case(false,true);
        }
        
        if (parts == "all" || parts == "box" || parts == "demo") {
            color("red") 
            perfboard_support();
            //translate([shiftx, shifty, wall-1])perfboard_mountingboard();
            
            
            translate([16,2,30]) rotate([180,0,0]) water_protector();

            translate([40,61,27]) water_protector();
        }
	}
	
    if (parts == "all" || parts == "box" || parts == "demo") {
        union() {
            // micro usb connection
            translate([-delta,shifty+18,20]) cube([wall+2*delta,12,8]);
            
            // BMP 180 vent holes
            ventholes = 4;
            ventsep = 2.5;
            for (ventNo = [0:ventholes-1]) {        translate([28+ventsep*ventNo,-wall/2,15]) cube([1,2*wall,10]);    
            }
            
            // DHT11 vent holes
            for (ventNo = [0:ventholes-1]) {        translate([box_sz+ventsep*ventNo,box_sy-wall-wall/2,32]) cube([1,2*wall,10]);    
            }

            // RF hole
            /*
            for (ventNo = [0:ventholes-1]) {        translate([9+ventsep*ventNo,60-wall-delta,20]) cube([1,wall+2*delta,10]);    
            }
            */
        
           // the standoff walls are too long
            // cut where the battery are:
            //translate([66+wall,5,wall-tol]) cube([10, pb_width-10, 20]);
        }
    }
}

