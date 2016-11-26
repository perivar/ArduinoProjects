// DVmega case maker
// Made by PD0ZRY
include <arduino.scad>

//Make the Case
//mega_ambe();
accu_monitor = 17;
uno_battery();
%translate([55,67.5+accu_monitor,29.5]) rotate([90,180,0]) usb_charger();
%translate([0,0,8]) arduino(UNO);
//%color("red") translate([2,0,36]) cube([50,85,8.5]); //Battery
%translate([39,-3,2.5]) rotate([180,180,180+90]) micro_usb_board(); //z=2

//enclosureLid(UNO);


module micro_usb_board() {
	difference() {
		cube([15,14,2]);
	}
	translate([-1,3,2]) cube([6,8,3]);
}
module usb_charger(){
	pcb_height = 2;
	cube([57,27,pcb_height]); //PCB
	translate([13,0,pcb_height]) cube([14.6,10,7]); //USB1
	translate([38,0,pcb_height]) cube([14.6,10,7]); //USB2
	translate([29,0,pcb_height]) cube([8,6,3]); //Micro USB
	translate([0,3.5,pcb_height]) cube([7,7.3,8]); //Button
	translate([18,10,-7]) cube([28.5,15.7,7]); //Display part1
	translate([14,10,-5]) cube([5,13,5]); //Display part2
}

module uno_battery() {
	difference() {
		enclosure(UNO,3,3,10+5+9,3,TAPHOLE); // basic box with tapholes
		translate([32,0,30]) rotate([90,90,0]) cylinder(h=8,r1=7,r2=7); // RF connector
		translate([32-7,-10,30]) cube([14,14,7.5]);
		translate([7.75,90,3]) rotate([90,0,0]) cube([28.5+1.5,15.7+1.5,7+1.5]); //display hole
		translate([55,80,23.25]) rotate([0,90,0]) cylinder(5,1.6,1.6); //Power button
		translate([26,-7,3]) cube([12,8,7]); // USB charger port
		translate([39.25,-3,2]) rotate([0,0,90]) cube([15.5,14.5,2]); //Chart port cutt-out
	}
}

module mega_ambe() {
	difference() {
		enclosure(MEGA,3,3,10+5,3,TAPHOLE); // basic box with tapholes
		translate([32,0,30]){
			rotate([90,90,0]) cylinder(h=8,r1=7,r2=7); // RF connector
		}
		translate([32-7,-10,30]){
			cube([14,14,10]);
		}
		translate([6,140,8+1.7]) cube([11,10,11]); //lf power
		translate([8+16,150,8+6+1.7]) rotate([90,90,0]) cylinder(h=10,r1=5,r2=5); //lf out
		translate([8+17+7,140,8+1.7]) cube([12,14,15]); //mic in

	}

	//Make the lid
	//translate([-100,0,0]) 
	/*difference() {
enclosureLid(DUE);
translate([32,119,-5])cylinder(h=10,r1=5,r2=5); //potmeter hole
}*/
}
