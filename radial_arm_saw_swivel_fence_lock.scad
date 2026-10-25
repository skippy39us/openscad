// Dual-Plate Miter Indexer System for Radial Arm Saw
// Parameters defined in inches with automatic conversion to mm

$fn = 64;

// Conversion factor
inch = 25.4;

// Parameters (specified in SAE/Inches)
base_thickness_in = 5/16;    // 5/16" plate thickness for robust countersinking depth
lip_depth_in = 5/16;         // ~5/16" drop-down lip depth
lip_thickness_in = 1/16;     // 1/16" registration lip thickness along Y
arc_radius_in = 1.77;        // Distance from pivot to indexing holes (~45mm)

// Converted metric values for OpenSCAD geometry
base_thickness = base_thickness_in * inch;
lip_depth = lip_depth_in * inch;
lip_thickness = lip_thickness_in * inch;
arc_radius = arc_radius_in * inch;

// Pivot Y is fixed at 3/8" back from the outside edge (Y = 0), independent of lip thickness
pivot_y = -(3/8 * inch);

pivot_radius = 4.2;          // M8 bolt clearance (8.4mm hole)
pin_radius = 3.15;           // 6mm pin clearance (6.3mm hole)
screw_radius = 2.5;          // M5 screw clearance
countersink_radius = 5.0;    // M5 flat head top radius (~10mm diameter)
countersink_depth = 3.0;     // Depth of the tapered head

// Left Base Plate with top-countersunk mounting holes
module left_base_plate() {
    pivot_x = -55.0;
    difference() {
        union() {
            // Main base plate body extending backward from Y = 0
            translate([pivot_x - 45, -75, 0])
                cube([60, 75, base_thickness]);
                
            // Front registration lip at the very front edge (y = -lip_thickness to 0)
            translate([pivot_x - 45, -lip_thickness, -lip_depth])
                cube([60, lip_thickness, base_thickness + lip_depth]);
        }
        
        // Pivot hole positioned at pivot_y
        translate([pivot_x, pivot_y, -1])
            cylinder(r=pivot_radius, h=base_thickness + 2);
            
        // Left indexing arc holes (-22.5°, -45°, -60°) relative to pivot_y
        translate([pivot_x, pivot_y, 0]) {
            for (angle = [-22.5, -45, -60]) {
                rotate([0, 0, angle])
                    translate([0, -arc_radius, -1])
                        cylinder(r=pin_radius, h=base_thickness + 2);
            }
        }
        
        // Base plate mounting screw hole 1 (with top countersink)
        translate([pivot_x - 30, pivot_y, -1])
            cylinder(r=screw_radius, h=base_thickness + 2);
        translate([pivot_x - 30, pivot_y, base_thickness - countersink_depth])
            cylinder(r1=screw_radius, r2=countersink_radius, h=countersink_depth + 1);
            
        // Base plate mounting screw hole 2 (with top countersink)
        translate([pivot_x - 15, pivot_y, -1])
            cylinder(r=screw_radius, h=base_thickness + 2);
        translate([pivot_x - 15, pivot_y, base_thickness - countersink_depth])
            cylinder(r1=screw_radius, r2=countersink_radius, h=countersink_depth + 1);
        
        // Placed safely on the plate surface (X: -85, Y: -40) cutting 2mm deep
        translate([-65, -40, base_thickness - 2]) 
            linear_extrude(height = 4) 
                text("Left", size = 8, font = "Liberation Sans", halign = "left", valign = "baseline");
        
    }
}

// Right Base Plate with top-countersunk mounting holes
module right_base_plate() {
    pivot_x = 55.0;
    difference() {
        union() {
            // Main base plate body extending backward from Y = 0
            translate([pivot_x - 15, -75, 0])
                cube([60, 75, base_thickness]);
                
            // Front registration lip at the very front edge (y = -lip_thickness to 0)
            translate([pivot_x - 15, -lip_thickness, -lip_depth])
                cube([60, lip_thickness, base_thickness + lip_depth]);
        }
        
        // Pivot hole positioned at pivot_y
        translate([pivot_x, pivot_y, -1])
            cylinder(r=pivot_radius, h=base_thickness + 2);
            
        // Right indexing arc holes (22.5°, 45°, 60°) relative to pivot_y
        translate([pivot_x, pivot_y, 0]) {
            for (angle = [22.5, 45, 60]) {
                rotate([0, 0, angle])
                    translate([0, -arc_radius, -1])
                        cylinder(r=pin_radius, h=base_thickness + 2);
            }
        }
        
        // Base plate mounting screw hole 1 (with top countersink)
        translate([pivot_x + 15, pivot_y, -1])
            cylinder(r=screw_radius, h=base_thickness + 2);
        translate([pivot_x + 15, pivot_y, base_thickness - countersink_depth])
            cylinder(r1=screw_radius, r2=countersink_radius, h=countersink_depth + 1);
            
        // Base plate mounting screw hole 2 (with top countersink)
        translate([pivot_x + 30, pivot_y, -1])
            cylinder(r=screw_radius, h=base_thickness + 2);
        translate([pivot_x + 30, pivot_y, base_thickness - countersink_depth])
            cylinder(r1=screw_radius, r2=countersink_radius, h=countersink_depth + 1);
        translate([45, -40, base_thickness - 2])
            linear_extrude(height = 4) 
                text("Right", size = 8, font = "Liberation Sans", halign = "left", valign = "baseline");
        
    }
}

