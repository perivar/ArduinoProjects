include <arduino.scad>

//enclosure(boardType = 4);

//bumper();

height = 8;

standoffs( 
  boardType = UNO, 
  height = height, 
  topRadius = mountingHoleRadius + 1, 
  bottomRadius =  mountingHoleRadius + 2, 
  holeRadius = mountingHoleRadius,
  mountType = TAPHOLE
);

translate([0,0,height])
arduino(boardType = 4);
