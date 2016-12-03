// Generic case and lid - Improved
// http://www.thingiverse.com/thing:643264
// Printbus, November 2016

// Originally remixed from dandmpye's Generic case (box and lid) http://www.thingiverse.com/thing:28608
//   Revised dimensioning for improved scalability
//   Reformatted and labels revised for readability
//   Added provision for mounting tabs
// Rev A incorporates several improvements in the design and with openSCAD utilization
//   Reduced interdependency between parameters through individual parameters that can be tailored
//     Box wall thickness, base thickness, mounting tab thickness, lid thickness, lid lip height
//   Added table of reference data for hardware dimensions
//   Improved mesh overlap to reduce "ghosting" in rendering view 
//   Added informative echo outputs to openSCAD console
//   Revised path for custom function library
//   Added sample code for sidewall teardrop and round holes
//   Added sample code for board mounting standoffs
//
// To keep the design manageable...
//   The diameter of the lid corner posts is factored from the screw hole in the post
//   The radius of the box corners is set to match the lid corner posts
//   The inside edge of the straight portions of lid lip is aligned with center of corner screw holes
//     This means the lip width will reduce as the box side wall thickness increases
//
// Hint: To minimize infill artifacts on box sidewalls, try to adjust box_wt and slicer number of 
//   solid perimeters so that no sidewall infill is required for your extrusion width

////////// REVISION HISTORY ///////////////////////////////////////////////////
// YYMMDD date code
// 150119 - initial publish
// 161104 - revA
//

////////// INCLUDE AND USE  ///////////////////////////////////////////////////
// NOTE: openSCAD version 2014.03 or newer required for MCAD library

// EXTERNAL FUNCTIONS USED
use <Utils\roundCornersCube.scad>
//  Get roundCornersCube.scad from http://www.thingiverse.com/thing:8812
//  Revise path location to the custom openSCAD function if not in standard custom library location
//  roundCornersCube (x,y,z,r) gives cube of size xyz with corner radius r
//  Note that cube center parameter is fixed at true, and the corner $fn is fixed at 25
//  MCAD roundedBox is not used - those results seem imperfect and doesn't set corner $fn 
use <Utils\polyhole.scad>
//  Requires openSCAD MCAD library to be installed (openSCAD 2014.03 or later)
//  polyhole(h,d) provides improved size control on small holes
//  cylinder center parameter defaults to false; $fn intentionally varies with size of hole
use <Utils\teardrops.scad>    
//  Requires openSCAD MCAD library to be installed (openSCAD 2014.03 or later)
//  teardrop(radius, length, angle) provides a sidewall hole more printable than round hole
//  Angle parameter of 90 degrees gives teardrop shape; unclear when another value would be used
//  Consists of a round lobe and a right angle at the teardrop point
//  radius refers to the radius of the round lobe
//  $fn on round lobe is forced to 30
//  length is really the thickness of the teardrop formed in the x-axis
//  overall size of the teardrop is radius * (1 + 1/sin(45)), or radius*2.414
//  For angle=90, round lobe will center at x,y,z=0. Teardrop builds on x-axis for length parameter

//////////////// PARAMETERS  ///////////////////////////////////////////////////
// All dimensions are millimeter
// Case parameters for tailoring  
box_sx = 90;       // box outside size in X axis, not including mounting tabs
box_sy = 60;       // box outside size in Y axis
box_sz = 52;       // box outside size in Z axis, including the lid thickness
box_wt = 2.0;      // box wall thickness (keep less than box_cp_hid)
box_bt = 2.0;      // box base or bottom thickness (should be a multiple of printed layer height)

// Lid parameters for tailoring
lid_sz = 2.0;      // lid size in Z axis or lid thickness (should be a multiple of printed layer height)
lip_h = 1.60;      // lid lip height (should be a multiple of layer height)
fit_tol = 0.40;    // fit tolerance or clearance between box and lid

