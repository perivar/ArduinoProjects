include <arduino_nano.scad>

delta = 0.1;

// perf board constants
pb_width = 60;
pb_depth = 40;
pb_height = 1.6;

pb_hole_dia = 2; 
pb_hole_edge = 1.10;

// pins
pinh = 5;           // height of pin in mm.
pind = 1;           // diameter of header pin in mm
pinsep = 0.1 * 25.4; // separation between header pins.
npin_x   = 20;         // number of pins. 
npin_y   = 14;         // number of pins. 

header_height = 8.5;    // height of female header connector

// calculate the pin offsets according to the perfboard size
xoff = (pb_width - npin_x*pin_base_x)/2 + pin_base_x/2;
yoff = (pb_depth - npin_y*pin_base_x)/2 + pin_base_x/2;

module perfboard_send() {
    perfboard();
    header(1,6,16,0);    
    header(1,12,16,0);
    header(1,14,3,0);    
    header(18,14,3,0);    
    header(8,4,4,0);  

    // arduino nano
    translate([45.2,1.3*25.4,pb_height+header_height+pin_base_z]) rotate([0,0,180]) Arduino_Nano(1,1);    

    // DHT 11
    translate([54.2,36.5,4]) rotate([0,0,180]) dht11();
}
    
module dht11() {
    
    dht11_h = 28.3;
    dht11_w = 12.75;
    dht11_d = 1.52;
        
    dht11_blue_h = 16;
    dht11_blue_w = 12.75;    
    dht11_blue_d = 6.0;    

    pin_h = 8.75;
    pin_off = 5.75;
    
    translate([-(dht11_w-3*pin_base_x)/2-2.54/2,pin_off-pin_base_x,pin_h-pin_base_x]) {
    
        color([0,0,0])
            cube([dht11_w,dht11_d,dht11_h]);
        
        color("blue")
            translate([0,-dht11_blue_d,dht11_h-dht11_blue_h])
            cube([dht11_blue_w, dht11_blue_d,dht11_blue_h]);
        

        // header
        color([0,0,0])
            translate([(dht11_w-3*pin_base_x)/2,-pin_base_x,0])
                cube([3*pin_base_x,pin_base_z+tol,pin_base_x]);
                

        // pins
        translate([((dht11_w-3*pin_base_x)/2)+2.54/2,-pin_off+pin_base_x,-pin_h+pin_base_x])
            cylinder(r=head_pind/2, h=pin_h);
            
        translate([((dht11_w-3*pin_base_x)/2)+2.54*3/2,-pin_off+pin_base_x,-pin_h+pin_base_x])
            cylinder(r=head_pind/2, h=pin_h);
            
        translate([((dht11_w-3*pin_base_x)/2)+2.54*5/2,-pin_off+pin_base_x,-pin_h+pin_base_x])
            cylinder(r=head_pind/2, h=pin_h);
            
	}
}


module header(x = 1, y = 1, length = 3, type = 0) {
    // plastic base        
       /* 
		translate([xoff-pin_base_x/2,
						yoff-pin_base_x/2,
						pb_height])
			cube([npin_x*pin_base_x,pin_base_x,pin_base_z+pb_height]);

		translate([xoff-pin_base_x/2,
						yoff-pin_base_x/2,
						pb_height])
			cube([pin_base_x,npin_y*pin_base_x,pin_base_z+pb_height]);
        */
	
       if (type == 0) {
        // horisontal
        difference() {                
           color("black") translate([xoff-pin_base_x/2+pinsep*(x-1),yoff-pin_base_x/2+pinsep*(y-1),pb_height])
			cube([pin_base_x*length,pin_base_x,header_height]);         
          	
            for (pinNoX = [0:length-1]) {           translate([xoff+pinsep*(x-1)+pinsep*pinNoX,yoff+pinsep*(y-1),pb_height-delta])
			cylinder(d=pind, h=header_height+2*delta);         
	}
            
            }            
       } else {
           // vertical
           difference() {
       color("black") translate([xoff-pin_base_x/2+pinsep*(x-1),yoff-pin_base_x/2+pinsep*(y-1),pb_height])
			cube([pin_base_x,pin_base_x*length,header_height]);        
               
          	for (pinNoY = [0:length-1]) {           translate([xoff+pinsep*(x-1),yoff+pinsep*(y-1)+pinsep*pinNoY,pb_height-delta])
			cylinder(d=pind, h=header_height+2*delta);            
	}                         
               } 
       }    
}

// perf board
module perfboard() {

    
    difference() {
        union() {
        // green perf board
        color("green") cube([pb_width, pb_depth, pb_height], false);
            
    }
    
        union() {
     /*   
    // perfboard holes
    color("yellow") {    
	for (pinNoX = [0:npin_x-1]) {
        for (pinNoY = [0:npin_y-1]) {
		
            translate([xoff+pinsep*pinNoX,yoff+pinsep*pinNoY,-delta])
			cylinder(d=pind, h=pinh+pin_base_z);
            
        }
	}
}  
       */     
            
            translate([pb_hole_dia/2+pb_hole_edge,pb_hole_dia/2+pb_hole_edge,-delta]) cylinder(pb_height+2*delta,d=pb_hole_dia);

            translate([pb_width-pb_hole_dia/2-pb_hole_edge,pb_hole_dia/2+pb_hole_edge,-delta]) cylinder(pb_height+2*delta,d=pb_hole_dia);

            translate([pb_hole_dia/2+pb_hole_edge,pb_depth-pb_hole_dia/2-pb_hole_edge,-delta]) cylinder(pb_height+2*delta,d=pb_hole_dia);

            translate([pb_width-pb_hole_dia/2-pb_hole_edge,pb_depth-pb_hole_dia/2-pb_hole_edge,-delta]) cylinder(pb_height+2*delta,d=pb_hole_dia);
                        
        }
    }
}
