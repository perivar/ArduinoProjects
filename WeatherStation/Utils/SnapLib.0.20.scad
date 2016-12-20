/*simple Snap library based on "Snap-Fit Joints for Plastics - A Design Guid" by Bayer MaterialScience LLC 
  http://fab.cba.mit.edu/classes/S62.12/people/vernelle.noel/Plastic_Snap_fit_design.pdf
 on http://www.thingiverse.com/thing:1860118
 by fpetrac
 Licensed under the Creative Commons - Attribution - Non-Commercial license.
*/


// Rev: SnapLib 0.00.scad first release
//      SnapLib 0.10.scad  added RSnapY RRSnapY
//      SnapLib 0.20.scad  Bug Fix

f = false;

//eps=0.5*12/100;//Elongation at break of ABS=12%
eps=0.5*6/100;//Elongation at break of PLA=6%

module SnapH(l,y,a,b)   //Define y calculate h
{    
    h=1.09*(eps*pow(l,2))/(y);
    p=y;
    echo("h is",h);
linear_extrude(height = b, center = f, convexity = 10, twist = 0)
polygon([[0,0],[l,0],[l,y],[l+p,y],[l+p+(y+h/4)/tan(a),-h/4],[l,-h/2],[0,-h]]);
}

module SnapY(l,h,a,b)   //Define h calculate y
{    
    y=1.09*(eps*pow(l,2))/(h);
    p=y;
    echo("y is", y);
linear_extrude(height = b, center = f, convexity = 10, twist = 0)
polygon([[0,0],[l,0],[l,y],[l+p,y],[l+p+(y+h/4)/tan(a),-h/4],[l,-h/2],[0,-h]]);
}

module RSnapY(l,h,a,Lobi,r2,K2=2)   //Define h calculate y
{    
    Theta=180/Lobi;
    y=1.64*K2*(eps*pow(l,2))/(r2);
    p=y;
    echo("y is", y);
    echo("r1/r2",(r2-h)/r2);
    echo("Theta", Theta);
    for(f=[0:1:Lobi])
    rotate([0,0,Theta*2*f])
rotate_extrude(angle = Theta, convexity = 2,$fn=200)
    translate([r2,0,0])
    mirror([1,-1,0])
    polygon([[0,0],[l,0],[l,y],[l+p,y],[l+p+(y+h/4)/tan(a),-h/4],[l,-h/2],[0,-h]]);
}

module RRSnapY(l,h,a,Lobi,r2,K1=2)   //Define h calculate y
{    
    Theta=180/Lobi;
    y=1.64*K1*(eps*pow(l,2))/(r2);
    p=y;
    echo("y is", y);
    echo("r1/r2",(r2-h)/r2);
    echo("Theta", Theta);
    for(f=[0:1:Lobi])
    rotate([0,180,Theta*2*f])
rotate_extrude(angle = Theta, convexity = 2,$fn=200)
    translate([r2,0,0])
    mirror([1,1,0])
    polygon([[0,0],[l,0],[l,y],[l+p,y],[l+p+(y+h/4)/tan(a),-h/4],[l,-h/2],[0,-h]]);
}