// Mounting tab parameters for tailoring
tab_use = true;     // true or false for mounting tab on x-axis yes/no
tab_sz = box_bt;    // tab size in z-axis or height (typically set same as box base thickness)
tab_sx = 8;         // mounting tab size in x-axis (the amount tab extends from box) 
tab_hoy = 7;        // tab hole offset in y axis from edge of tab

// Fastener and hardware component hole sizing
/*==================================================== 
Standard hardware dimension reference data
These are a reference point only; adjustment may be necessary due to nozzle size, etc.
Also note that MCAD polyhole does better at actual diameters than circle/cylinder

SIZE         THREAD  CLEAR   NUT AFD  NUT OD   NUT     HEAD     HEAD    WASHER  FLAT    
             HOLE    HOLE    WRENCH   @fn=6    HEIGHT  OD       HEIGHT  HEIGHT  OD      
-----------  ------  ------  -------  -------  ------  ------   ------  ------  ----- 
M2 x 0.4     1.75mm  2.20mm  4.0mm    4.62mm   1.6mm   4.0mm    2.0mm   0.3mm   5.5mm
M2.5 x 0.45  2.20mm  2.75mm  5.0mm    5.77mm   2.0mm   5.0mm    2.5mm   0.3mm   6.0mm
M3 x 0.5     2.70mm  3.30mm  5.5mm    6.35mm   2.4mm   6.0mm    3.0mm   0.5mm   7.0mm 
M4 x 0.7     3.50mm  4.40mm  7.0mm    8.08mm   3.2mm   8.0mm    4.0mm   0.8mm   9.0mm
M5 x 0.8     4.50mm  5.50mm  8.0mm    9.24mm   4.7mm   10.0mm   5.0mm   1.0mm   10.0mm
M6 x 1.0     5.50mm  6.60mm  10.0mm   11.55mm  5.2mm   12.0mm   6.0mm   1.6mm   12.0mm
M8 x 1.25    7.20mm  8.80mm  13.0mm   15.01mm  6.8mm   16.0mm   8.0mm   2.0mm   17.0mm
#2-56        1.85mm  2.44mm  4.76mm   5.50mm   1.59mm  4.60mm   2.18mm  0.91mm  6.35mm
#3-56        2.26mm  2.79mm  4.76mm   5.50mm   1.59mm  5.28mm   2.51mm  0.91mm  7.94mm
#4-40        2.44mm  3.26mm  6.35mm   7.33mm   2.38mm  5.97mm   2.85mm  1.14mm  9.53mm
#6-32        2.95mm  3.80mm  7.94mm   9.17mm   2.78mm  7.37mm   3.51mm  1.14mm  11.11mm
#8-32        3.66mm  4.50mm  8.73mm   10.08mm  3.18mm  8.74mm   4.17mm  1.14mm  12.7mm
#10-24       4.09mm  5.11mm  9.53mm   11.00mm  3.18mm  10.13mm  4.83mm  1.14mm  14.29mm
#10-32       4.31mm  5.11mm  9.53mm   11.00mm  3.18mm  10.13mm  4.83mm  1.14mm  14.29mm
1/4-20       5.56MM  6.76MM  11.11mm  12.83mm  4.76mm  13.03mm  6.35mm  1.80mm  18.65
Notes:       1,2     2,3     4        5        6       7,8      8,9     8,10    8,11
----------------------------------------------------------------------------------------
Note  1: Thread hole is for tap or self thread of machine screw in soft material
Note  2: Hole dimensions are from littlemachineshop.com Tap Drill - 50% Thread column data
Note  3: Clearance hole data is littlemachineshop.com Clearance Drill - Standard Fit column data
Note  4: Nut Across Flat Diameter (AFD) metric data is ISO, inch is boltdepot.com US Nut Size table
Note  5: Nut round OD is the openSCAD circle diameter required to achieve a nut size at $fn=6 
         Nut OD is calculated as = (NUT AFD)/cos(30)
Note  6: Nut height is for standard hex nut; jam nuts are less, lock nuts are more
         Metric data is ISO 4032, SAE data from boltdepot.com US Nut Size tables
Note  7: Head diameter varies with the head style; value shown is max across all except truss head
Note  8: Data from http://www.numberfactory.com/nf_metric.html or http://www.numberfactory.com/nf_inch.html 
Note  9: Head height varies with head style; value shown is max across all styles
Note 10: Standard washer height or thickness
Note 11: Flat washer outer diameter
****************************************************************************************/
// Tailor fastener sizing and fit adjustments here
// All screw holes are implemented with MCAD polyhole - more accurate than hole by cylinder
// Dimensions shown were determined with Simplify3D as slicer, inside perimeters printed first
// Tolerance added to nominal corrects for extrusion width and other printer variations

