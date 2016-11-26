module polyhole(h, d) 
{
	/* Nophead's polyhole code */
    n = max(round(2 * d),3);
    rotate([0,0,180])
        cylinder(h = h, r = (d / 2) / cos (180 / n), $fn = n);
}

// make it interchangeable between this and cylinder
module cylinder_poly(r, h, center=false){
    polyhole(d=r*2, h=h, center=center);
}