// Standard width is 69.33mm. This is inner space width.
width=52; //[51:85]
// Inner space height. Default 41mm
height=41;  // [37:70]
// Wall thickness in mm, add to width and height. Actuall wall (including cover) thickness is
// half of this value. 
wall_double_thickness=4; // [1:4]

/* Don't change these values */
// Inner space length.
length=106; // Note: if you change this, you must update screw_posistion_from_edge and the value at "why is this magic number?" in electrical_box.scad accordingly.