// Left Rotating Arm (Flange extends to the right / +X, with top-countersunk fence screw holes)
module left_rotating_arm() {
    arm_back = pivot_y - arc_radius - 10;
    arm_xmin = -12;
    arm_xmax = 50;
    arm_width = arm_xmax - arm_xmin;

    difference() {
        union() {
            intersection() {
                union() {
                    translate([0, pivot_y, 0])
                        cylinder(r=pivot_radius + 6, h=base_thickness);
                    translate([arm_xmin, arm_back, 0])
                        cube([arm_width, abs(arm_back), base_thickness]);
                }
                translate([arm_xmin - 8, arm_back - 5, -10])
                    cube([arm_width + 16, abs(arm_back) + 5, base_thickness + 20]);
            }
            translate([arm_xmin, -lip_thickness, -lip_depth])
                cube([arm_width, lip_thickness, base_thickness + lip_depth]);
        }
        translate([0, pivot_y, -1])
            cylinder(r=pivot_radius, h=base_thickness + 2);
        translate([0, pivot_y, 0])
            translate([0, -arc_radius, -1])
                cylinder(r=pin_radius, h=base_thickness + 2);
                
        // Fence mounting screw hole 1 (with top countersink)
        translate([20, pivot_y, -1])
            cylinder(r=screw_radius, h=base_thickness + 2);
        translate([20, pivot_y, base_thickness - countersink_depth])
            cylinder(r1=screw_radius, r2=countersink_radius, h=countersink_depth + 1);
            
        // Fence mounting screw hole 2 (with top countersink)
        translate([38, pivot_y, -1])
            cylinder(r=screw_radius, h=base_thickness + 2);
        translate([38, pivot_y, base_thickness - countersink_depth])
            cylinder(r1=screw_radius, r2=countersink_radius, h=countersink_depth + 1);
        // --- BOTTOM ENGRAVED TEXT ("Left") ---
        translate([30, pivot_y - 30, -0.1])
            linear_extrude(height = 2)
                mirror([1, 0, 0])
                    text("Left", size = 8, font = "Liberation Sans", halign = "center", valign = "center");
    }
}

// Right Rotating Arm (Mirrored: Flange extends to the left / -X, with top-countersunk fence screw holes)
module right_rotating_arm() {
    arm_back = pivot_y - arc_radius - 10;
    arm_xmin = -50;
    arm_xmax = 12;
    arm_width = arm_xmax - arm_xmin;

    difference() {
        union() {
            intersection() {
                union() {
                    translate([0, pivot_y, 0])
                        cylinder(r=pivot_radius + 6, h=base_thickness);
                    translate([arm_xmin, arm_back, 0])
                        cube([arm_width, abs(arm_back), base_thickness]);
                }
                translate([arm_xmin - 8, arm_back - 5, -10])
                    cube([arm_width + 16, abs(arm_back) + 5, base_thickness + 20]);
            }
            translate([arm_xmin, -lip_thickness, -lip_depth])
                cube([arm_width, lip_thickness, base_thickness + lip_depth]);
        }
        translate([0, pivot_y, -1])
            cylinder(r=pivot_radius, h=base_thickness + 2);
        translate([0, pivot_y, 0])
            translate([0, -arc_radius, -1])
                cylinder(r=pin_radius, h=base_thickness + 2);
                
        // Fence mounting screw hole 1 (with top countersink)
        translate([-20, pivot_y, -1])
            cylinder(r=screw_radius, h=base_thickness + 2);
        translate([-20, pivot_y, base_thickness - countersink_depth])
            cylinder(r1=screw_radius, r2=countersink_radius, h=countersink_depth + 1);
            
        // Fence mounting screw hole 2 (with top countersink)
        translate([-38, pivot_y, -1])
            cylinder(r=screw_radius, h=base_thickness + 2);
        translate([-38, pivot_y, base_thickness - countersink_depth])
            cylinder(r1=screw_radius, r2=countersink_radius, h=countersink_depth + 1);
        // --- BOTTOM ENGRAVED TEXT ("Right") ---
        translate([-30, pivot_y - 30, -0.1])
            linear_extrude(height = 2)
                mirror([1, 0, 0])
                    text("Right", size = 8, font = "Liberation Sans", halign = "center", valign = "center"); 
    }
}

module index_pin() {
    pin_dia = 5.9;          // Slightly under 6mm for a smooth slip-fit with clearance
    pin_length = 5/8 * inch;// Spans both the base plate and rotating arm (1/4" each)
    head_dia = 16.0;        // Ergonomic top knob diameter for easy handling
    head_height = 4.0;      // Thickness of the thumb grip head
    taper_height = 1.5;     // Tapered tip to easily guide into the hole

    union() {
        // Tapered tip for easy drop-in alignment
        cylinder(d1=pin_dia - 1.5, d2=pin_dia, h=taper_height);
        
        // Main pin shaft
        translate([0, 0, taper_height])
            cylinder(d=pin_dia, h=pin_length - taper_height);
        
        // Top grip head / thumb knob
        translate([0, 0, pin_length])
            cylinder(d=head_dia, h=head_height);
    }
}

// Render pin on the build plate
index_pin();

// Render components clearly separated on the build plate
left_base_plate();

translate([130, 0, 0])
    right_base_plate();

translate([40, -130, 0])
    left_rotating_arm();

translate([160, -130, 0])
    right_rotating_arm();

// Render pin on the build plate
index_pin([0,0,0]);
