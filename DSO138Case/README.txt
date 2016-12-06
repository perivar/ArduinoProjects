                   .:                     :,                                          
,:::::::: ::`      :::                   :::                                          
,:::::::: ::`      :::                   :::                                          
.,,:::,,, ::`.:,   ... .. .:,     .:. ..`... ..`   ..   .:,    .. ::  .::,     .:,`   
   ,::    :::::::  ::, :::::::  `:::::::.,:: :::  ::: .::::::  ::::: ::::::  .::::::  
   ,::    :::::::: ::, :::::::: ::::::::.,:: :::  ::: :::,:::, ::::: ::::::, :::::::: 
   ,::    :::  ::: ::, :::  :::`::.  :::.,::  ::,`::`:::   ::: :::  `::,`   :::   ::: 
   ,::    ::.  ::: ::, ::`  :::.::    ::.,::  :::::: ::::::::: ::`   :::::: ::::::::: 
   ,::    ::.  ::: ::, ::`  :::.::    ::.,::  .::::: ::::::::: ::`    ::::::::::::::: 
   ,::    ::.  ::: ::, ::`  ::: ::: `:::.,::   ::::  :::`  ,,, ::`  .::  :::.::.  ,,, 
   ,::    ::.  ::: ::, ::`  ::: ::::::::.,::   ::::   :::::::` ::`   ::::::: :::::::. 
   ,::    ::.  ::: ::, ::`  :::  :::::::`,::    ::.    :::::`  ::`   ::::::   :::::.  
                                ::,  ,::                               ``             
                                ::::::::                                              
                                 ::::::                                               
                                  `,,`


http://www.thingiverse.com/thing:1202909
 Case for DSO138 - Remixed to fit new PCB mounting hole pattern by Easybotics is licensed under the Creative Commons - Attribution license.
http://creativecommons.org/licenses/by/3.0/

# Summary

This is derived from the great case design by Egil.

**Updated Dec 16th:** Increased clearance on the button inserts, and decreased height of tact switch standoffs in top.  Buttons are all decreased by .4mm diameter - and should fit with no filing or sanding necessary straight from printer (at least they do from my printer) - if you need larger clearance you can alter it in the SCAD file by editing the variable "buttonclearance = 0.2;" Clearance between slider switches and case is not changed as this close fit is necessary to keep the extensions from bending. 

**Original Post:**  When I printed one I noticed that the PCB holes did not line up with the version of the PCB I received in Dec 2015 from Banggood. - everything fits except the PCB mounting holes have moved 1mm towards the edge in the X dimension, and the slider switches appear the have moved .5mm to the left... Above pictures show original hole misalignment with my PCB- the files in this thing have the corrected hole locations as does the source SCAD. 

If your PCB has the mounting holes centered 5MM from the edges of the PCB (nor the corner) this is the correct version for you. 

Anyway now the PCB mounting holes appear to be symetrical from the corners of the PCB - whereas before they must have been about 6MM from the edge in the X (left, right) dimensions. 

A few other changes are the addition of the front USB port as I want to connect a lithium ion battery charger PCB ($1.5 on ebay) to the USB VBUS pin from this port to charge an internal li-ion instead of using 9V battery. Bangood also sells a stepup dc-dc converter designed for the DSO138 that takes 3.3-5V and boosts it to 9V. 

The battery charger PCB I choose also has under/over voltage protection built in which is critical to protect the battery if your battery doesn't come with a PCB attached. 

The electronics look like they will all fit in the 9V battery compartment, just barely ;) - although it is fairly easy to increase the size because the source is available in SCAD if you wanted a larger battery compartment. 

The countersink on the bottom cover was not wide/deep enough for my 3mm screws so I increased the width/depth some. The below screws now fit perfectly flush. The 10MM screws allow for 2.5MM thread engagement - if you want more choose the 12MM long ones, but 2.5mm seems to be enough as they don't have to bear any real force. 

I also increased the hole size the threads engage into - now the screws should self thread into the plastic without threading necessary. 

The screws I used are: Flat Socket Head Screws A2 SS - 3M x .5 x 10MM
From: http://www.albanycountyfasteners.com/Flat-Socket-Head-Cap-Screw-3MM-Stainless-Steel-p/5470000.htm

By - http://www.easybotics.com/
And - http://hilo90mhz.com/


# Post-Printing

Higher res pictures of wiring: https://goo.gl/photos/MEnoZuTqfLQ5hbV36
The parts are:
http://www.banggood.com/DSO138-Power-DCDC-Converter-Boost-Module-Step-up-Module-Board-p-1000089.html
http://www.banggood.com/TP4056-1A-Lipo-Battery-Charging-Board-Charger-Module-Mini-USB-Interface-p-1027027.html

The battery can be almost any single cell lipo with battery protection PCB built in. If you want to use a battery with no protection pcb built in you can buy charger modules that have the protection included like this one:
http://www.ebay.com/itm/5V-Micro-USB-1A-18650-Lithium-Battery-Charging-Board-Charger-Module-Protection-/371152022965?hash=item566a626db5:g:lWQAAOSwEK9UJ50a

The battery protection is important because otherwise there will be nothing to stop the battery voltage going below 3V and permanently damaging your battery. You can tell if your battery has protection PCB by looking near the contacts/wires - there will be a little narrow PCB under the tape there that contains an IC chip and MOSFETS to cut output when voltage goes too low. It can be seen under the yellow tape in one of my pictures.

Then you can use any battery without protection like this:
http://www.banggood.com/Walkera-Helicopter-Battary-Mini-CP-Genius-CP-Lithium-Battery-p-69307.html

The wires to the USB connector on the DSO138 PCB are to get 5V power to the charger - this way that connector charges the battery and you don't have to worry about mounting the new charger PCB where the port is accessible.

Using the parts I have everything barely fits in the space provided. 

Another option that may be easier/cheaper for some of you is to buy one of these 9V rechargeable batteries: http://www.banggood.com/9V-800mah-USB-Lithium-Rechargeable-Battery-p-986563.html

Then you would not need the charger or dc-dc converter, you would just have to cut a hole so that micro USB connector is accessible from the outside, or run some wires to the internal port I suppose.