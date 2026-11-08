// Shop Vac Hose Adapter Flange
// Designed for 2.25" ID hose / 1" total height / 1/4" mounting flange

$fn = 128; // High resolution for smooth round port walls
inch = 25.4;

// Key Parameters
port_id       = 2.27 * inch;   // 2.25" Inner Diameter (57.15mm)
wall_thick    = 3.0;           // 3mm wall thickness for sturdy PETG print
port_od       = port_id + (2 * wall_thick); // Outer Diameter of barrel

total_height  = 1.0 * inch;    // 1.0" Total Height (25.4mm)
flange_thick  = 0.25 * inch;   // 1/4" Flange Thickness (6.35mm)
flange_margin = 0.50 * inch;   // 1/2" Flange rim extension for screw mounting
flange_od     = port_od + (2 * flange_margin);

screw_hole_r  = 2.2;           // Clearance for #8 wood screws (4.4mm hole)
countersink_r = 4.5;           // Countersink diameter for screw head flush fit

module hose_adapter_flange() {
    difference() {
        union() {
            // 1/4" Bottom Mounting Flange Base
            cylinder(r = flange_od / 2, h = flange_thick);
            
            // 1" Tall Main Hose Barrel
            cylinder(r = port_od / 2, h = total_height);
        }
        
        // 2.25" Inner Diameter Airway Thru-Hole
        translate([0, 0, -1])
            cylinder(r = port_id / 2, h = total_height + 2);
            
        // 4x Countersunk Screw Mounting Holes in the Flange
        for (a = [45, 135, 225, 315]) {
            rotate([0, 0, a]) {
                translate([(port_od / 2) + (flange_margin / 2), 0, 0]) {
                    // Screw shank hole
                    translate([0, 0, -1])
                        cylinder(r = screw_hole_r, h = flange_thick + 2);
                        
                    // Countersink angle for flush screw heads
                    translate([0, 0, flange_thick - 2.5])
                        cylinder(r1 = screw_hole_r, r2 = countersink_r, h = 2.6);
                }
            }
        }
    }
}

// Render on build plate
hose_adapter_flange();