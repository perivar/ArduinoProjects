use </Utils/teardrops.scad>
use </Utils/roundCornersCube.scad>
use </Utils/polyhole.scad>

module standoff(outer_diam, inner_diam, height, hole_depth) {
	/* Generates a standoff for mounting something e.g. a PCB */
	difference() {
		cylinder(r=outer_diam/2, h=height, $fn=50);
		translate([0,0, height - hole_depth]) polyhole(hole_depth + 1, inner_diam); 
	}
}

module cylindrical_lip(outer_diameter, height, wall_thickness) {	
	/* Generates a hollow cylindrical lip, quartered. */
	difference() {
		cylinder(r=outer_diameter/2, h = height);
		//Core it out
		translate([0,0,-0.5])  cylinder(r=(outer_diameter/2) - wall_thickness, h = height+1);	
		//Cut it into a quarter.
		translate([-outer_diameter/2,0,-0.5]) cube([outer_diameter + 1, outer_diameter/2,height + 1]);
		translate([0, -outer_diameter/2, -0.5]) cube([outer_diameter + 1, outer_diameter/2,height + 1]);
	}
}

module rounded_cube_case (generate_box = true, generate_lid = false) 
{ 
	sx = 95; 			//X dimension
	sy = 39;			//Y dimension
	sz = 30;				//Z dimension
	r = 2.5;				//The radius of the curves of the box walls.
	wall_thickness = 1.5;//Thickness of the walls of the box (and lid)

	//Screw hole details
	screw_hole_dia = 2;  	//Diameter of the screws you want to use
	screw_hole_depth = 20;	//Depth of the screw hole

	screw_head_dia = 4.5;	//Diameter of the screw head (for the recess)
	screw_head_depth = 0;	//Depth of the recess to hold the screw head

	screw_hole_centres = [ [wall_thickness*2, wall_thickness*2,0 ], 
					[sx - ( wall_thickness*2), wall_thickness*2, 0],
					[sx - ( wall_thickness*2), sy - ( wall_thickness*2), 0], 
					[wall_thickness*2, sy - (wall_thickness*2), 0] ];

	corner_lip_dia = screw_hole_dia * 3.5;
	corner_standoff_dia = screw_hole_dia * 3;

	if (generate_lid == true) 
	{
			translate([0, sy+10, 0])
			difference() 
			{
				union() {
					translate([sx/2, sy/2, wall_thickness/2]) roundCornersCube(sx,sy,wall_thickness,r); //Create the cube
					//Create the reinforcing lip.
					translate([corner_lip_dia,wall_thickness,wall_thickness]) cube([sx-corner_lip_dia * 2,wall_thickness,wall_thickness]);
					translate([wall_thickness,corner_lip_dia,wall_thickness]) cube([wall_thickness,sy-corner_lip_dia * 2,wall_thickness]);
					translate([sx - wall_thickness*2,corner_lip_dia, wall_thickness]) cube([wall_thickness,sy-corner_lip_dia * 2,wall_thickness]);	
					translate([corner_lip_dia,sy - wall_thickness*2,wall_thickness]) cube([sx-corner_lip_dia * 2,wall_thickness,wall_thickness]);
					

					//Fit the reinforcing lip around the corner standoffs
						translate([0,0,wall_thickness]) translate(screw_hole_centres[0]) rotate(180)  
							cylindrical_lip(corner_lip_dia + (wall_thickness*2), 
								wall_thickness,wall_thickness);
						translate([0,0,wall_thickness]) translate(screw_hole_centres[1]) rotate(270)  
								cylindrical_lip(corner_lip_dia + (wall_thickness*2),
								wall_thickness,wall_thickness);
						translate([0,0,wall_thickness]) translate(screw_hole_centres[2]) 
								cylindrical_lip(corner_lip_dia + (wall_thickness*2),	
								wall_thickness, wall_thickness);
						translate([0,0,wall_thickness]) translate(screw_hole_centres[3]) rotate(90)  
								cylindrical_lip(corner_lip_dia + (wall_thickness*2),
								wall_thickness, wall_thickness);
				}
				for (i = screw_hole_centres) 
				{
					/*	Drill two holes in the lid - the screw-hole, and the countersink 
						The screw-hole is made 25% larger here, as the idea is for the screw
						to pass through the lid without biting into it */
		
	 				translate([0,0,-0.5]) translate(i) polyhole(wall_thickness + 1, screw_hole_dia * 1.25);  //The screw hole.
					//translate([0, 0, -1]) translate(i) polyhole(screw_head_depth + 1, screw_head_dia); //The countersink
				}
			}
	}

	if (generate_box == true)  
	{
		//The 'box' part of the case.
		union() 
		{
			difference() 
			{
				translate([sx/2, sy/2,sz/2 ]) roundCornersCube(sx,sy,sz, r);
				//cut off the 'lid' of the box
				translate([-0.1,-0.1, sz - wall_thickness]) cube([sx+1,sy+1,wall_thickness + 1]);
				//hollow it out
				translate([sx/2, sy/2, sz/2 + wall_thickness]) roundCornersCube(sx - (wall_thickness*2) , sy - (wall_thickness*2) , sz, r);
			}
			
			//Put in the pillars for the screws to go into.
			for (i = screw_hole_centres)  
			{
				translate([0,0,wall_thickness]) translate(i) 
					standoff(corner_standoff_dia, screw_hole_dia, sz - (wall_thickness * 2), 
						screw_hole_depth);
			}
		}
	}

}

//End of Generic Case code

standoff_height = 8;
pcb_thickness = 2;

//Connector hole sizes
power_conn_radius = 5;
rf_conn_radius = 5;
audio_conn_radius = 6;

//Positioning offsets measured from the upper surface of lower left corner of the PCB, when board orientated with power conn in bottom left.
//PCB mounting holes
hole_1_x_offset = 4;
hole_1_y_offset = 5;

hole_2_x_offset = 75;
hole_2_y_offset = 5;

hole_3_x_offset = 75;
hole_3_y_offset = 28;

power_conn_x_offset = 11.5;
power_conn_z_offset = 8;

rf_conn_x_offset = 43;
rf_conn_z_offset = 7.5;

audio_conn_x_offset = 7.5;
audio_conn_z_offset = 4;

pcb_corner_x = 8;
pcb_corner_y = 3.5;

difference() {
	union()  { 
		rounded_cube_case(true, false);
		//The three standoffs to support the PCB
		translate([pcb_corner_x + hole_1_x_offset, pcb_corner_y + hole_1_y_offset, 1.49]) standoff(6, 1.75, standoff_height, 8); 
		translate([pcb_corner_x + hole_2_x_offset, pcb_corner_y + hole_2_y_offset, 1.49]) standoff(6, 1.75, standoff_height, 8);
		translate([pcb_corner_x + hole_3_x_offset, pcb_corner_y + hole_3_y_offset, 1.49]) standoff(6, 1.75, standoff_height, 8);
	}
	//Cut the holes for the sockets on the board.
	#translate([pcb_corner_x + power_conn_x_offset, 0, standoff_height + pcb_thickness + power_conn_z_offset]) 
		rotate([90,0,0]) teardrop(10, power_conn_radius, true, false); //power conn
	#translate([pcb_corner_x + rf_conn_x_offset,0,standoff_height + pcb_thickness + rf_conn_z_offset]) 
		rotate([90,0,0]) teardrop(10, rf_conn_radius, true, false); //rf in
	#translate([pcb_corner_x + audio_conn_x_offset, 39, standoff_height + pcb_thickness + audio_conn_z_offset]) 
		rotate([90,0,0]) teardrop(10, audio_conn_radius, true, false); //audio out
} 