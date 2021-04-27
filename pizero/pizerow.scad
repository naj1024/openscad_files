/*
    An enginnering model of the pizero
    
 Measurements from Pizero / PizeroW mechanical drawing and measurements
*/

/* [Options] */
gpio_connector=1;   // [0:No,1:Yes] 
gpio_solder_pins=1; // [0:No,1:Yes] 

/* [pizero dimensions - DO NOT ALTER] */
pz_length = 65; // not including sd card protrusion
pz_width = 30;  // not including any connector protrusions
pz_pcb_thickness = 1.45; // including solder mask
pz_component_max_height = (3.1 - pz_pcb_thickness); // hdmi is max
pz_rounded_edge_offset = 3.0;
pz_botton_pin_height = 1.0;  // solder pins for gpio connector

pz_mount_hole_dia = 2.75; 
pz_mount_hole_offset = 3.5; // from edge
pz_mount_hole_dia_clearance = 6; 

pz_gpio_length = 50.8; // total 
pz_gpio_width = 5;  // total
pz_gpio_x_offset = 32.5;  // from left hand edge to centre of connector
pz_gpio_y_offset = 3.5; // long edge centre form pcb edge
pz_gpio_height = (9.8 - pz_pcb_thickness); // wihtout pcb thickness

pz_sdcard_y_offset = 16.9;
pz_sdcard_length = 15.4; // sdcard present
pz_sdcard_width = 12;
pz_sdcard_protrusion = 2.3; // sdcard present
pz_sdcard_height = (2.8 - pz_pcb_thickness); 

pz_camera_y_offset = 15;
pz_camera_length = 4.43;
pz_camera_width = 17;
pz_camera_protrusion = 1.1; // no cable present
pz_camera_height = (2.65 - pz_pcb_thickness);

pz_hdmi_x_offset = 12.4;
pz_hdmi_length = 11.2;
pz_hdmi_width = 7.6;
pz_hdmi_protrusion = 0.5; // no cable present
pz_hdmi_height = (4.7 - pz_pcb_thickness);

pz_usb_power_x_offset = 54;
pz_usb_x_offset = 41.4;
pz_usb_length = 8;
pz_usb_width = 5.6;
pz_usb_protrusion = 1; // no cable present
pz_usb_height = (3.96 - pz_pcb_thickness);

pz_max_length = pz_length + pz_sdcard_protrusion + pz_camera_protrusion;
pz_max_width = pz_width + pz_usb_protrusion;

function pz_get_max_height(gpio_header, gpio_solder) =
    pz_pcb_thickness  + 
    (pz_botton_pin_height * (gpio_solder?1:0)) + 
    (pz_gpio_height * (gpio_header?1:0)) +
    (pz_component_max_height * (gpio_header?0:1));


module pzw(gpio_header = true, gpio_solder = true) { 

    pz_max_height = pz_get_max_height(gpio_header, gpio_solder);
    
    echo("pi max length ", pz_max_length);
    echo("pi max width  ", pz_max_width);
    echo("pi max height ", pz_max_height);

    module pzw_solid() {
        // rounded edges on pcb
        x_round = [pz_rounded_edge_offset, (pz_length - pz_rounded_edge_offset)];
        y_round= [pz_rounded_edge_offset, (pz_width - pz_rounded_edge_offset)];
        for (x = x_round, y = y_round)
            translate([x, y, 0])
            {
                $fn = 40;
                cylinder(d=(2*pz_rounded_edge_offset), h=pz_pcb_thickness);
            }  

        // pcb split into bits to conform with rounded edges
        translate([pz_rounded_edge_offset, 0, 0])
            cube([pz_length - (2 * pz_rounded_edge_offset), pz_width, pz_pcb_thickness]);
        translate([0, pz_rounded_edge_offset, 0])
            cube([pz_length, pz_width - (2 * pz_rounded_edge_offset), pz_pcb_thickness]);

        // gpio 
        if (gpio_header)
        translate([pz_gpio_x_offset-(pz_gpio_length/2), 
                  (pz_width-pz_gpio_y_offset-(pz_gpio_width/2)), 
                  pz_pcb_thickness])
            cube([pz_gpio_length, pz_gpio_width, pz_gpio_height]);

        // gpio underside solder
        if (gpio_solder)
        translate([pz_gpio_x_offset-(pz_gpio_length/2), 
                  (pz_width-pz_gpio_y_offset-(pz_gpio_width/2)), 
                  -pz_botton_pin_height])
            cube([pz_gpio_length, pz_gpio_width, pz_botton_pin_height]);
        
        // sdcard 
        translate([-pz_sdcard_protrusion, 
                  (pz_sdcard_y_offset-(pz_sdcard_width/2)), 
                  pz_pcb_thickness])
            cube([pz_sdcard_length, pz_sdcard_width, pz_sdcard_height]);

        // camera
        translate([(pz_length - pz_camera_length + pz_camera_protrusion), 
                   (pz_camera_y_offset-(pz_camera_width/2)), 
                    pz_pcb_thickness])
            cube([pz_camera_length, pz_camera_width, pz_camera_height]);
            
        // hdmi 
        translate([(pz_hdmi_x_offset - (pz_hdmi_length/2)), 
                   -pz_hdmi_protrusion, 
                    pz_pcb_thickness])
            cube([pz_hdmi_length, pz_hdmi_width, pz_hdmi_height]);
            
        // usb power 
        translate([(pz_usb_power_x_offset - (pz_usb_length/2)), 
                   -pz_usb_protrusion, 
                    pz_pcb_thickness])
            cube([pz_usb_length, pz_usb_width, pz_usb_height]);
        
        // usb 
        translate([(pz_usb_x_offset - (pz_usb_length/2)), 
                   -pz_usb_protrusion, 
                    pz_pcb_thickness])
            cube([pz_usb_length, pz_usb_width, pz_usb_height]);
    }
    
    // make 0,0,0 centre
    translate([pz_camera_protrusion+pz_camera_protrusion-pz_max_length/2, 
               pz_usb_protrusion-pz_max_width/2, 
               0])
    difference () {
        pzw_solid();

        // mounting holes
        x_holes = [pz_mount_hole_offset, (pz_length - pz_mount_hole_offset)];
        y_holes = [pz_mount_hole_offset, (pz_width - pz_mount_hole_offset)];
        for (x = x_holes, y = y_holes)
            translate([x, y, -pz_pcb_thickness])
            {
                $fn = 40;
                cylinder(d=pz_mount_hole_dia, h=10);
            }
   }
}

// uncomment if you want one
//color("blue")
//pzw(gpio_connector, gpio_solder_pins);
