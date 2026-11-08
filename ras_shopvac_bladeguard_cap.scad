// Slip-Fit Cap for 42.75mm OD Blade Guard Dust Port
// Configured with +0.35mm Shrinkage Compensation for smooth slip fit

$fn = 128; // High resolution for round cylinder walls

// Measured & Target Dimensions
//port_measured_od = 42.69; // Measured OD of metal/plastic guard port
port_measured_od = 42.69; // Measured OD of metal/plastic guard port

shrink_offset    = 0.1;  // CAD clearance to offset 3D printer internal shrinkage

cap_height       = 19.0;  // 19mm total height
wall_thick       = 2.5;   // 2.5mm cap wall thickness
top_thick        = 3.0;   // 3.0mm solid top end-cap thickness

// Calculated CAD Dimensions
cap_id = port_measured_od + shrink_offset; // ~43.10mm CAD hole
cap_od = cap_id + (2 * wall_thick);         // ~48.10mm Outer cap diameter

module guard_port_cap() {
    difference() {
        // Outer Cap Body
        cylinder(r = cap_od / 2, h = cap_height);
        
        // Internal Slip-Fit Chamber (Hollowed out from bottom)
        translate([0, 0, -1])
            cylinder(r = cap_id / 2, h = cap_height - top_thick + 1);
            
        // Lead-In Chamfer at bottom opening for easy slip-on insertion
        translate([0, 0, -1])
            cylinder(r1 = (cap_id / 2) + 1.2, r2 = cap_id / 2, h = 2.5);
    }
}

// Render on the build plate (Bottom opening resting on Z=0)
guard_port_cap();