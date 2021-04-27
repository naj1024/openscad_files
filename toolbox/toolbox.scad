/*
 Storage box with hinge and latch
 
 V1.0   - First release after remix
 V1.1   - Added lip on bottom half
 V1.2   - Added text on lid and code tidy up
 V1.3   - Bug fix: bottom was 2* wall_thickness
 V1.4   - Openscad customizer (View->Customizer (unhide))
 V1.4.1 - Variable latch width 
 V1.4.2 - Fix for thingiverse not supporting true/false
 
 Note the lid and bottom are the same height, so it can be printed
 in place flat on the bed. You may be able to print separate halves
 of different heights and push the hinge together, no guarantees.
 
 Remixed from:
 https://www.thingiverse.com/thing:2969508

 Tested with:
    length width   height  lip    text
    100      50     12.5   false  false  original (before remix)
    135      90     14     false  false
    135      90     18     true   true
*/

/* [Box dimensions] */
// maximums are set for a 200mm square bed
// hinge on this length
length = 135;         // [70:200]
width = 90;           // [20:95]
// per half, outside dimension. MINIMUM 12mm
height = 18;          // [12:50]
wall_width = 2;       // 
latch_width = 10;  

/* [Text on lid] */
// Add an engraved text on the top, 'help->font list' for available
add_text = 1;  // [0:No,1:Yes]
lid_text = "Tools";
text_font="Comic Sans MS"; 

/* [Lip] */
// Add a lip on bottom, note will reduce inside dimension by 2*lip_width
add_lip = 1;  // [0:No,1:Yes]
lip_height = 2.0;
lip_width = 1.0;

/* [fixed values] */
hinge_width_flat = 5;
latch_thickness = 2;
hinge_from_edge = (length>100)?20:10;  // above 100mm wide hinges are 10mm further in
hinge_length = 10;
rounding_radius = 2.5;

/* [Render resolution] */
// Set to 0.01 for higher definition curves (renders slower)
$fs = 0.01;

// derived values, does not take account of lip on bottom half
inside_length = length-2*wall_width;
inside_width = width-2*wall_width;
inside_height = height-wall_width+1;  // extra 1 to compensate for translate

/*******************/
/*                 */
/* start of design */
/*                 */
/*******************/

// lay flat on x
rotate([180,0,0])
// offset by height of each half on z
translate([0,0,-height])
// offset either side of y to allow for hinge
translate([0,hinge_width_flat,0])

// bottom with latch and optional lip
union() {
    difference() {
        roundedcube([length, width, height], false, rounding_radius, "zmax");
        // remove the inside
        translate([wall_width, wall_width, -1]) {
            roundedcube([inside_length, inside_width, inside_height],false,rounding_radius,"zmax");
        }
        
        // 4 finger grips on outside of bottom
        groove(((length/2)-(latch_width/2)), (width-2*wall_width), -3, g_length=latch_width-2, g_offset=-4);
        groove(((length/2)-(latch_width/2)), (width-2*wall_width), -3, g_length=latch_width-2, g_offset=-6);
        groove(((length/2)-(latch_width/2)), (width-2*wall_width), -3, g_length=latch_width-2, g_offset=-8);
        groove(((length/2)-(latch_width/2)), (width-2*wall_width), -3, g_length=latch_width-2, g_offset=-10);
    }
    
    // latch on inside 
    translate([(length/2)-(latch_width/2), (width-2*wall_width), -3]) {
        union() {
            cube([latch_width,latch_thickness,height+1]);
            rotate([0,90,0]) {
                translate([-1,1.8,1]) {
                    cylinder(h=latch_width-2, r1=1, r2=1, $fn=100);
                }
            }
        }
    }
    
    // the dust lip
    if (add_lip) {
        translate([0, 0, 0]) {
            difference() {
                translate([wall_width, wall_width, -lip_height]) {
                    roundedcube([inside_length, inside_width, inside_height+lip_height], false, rounding_radius, "zmax");
                }
                translate([wall_width+lip_width, wall_width+lip_width, -lip_height-1]) {
                    roundedcube([inside_length-2*lip_width, inside_width-2*lip_width, inside_height+2], false, rounding_radius, "zmax");
                }
            }
        }
    }

    // hinges
    hingeouter(hinge_from_edge, 10);
    hingeouter((length-hinge_from_edge-hinge_length), 0);
}

