nozzle_dia=0.4;
layer_height=0.3;

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
  echo(d,n,pr*2);
  translate([0,0,-1])cylinder(r=pr,h=h+2,$fn=n);    
}

module main() {
  difference() {
    linear_extrude(5) {
      hull(){
        rotate([0,0,-46.5])
          translate([5,2])
            square([0.001,168]);

        rotate([0,0,-43.5])
          translate([-5,2])
            square([0.001,168]);
      }
    }
    rotate([0,0,-45])
      for(i=[1:0.5:10])
	    translate([0,i*(i+6),0])hole(i,5);
  }
}

translate([10,10,0])main();