height = 4;
hole_dia = 6.6;
outer_dia = 16;
epsilon = 0.01;

// from polyholes-revisited.scad
nozzle_dia=0.4;
layer_height=0.2;

function pi() = 3.141592;
function width(d,h) = h-(pi()*((h*h)-(d*d)))/(4*h);
function arc(r,t) = 0.5*(t+sqrt((t*t)+4*(r*r)));
function polyhole(r,n,t) = arc(r,t)/cos(180/n);

function sides(d,t) = ceil(180 / acos((d-t)/d));

module hole(d,h)
{
  n=sides(d,0.1);
  t=width(nozzle_dia,layer_height);
  pr=polyhole(d/2,n,t);
  echo(str("orig dia: ", d, ", num sides: ", n, ", new dia: ",pr*2));
  translate([0,0,-epsilon])cylinder(r=pr,h=h+2*epsilon,$fn=n);    
}

// nut
difference() {
    
	Num_Sides = 6;			// Hexagon = 6
	Nut_Flats = outer_dia; 	// Measure across the flats
	Flats_Rad = Nut_Flats/2;
	Nut_Rad = Flats_Rad / cos(180/Num_Sides);    
    
    // nut
    cylinder(h = height, r = Nut_Rad, $fn = Num_Sides);
    
    // hole
    //translate([0,0,-epsilon]) cylinder(h = height+2*epsilon, r = hole_dia/2, $fn = 20);
    hole(hole_dia, height);
}