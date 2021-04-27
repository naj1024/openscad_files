/*
    A box for the pizero(/w).
    Designed to allow the pizero to be completely in the box, resiliant to
    dust and pokey fingers.
    
    * Configurable connector holes
    * Either holes, for screws/bolts, or mounting pins for the pizero
    * Engineering model of a pizero, so you can check if it looks right
        - remember to turn this off before generating an STL
        
    TODO:
    * Calculate everything, remove magic numbers
    * Cut outs the gland on the lid to allow connectors right into the pizero
*/

// THINGIVERSE customizer does not understand true/flase, so use 1/0 instead

/* [parts] */
make_bottom=1;   // [0:No,1:Yes] 
make_top=1;      // [0:No,1:Yes] 

/* [connectors] */
sdcard_hole = 1; // [0:No,1:Yes] 
power_hole = 1;  // [0:No,1:Yes] 
hdmi_hole = 1;   // [0:No,1:Yes] 
usb_hole = 1;    // [0:No,1:Yes] 
camera_hole = 1; // [0:No,1:Yes] 
gpio_hole = 1;   // [0:No,1:Yes] 
pins = 1;        // [0:No,1:Yes] 

/* [box] */
// gap around pizero inside the box
gap = 1.0;
// wall thickness of box
shell_thickness = 1.6;
// standoffs pizero sits on in the box
standoffs = 1.5;


/* [Text on lid] */
// Add an engraved text on the top, 'help->font list' for available
add_text = 1;  // [0:No,1:Yes]
lid_text = "pizerow";
text_font="Comic Sans MS"; 

/* [pizero options] */
// show an engineering model
dummy_pizero = 0;  // [0:No,1:Yes] 
// do we need height for a header
//pz_header = 0; // not tested, problems with heights 
// allow for solder on bottom, standoffs take care of this
//pz_solder = 0;    // don't need to allow for this as we have standoffs


// the pizero engineering model with the measurements we use, includes don't work in thingiverse customizer
include <pizerow.scad>;

case_inside_length = pz_max_length + 2*gap;
case_inside_width = pz_max_width + 2*gap;
case_inside_height = pz_get_max_height(true, true) + standoffs; 

case_outside_length = case_inside_length + (2*shell_thickness);
case_outside_width = case_inside_width + (2*shell_thickness);
case_outside_height = case_inside_height; //+ (2*shell_thickness);

module rounded_box(length, 
             width, 
             height, 
             rounded_edge_radius) 
{    
    
    // rounded edges
    x_round = [rounded_edge_radius, (length - rounded_edge_radius)];
    y_round= [rounded_edge_radius, (width - rounded_edge_radius)];
    for (x = x_round, y = y_round)
        translate([x, y, 0])
        {
            $fn = 40;
            cylinder(d=(2*rounded_edge_radius), h=height);
        }  

    // pcb split into bits to conform with rounded edges
    translate([rounded_edge_radius, 0, 0])
        cube([length - (2 * rounded_edge_radius), 
                width, 
                height]);
    translate([0, rounded_edge_radius, 0])
        cube([length, 
                width - (2 * rounded_edge_radius), 
                height]);    
}

module shell(inside_length, 
             inside_width, 
             inside_height, 
             thickness, 
             rounded_edge_radius) 
{
    difference () 
    {
        // outside
        translate([-thickness, -thickness, -thickness])
            rounded_box(case_outside_length, 
                case_outside_width, 
                case_outside_height,
                rounded_edge_radius);
    
        // inside, remove top by extending it through the outside
        rounded_box(inside_length, inside_width, case_outside_height+1, rounded_edge_radius);
        
        if (sdcard_hole) {
            offset = 10.4 + gap; // magic number for centre line
            translate([-case_outside_length/8, offset, standoffs+pz_pcb_thickness/2])
                #cube([case_outside_length/4, pz_sdcard_width+3, 4]);
        }
        
        if (usb_hole) {
            offset = 37.9 + gap;
            translate([offset, -case_outside_width/4, standoffs-0.6])
                #cube([pz_usb_length+3.5, case_outside_length/4, 7]);
        }

        if (power_hole) {
            offset = 50.5 + gap;
            translate([offset, -case_outside_width/4, standoffs-0.6])
                #cube([pz_usb_length+3.5, case_outside_length/4, 7]);
        }
        
        // hole for camera
        if (camera_hole) {
            offset = 8.5 + gap;
            translate([case_outside_length/1.25, offset, (standoffs+pz_pcb_thickness)])
                #cube([case_outside_length/4, pz_camera_width-2, 1.2]);
        }
        if (hdmi_hole) {
            offset = 7.3 + gap;
            translate([offset, -case_outside_width/4, standoffs+pz_pcb_thickness/2])
                #cube([pz_hdmi_length+3.5, case_outside_length/4, 5]);
        }
    }
}

module bottom_shell() {
    translate([-case_inside_length/2, -case_inside_width/2, 0])
        shell(case_inside_length, 
              case_inside_width, 
              case_inside_height, 
              shell_thickness, 
              pz_rounded_edge_offset);

