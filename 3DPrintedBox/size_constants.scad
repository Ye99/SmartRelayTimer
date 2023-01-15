// HomeDepot M52-PJ26-WM 79.5mm outer width, 124 outer length. https://www.homedepot.com/p/Leviton-Decora-1-Gang-White-Decorator-Rocker-Midway-Nylon-Wall-Plate-10-Pack-M52-0PJ26-0WM/100356780
// To get the width/length below, subtract wall_double_thickness.

// Standard width is 69.33mm. This is inner space width.
width=52; //[51:85]
// Inner space height. Default 41mm
height=41;  // [37:70]
// Wall thickness in mm, add to width and height. Actual wall (including cover) thickness is
// half of this value. 
wall_double_thickness=4; // [1:4]

/* Don't change these values */
// Inner space length.
length=106; // Note: if you change this, you must update the value at "why is this magic number?" in electrical_box.scad accordingly.