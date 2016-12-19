include <perfboard_send.scad>
include <StandoffGenerator.scad>
use <Utils\roundCornersCube.scad>

/* [Body] */
//Choose shape of the main body
Shape = 2; // [1:Round, 2:Square, 3:Hex]
//Select height of the main body,  mm
BaseHeight = 7; // [0:50]
//Select diameter of the main body, mm
BaseDia = 4; // [0:30]

/* [Top] */
//Choose style of the top section
Style = 2; // [1:Male, 2:Snap-In, 3:Flat, 4:Female, 5:Hollow]
//Select height of the top, mm
TopHeight = 4; // [2:20]
//Select diameter of the top, mm
TopDia = 2; // [1:25]

// bottom plate thickness
thickness = 2;

module perfboard_mountingboard() {
    
    // bottom plate
    translate([pb_width/2,pb_depth/2,thickness/2])
    roundCornersCube( pb_width, pb_depth, thickness, 2);

    // standoffs
    for (dx=[TopDia, pb_width-TopDia]) 
        for (dy=[TopDia, pb_depth-TopDia]) {
                translate([dx,dy,0])
                    standoff(Shape,BaseHeight,BaseDia,Style,TopHeight,TopDia);            
        }
            
    // perf board
    translate([0,0,BaseHeight])
    perfboard_send();
}

//perfboard_mountingboard();