    // mounting standoffs and pins for pizero
    translate([pz_camera_protrusion+pz_camera_protrusion-pz_max_length/2,
                pz_usb_protrusion-pz_max_width/2, 0]) 
    {
        x_pins = [pz_mount_hole_offset, (pz_length - pz_mount_hole_offset)];
        y_pins = [pz_mount_hole_offset, (pz_width - pz_mount_hole_offset)];
        for (x = x_pins, y = y_pins)
            translate([x, y, 0])
            {
                $fn = 40;
                cylinder(d=pz_mount_hole_dia_clearance, h=standoffs);
                translate([0, 0, standoffs])
                    if (pins) 
                    {
                        // allow for some slack in the hole diameter, 0.9
                        // pins longer then pcb is thick so pcb can't slip out
                        cylinder(d=(pz_mount_hole_dia*0.9), h=3*pz_pcb_thickness);
                    }
            }
    }  
    
    // for reference we can add a dummy pizero
    if (dummy_pizero) {
        color("yellow")
            translate([0, 0, standoffs]) // add 20 for outside box
                pzw(true, trues);
    }
}


module bottom() {
    difference() 
    {
        bottom_shell();
        // holes right through instead of pins
        if (!pins) 
        {
            translate([pz_camera_protrusion+pz_camera_protrusion-pz_max_length/2,
                    pz_usb_protrusion-pz_max_width/2, 0]) 
            {
                x_pins = [pz_mount_hole_offset, (pz_length - pz_mount_hole_offset)];
                y_pins = [pz_mount_hole_offset, (pz_width - pz_mount_hole_offset)];
                for (x = x_pins, y = y_pins)
                    translate([x, y, 0])
                    {
                        $fn = 40;
                        translate([0, 0, -2*shell_thickness])
                            #cylinder(d=(pz_mount_hole_dia*1.1), h=2*case_inside_height);
                    }
            }
        }
    }
}

module top_with_rim() {
    // add an extra layer on top to cover the gpio hole
    lid_thickness = (gpio_hole)?(shell_thickness):(shell_thickness+1);
    rounded_box(case_outside_length, case_outside_width, lid_thickness, pz_rounded_edge_offset);
    
    // need to make a rim/gland
    translate([shell_thickness, shell_thickness, -2*shell_thickness]) 
    {
        // translate to make sure that rim is part of the top
        translate([0,0,0.5]) 
        difference() 
        {
            rounded_box(case_outside_length - 2*shell_thickness, 
                         case_outside_width - 2*shell_thickness, 
                         2*shell_thickness, 
                         pz_rounded_edge_offset);
            
            // make a gland type rim by extending through the inside box
            translate([shell_thickness, shell_thickness, -shell_thickness])
                rounded_box(case_inside_length - 2*shell_thickness, 
                            case_inside_width - 2*shell_thickness, 
                            3*shell_thickness, 
                            pz_rounded_edge_offset);
        }
    }
}

module top () {
    color("orange")
    
    translate([-case_inside_length/2-shell_thickness, 
                -case_inside_width/2-shell_thickness, 
                case_outside_height+shell_thickness]) 
        difference () 
        {
            top_with_rim();
         
            // always cut out for gpio pins
            offset_x = 9.9 + gap; // magic numbers
            offset_y = 25.4 + gap;
            translate([offset_x, offset_y, -3*shell_thickness])
                #cube([pz_gpio_length+2, 
                       pz_gpio_width+2,
                       4*shell_thickness+0.3]);
            
            // a notch to make taking top of easier
             translate([0, 10+gap, -0.1])
                cube([shell_thickness, 
                       15,
                       shell_thickness*0.6]);
            
            // text, really deep text if we have no gpio cutout
            if(add_text) 
            {
                translate([case_outside_length/2,case_outside_width*0.5,+shell_thickness*0.5]) 
                    linear_extrude(5, convexity=4) 
                        text(lid_text, font=text_font, valign="center", halign="center");
            }
        }
    
    if (pins)
    {
        // add locking pins to lid
        // values iteratively found 
        translate([pz_camera_protrusion+pz_camera_protrusion-pz_max_length/2, 
                    pz_usb_protrusion-pz_max_width/2,
                    case_outside_height - 2.9*shell_thickness]) 
        {
            x_pins = [pz_mount_hole_offset, (pz_length - pz_mount_hole_offset)];
            y_pins = [pz_mount_hole_offset, (pz_width - pz_mount_hole_offset)];
            for (x = x_pins, y = y_pins)
                translate([x, y, 0])
                {
                    //translate([0, 0, -2*shell_thickness])
                    difference ()
                    {
                        $fn = 40;
                        length = 6.6; //magic
                        #cylinder(d=pz_mount_hole_dia_clearance*0.9, h=length);
                        #cylinder(d=pz_mount_hole_dia*1.1, h=length);
                    }
                }
        }
            
    }
}

/*
// something doesn't add up, measured prints do not equate
echo("inside length ", case_inside_length);
echo("inside width  ", case_inside_width);
echo("inside height  ", case_inside_height);

echo("outside length ", case_outside_length);
echo("outside width  ", case_outside_width);
echo("outside height ", case_outside_height);
*/

if (make_bottom) bottom();
if (make_top) top();