// Box and lid screw hole parameters for tailoring
box_cp_hid = 2.44 + 0.1; // corner post hole inside diameter for screw threading (2.44 nominal for #4)
box_cp_hd = 10.0;        // corner post hole depth must be less than (box_sz - lid_sz)
lid_hid = 3.26 + 0.1;    // lid screw clearance hole inside diameter (3.26 nominal for #4) 
lid_rid = 6.0 + 0.1;     // lid screw head recess inside diameter (6.0 nominal for #4)
lid_rd = 0.0;            // depth of lid head recess (lid_sz must be able to accomodate the recess)
tab_hid = 3.26 +0.1;     // inside diameter of the mounting tab clearance holes (3.26 nominal for #4)

////////// NON-USER PARAMETERS AND CALCULATIONS /////////////////////////////////
// Parameters beyond this point are normally not altered in basic tailoring
// Modify at your own risk

// Geometry mesh factors 
MF = 0.01;       // Mesh Factor is the amount of overlap on geometries for proper mesh
MSA = MF;        // Mesh Single Adjustment factor (translate ends; size adjustment on single ended mesh)
MDA = 2*MF;      // Mesh Double Adjustment (size adjustment on double ended mesh like boring holes)

// calculated parameters 
box_cp_od = box_cp_hid * 3 ;     // set outer diameter of the corner standoff post to 3*hole diameter
box_cp_or = box_cp_od / 2 ;      // outer radius of the corner standoff post
lip_w = box_cp_or - box_wt - fit_tol; // lid lip width set so inside of lip aligns lid hole centers
lip_arc_or = box_cp_od - box_wt; // outside radius of the corner arc on the lid lip
lip_arc_od = 2 * lip_arc_or;     // outside diameter of the corner arc on the lid lip
box_r = (3 * box_cp_hid) / 2;    // radius of the box corners automatically based on screw size

// Define matrix of lid hole locations
// Matrix starts with hole closest to x,y=0 and goes CCW around box
lid_hole_centers = [[           box_cp_or ,          box_cp_or , 0 ], 
					[  box_sx - box_cp_or ,          box_cp_or , 0 ],
					[  box_sx - box_cp_or , box_sy - box_cp_or , 0 ], 
					[           box_cp_or , box_sy - box_cp_or , 0 ]];

// Define matrix of mounting tab hole locations
// Matrix starts with hold closest to x,y=0 and goes CCW around box
tab_hole_centers = [[          -tab_sx/2 ,          tab_hoy , 0 ],
                    [  box_sx + tab_sx/2 ,          tab_hoy , 0 ],
                    [  box_sx + tab_sx/2 , box_sy - tab_hoy , 0 ],
                    [          -tab_sx/2 , box_sy - tab_hoy , 0 ]];

//////////////////////////////////////////////////////////////////////////////////////
// Top level geometry
// Edit true or false for obtaining box and lid respectively
//rounded_cube_case(generate_box=true, generate_lid=true);

//----------------------------------------------------------
module standoff( post_od , post_id , post_h , hole_depth) {
  // Generates a standoff for mounting lid or circuit board
  // post_od: outer diamter of the standoff post
  // post_id: diameter of the inner hole in the standoff post
  // post_h: height of the standoff post
  // hole_depth: depth of the inner hole in the standoff post
  difference() {
    // start with a solid post
    // set $fn=25 to match what roundCornersCube does
    cylinder( d = post_od , h = post_h , center = false, $fn = 25);  
      
    // remove the hole for the screw
    translate([ 0, 0, post_h - hole_depth ])
      polyhole( hole_depth + MSA, post_id ); 
  }  // end difference
}  // end module standoff