// top with notch to receive the latch from the bottom
translate([0,0,height])
rotate([180,0,0])
union() {
    translate([0, -(width+hinge_width_flat), 0]) {
        difference() {
            roundedcube([length, width, height], false, rounding_radius, "zmax");
            
            translate([wall_width, wall_width, -1]) {
                roundedcube([inside_length, inside_width, inside_height], false, rounding_radius,"zmax");
            }
            
            // groove for latch in inside
            translate([(length/2)-(latch_width/2),2,2]) {
                rotate([0,90,0]) {
                    cylinder(h=latch_width-2, r1=1, r2=1, $fn=100);
                }
            }
           
            // text, depth of engraving is a fraction of the wall_width here
            if(add_text) {
                translate([length/2,width/2,height-wall_width/5]) {
                    linear_extrude(5, convexity=4) {
                        mirror([180,0,0]) {
                            mirror([180,0,0]) {
                                text(lid_text, font=text_font, valign="center", halign="center");
                            }
                        }
                    }
                }    
            }
        }
    }
    
    // hinges
    hingeinner((hinge_from_edge+hinge_length+.5), 0);
    hingeinner((length-hinge_from_edge-2*hinge_length-0.5), 10);
}
        
module hingeouter(h_offset, mm){
    rotate([0,90,0]) {
        translate([0,-5,h_offset]) {
            difference() {
                union() {
                    cylinder(h=10, r1=4, r2=4, $fn=100);     
                    difference() {
                        translate([2,3,0])
                        rotate([0,0,135])
                        cube([10,7,10]);
                        translate([0,7,-5]) 
                        rotate([0,0,90]) 
                        cube([4,10,20]);
                    }
                }
                translate([0,0,mm]) {
                    sphere(3, $fn=100);
                }
            }
        }
    }
}

module hingeinner(h_offset, mm){
    rotate([0,90,0]) {
        translate([0,0,h_offset]) {
            union() {
                cylinder(h=10, r1=4, r2=4, $fn=100);
                difference() {
                    translate([-5,-10,0])
                    rotate([0,0,45]) 
                    cube([9,7,10]);   
                    translate([0,-10,-1]) 
                    rotate([0,0,90]) 
                    cube([3,10,20]);
                }
                translate([0,0,mm]) {
                    sphere(2.75, $fn=100);
                }
            }
        }
    }
}

module groove(x_start, y_start, z_start, g_length, g_offset) {
    translate([x_start, y_start, z_start]) {
        rotate([0, 90, 0]) {
            translate([g_offset, 4.8, 1]) {
                cylinder(h=g_length, r1=1, r2=1, $fn=100);
            }
        }
    }
}

module roundedcube(size = [1, 1, 1], center = false, radius = 0.5, apply_to = "all") {
	// If single value, convert to [x, y, z] vector
	size = (size[0] == undef) ? [size, size, size] : size;

	translate_min = radius;
	translate_xmax = size[0] - radius;
	translate_ymax = size[1] - radius;
	translate_zmax = size[2] - radius;

	diameter = radius * 2;

	obj_translate = (center == false) ?
		[0, 0, 0] : [
			-(size[0] / 2),
			-(size[1] / 2),
			-(size[2] / 2)
		];

	translate(v = obj_translate) {
		hull() {
			for (translate_x = [translate_min, translate_xmax]) {
				x_at = (translate_x == translate_min) ? "min" : "max";
				for (translate_y = [translate_min, translate_ymax]) {
					y_at = (translate_y == translate_min) ? "min" : "max";
					for (translate_z = [translate_min, translate_zmax]) {
						z_at = (translate_z == translate_min) ? "min" : "max";

						translate(v = [translate_x, translate_y, translate_z])
						if (
							(apply_to == "all") ||
							(apply_to == "xmin" && x_at == "min") || (apply_to == "xmax" && x_at == "max") ||
							(apply_to == "ymin" && y_at == "min") || (apply_to == "ymax" && y_at == "max") ||
							(apply_to == "zmin" && z_at == "min") || (apply_to == "zmax" && z_at == "max")
						) {
							sphere(r = radius);
						} else {
							rotate = 
								(apply_to == "xmin" || apply_to == "xmax" || apply_to == "x") ? [0, 90, 0] : (
								(apply_to == "ymin" || apply_to == "ymax" || apply_to == "y") ? [90, 90, 0] :
								[0, 0, 0]
							);
							rotate(a = rotate)
							cylinder(h = diameter, r = radius, center = true);
						}
					}
				}
			}
		}
	}
}