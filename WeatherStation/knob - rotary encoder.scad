/* [Basic] */
//Diametre du bouton
Knob_Diameter=13; //[10:30]
//Hauteur du bouton
Knob_Height=15;//[10:20]
//Longueur de l'axe
Axis_Lenght=10;//[5:15]
//Arrondis
Rounded=2;//[1:3]
//Ajustement
Ajustment=0.2;//[0,0.1,0.2,0.3]

inner_dia = 6; // 6 mm shaft

/* [Hidden] */
$fn=50;

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
     //translate([0,0,-epsilon])cylinder(r=pr,h=h+2*epsilon,$fn=n);    
    
    cylinder(r=pr,h=h,$fn=n);    
}

difference() {
  union() {
      cylinder(r=Knob_Diameter/2,h=Knob_Height-Rounded);
      translate([0,0,Knob_Height-Rounded]) cylinder(r=Knob_Diameter/2-Rounded,h=Rounded);
      translate([0,0,Knob_Height-Rounded]) rotate_extrude(convexity = 10) translate([Knob_Diameter/2-Rounded,0,0]) circle(r=Rounded);
  }
  
  // grove at the top
  top_grove_rad = 0.7;
  translate([0,0,Knob_Height]) rotate([-90,0,0]) cylinder(r=top_grove_rad,h=Knob_Diameter/2);
  translate([0,0,Knob_Height]) sphere(r=top_grove_rad);
  
  // groves at the side
  side_grove_rad = 1.0;
  for (i=[22.5:45:360]) translate([(Knob_Diameter+0.6)*sin(i)/2,(Knob_Diameter+0.6)*cos(i)/2,3]) cylinder(r=side_grove_rad,h=Knob_Height);
  
  // shaft
  difference() {
      hole(inner_dia, Axis_Lenght-2);
      translate([-5,-6.5-Ajustment,0]) cube([10,5,Axis_Lenght-2]);
  }
}