//----------------------------------------------------------
module cylindrical_lip( l_od , l_h , l_w ) {	
  // Generate a quarter circle arc for use as a lip
  // l_od: outer diameter of the lip arc
  // l_h: height of the lip arc
  // l_w: width of the lip arc
  l_r = l_od / 2;   // calculate radius of the lip arc
  difference() {
    // start with a solid cylinder
    cylinder( r = l_r, h = l_h, center=false, $fs=0.01);
      
    // hollow it out to form a ring
    translate([ 0, 0, -MSA ])                    // -MSA to offset oversized cylinder being removed
      cylinder( r = l_r - l_w, h = l_h + MDA, center=false, $fs=0.01 ); // +MDA on h to ensure removal
      
    // remove all but a quarter of the ring
    translate([ -l_r, 0, -MSA ])                 // -MSA to offset oversized cube being removed
      cube([ l_od + MSA , l_r, l_h + MDA ]);     // oversize by +MSA or +MDA to ensure complete removal 
    translate([ 0, -l_r, -MSA ])                 // -MSA to offset oversized cube being removed
      cube([ l_od + MSA, l_r + MSA, l_h + MDA ]);// oversize by +MSA or +MDA to ensure complete removal
      
  }  // end difference
}  // end module cylindrical_lip

//----------------------------------------------------------
module rounded_cube_case (generate_box, generate_lid) {
  // generate_box: true or false flag
  // generate_lid: true or false flag

  // Design rendering of box starts at x=0, y=0, z=0 
  // When present, mounting tabs are always added as extensions on X axis
  // left-right-forward-rear references are with respect to axis in default view (+x to right, +y to rear)
  // If both box and lid are being generated, lid will be offset in Y to place it rearward of box

  if (generate_box == true) {    // we need to create the box part
    echo(str("Box outer size is x:",box_sx,"mm, y:",box_sy,"mm, z:",box_sz,"mm (with lid)"));
    echo(str("Available clearance between corner posts is x:",box_sx - 2*box_cp_od,"mm, y:",box_sy - 2*box_cp_od));
    echo(str("Available height inside closed box is ",box_sz - box_bt - lid_sz,"mm"));
      
    union() {
      difference() {
        union() {
          // Start with a solid cube with rounded corners
          // Z-axis height of box is reduced by lid thickness
          translate([ box_sx/2, box_sy/2, (box_sz - lid_sz)/2 ])
            roundCornersCube( box_sx, box_sy, box_sz - lid_sz, box_r );
          // Extend base for the mounting tabs if present
          if ( tab_use == true ) {
            echo(str("Mounting tabs of ",tab_sx,"mm increase x-axis size to ",box_sx + 2*tab_sx,"mm"));
            echo(str("Tab mounting hole spacing is x:",box_sx+tab_sx,"mm, y:",box_sy-2*tab_hoy,"mm"));
            difference () {
              // start with the plate for the mounting tabs
              translate ([ box_sx/2, box_sy/2, tab_sz/2 ])
                roundCornersCube ( box_sx + (tab_sx*2), box_sy, tab_sz - MSA, box_r );

              // now remove the mounting holes in the mounting tabs
              for(j = tab_hole_centers) {        // for each hole in the mounting tab
                translate([ 0, 0, -MSA ])        // shift Z to ensure complete removal of hole
                  translate(j)
                    polyhole ( tab_sz + MDA, tab_hid ); // oversize height to ensure complete removal
              }  // end for loop on mounting tab holes
            }  // end difference
          }  // end if tab_use
        }  // end union
        
        // Hollow out the box volume, leaving box_bt at bottom and box_wt at sides
        translate([ box_sx/2, box_sy/2, (box_sz - lid_sz)/2 + box_bt ]) 
          roundCornersCube( box_sx - (box_wt*2), box_sy - (box_wt*2), box_sz, box_r - box_wt);  

        // Define any holes in the box walls here
        // Sample teardrop holes with bottom of round lobe at floor of box - uncomment and tailor as desired
/*
        teardrop_r = 3.5;  // radius for round end of teardrop
        translate([ box_sx/3, box_wt/2, teardrop_r + box_bt ])  // forward sidewall
          rotate([0, 0, 90])
	        teardrop( radius=teardrop_r, length=box_wt + MDA, angle=90 );
        translate([ box_sx-box_wt/2, box_sy/3, teardrop_r + box_bt ]) // right sidewall
          teardrop( radius=teardrop_r, length=box_wt + MDA, angle=90 );
        translate([ box_sx/3, box_sy-box_wt/2, teardrop_r + box_bt ]) // rear sidewall
          rotate([0, 0, 90])
	        teardrop( radius=teardrop_r, length=box_wt + MDA, angle=90 );
        translate([ box_wt/2, box_sy/3, teardrop_r + box_bt ])  // left sidewall
          teardrop( radius=teardrop_r, length=box_wt + MDA, angle=90 );
//*/       

        // Sample round holes centered on available wall height - uncomment and tailor as desired
/*
        hole_r = 2;
        translate([ box_sx*2/3, box_wt/2, (box_sz-lid_sz-box_bt)/2 + box_bt ])  // forward sidewall
          rotate([90, 0, 0])
            cylinder( h=box_wt + MDA, r=hole_r, center=true, $fn=30 );
        translate([ box_sx - box_wt/2, box_sy*2/3, (box_sz-lid_sz-box_bt)/2 + box_bt ])  // right sidewall
          rotate([0, 90, 0])
            cylinder( h=box_wt + MDA, r=hole_r, center=true, $fn=30 );
        translate([ box_sx*2/3, box_sy - box_wt/2, (box_sz-lid_sz-box_bt)/2 + box_bt ])  // forward sidewall
          rotate([90, 0, 0])
            cylinder( h=box_wt + MDA, r=hole_r, center=true, $fn=30 );
        translate([ box_wt/2, box_sy*2/3, (box_sz-lid_sz-box_bt)/2 + box_bt ])  // left sidewall
          rotate([0, 90, 0])
            cylinder( h=box_wt + MDA, r=hole_r, center=true, $fn=30 );
//*/

      }  // end difference
			
      // Add the corner standoff posts for the lid screws 
      for(i = lid_hole_centers) {
        translate([ 0, 0, box_bt - MSA ])  // raise up to the inside of the box
          translate(i)                     // locate a corner
            standoff( box_cp_od, box_cp_hid, box_sz - box_bt - lid_sz + MSA, box_cp_hd );
      }  // end for loop on standoff posts

      // Add any mounting standoff posts on the box bottom here
      // Sample mounting posts for small board centered in box - uncomment and tailor as desired
/*
      bd_hsp_x = 34.75;  // board hole spacing in x axis
      bd_hsp_y = 28;    // board hole spacing in y axis
      bd_post_od = 6;   // diameter of the board mounting post
      bd_post_id = 2.7; // hole diameter in the mounting post (2.7 for threading M3)
      bd_post_h = 4;    // height of the board mounting posts
      echo(str("Available height above board posts is ",box_sz - box_bt - lid_sz - bd_post_h,"mm"));
      translate([ box_sx/2 - bd_hsp_x/2, box_sy/2 - bd_hsp_y/2, box_wt - MSA ])  // forward left corner
        standoff( post_od = bd_post_od, post_id=bd_post_id , post_h=bd_post_h , hole_depth=4); // for M3
      translate([ box_sx/2 + bd_hsp_x/2, box_sy/2 - bd_hsp_y/2, box_wt - MSA ])  // forward right
        standoff( post_od = bd_post_od, post_id=bd_post_id , post_h=bd_post_h , hole_depth=4); // for M3
      translate([ box_sx/2 + bd_hsp_x/2, box_sy/2 + bd_hsp_y/2, box_wt - MSA ])  // right rear
        standoff( post_od = bd_post_od, post_id=bd_post_id , post_h=bd_post_h , hole_depth=4); // for M3
      translate([ box_sx/2 - bd_hsp_x/2, box_sy/2 + bd_hsp_y/2, box_wt - MSA ])  // left rear
        standoff( post_od = bd_post_od, post_id=bd_post_id , post_h=bd_post_h , hole_depth=4); // for M3
//*/      
    }  // End union 

  }  // end if generate_box

  y_offset = generate_box ? box_sy+10 : 0; // offset lid Y by box_sy+10 if we are also doing box
  if ( generate_lid == true ) {        // we need to create the lid part
    translate([ 0, y_offset, 0]) { 
      difference() {
        // create the base solids for the lid
        union() {
          // Start with a solid plate with rounded corners to match the box part
          translate([ box_sx/2, box_sy/2, lid_sz/2 ])
            roundCornersCube( box_sx, box_sy, lid_sz, box_r );
 
          // Add a reinforcement lip to the lid, starting with the straight portions 
          // increase lip width by MSA to ensure mesh with quarter circle lip added below
          translate([ box_cp_od + fit_tol, box_wt + fit_tol, lid_sz ]) 
            cube([box_sx - (box_cp_od*2) - (fit_tol*2), lip_w + MSA, lip_h ]); 
          translate([box_wt + fit_tol, box_cp_od + fit_tol, lid_sz]) 
            cube([ lip_w + MSA, box_sy - (box_cp_od*2) - (fit_tol*2), lip_h ]);
          translate([box_sx - box_cp_or - fit_tol, box_cp_od + fit_tol, lid_sz ]) 
            cube([lip_w + MSA, box_sy - (box_cp_od*2) - (fit_tol*2), lip_h ]);	
          translate([box_cp_od + fit_tol, box_sy - box_cp_or - fit_tol, lid_sz]) 
            cube([box_sx - (box_cp_od*2) - (fit_tol*2), lip_w + MSA, lip_h]);
					
          // Fit a quarter circle lip around the corner mounting posts
          translate([ 0, 0, lid_sz]) 
            translate( lid_hole_centers[0] ) 
              rotate(180)  
                cylindrical_lip( lip_arc_od, lip_h, lip_w );
          translate([ 0, 0, lid_sz ])
            translate( lid_hole_centers [1] )
              rotate(270)  
                cylindrical_lip( lip_arc_od, lip_h, lip_w );
          translate([ 0, 0, lid_sz ])
            translate( lid_hole_centers [2] ) 
              cylindrical_lip( lip_arc_od, lip_h, lip_w );
          translate([ 0, 0, lid_sz ])
            translate( lid_hole_centers [3] )
              rotate(90)  
                cylindrical_lip( lip_arc_od, lip_h, lip_w );
        }  // end union of the base solids for the lid

        for (i = lid_hole_centers) {               // for each corner in the lid
          // remove the material for the corner screw hole 
          translate([ 0, 0, -MSA ])                // shift Z to ensure complete removal of hole
            translate(i) 
              polyhole( lid_sz + MDA, lid_hid );   // height is +MDA to ensure complete removal
          if ( lid_rd > 0 ) {                      // we need to countersink the screw head
            // remove the material for the screw head recess 
            translate([ 0, 0, -MSA ])              // -MSA to offset oversize hole being removed
              translate(i) 
                polyhole( lid_rd + MSA, lid_rid ); // oversize +MSA to ensure complete removal 
          }  // end if lid_rd
        }  // end for loop on lid holes

        // Add removal of any holes in the lid here
        // Sample square hole centered in lid - uncomment and tailor as desired
/*
        translate([ box_sx/2, box_sy/2, lid_sz/2 ])
          cube([ 15, 10, lid_sz + MDA], center=true );
//*/

      }  // end difference for lid
    }  // end translate to move away from box if it is also being made
  }  // end if generate_lid
  
  echo(str("Maximum lid screw length is ", box_cp_hd + lid_sz - lid_rd,"mm"));

}  // end module rounded_cube_case


