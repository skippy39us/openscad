// Heavy-Duty 45-Degree Indexing Triangle for RAS Fence
// Optimized for Flashforge Adventurer 5M (Max leg size ~200mm)

$fn = 128; 
inch = 25.4;

// Parameters
leg_length = 200.0;     // 200mm legs (fits safely on the 220x220mm AD5M bed)
thickness = 3/4 * inch; // 19.05mm (3/4 inch thick for rigid clamping purchase)

// D-Hole Dimensions (25mm radius = 50mm diameter)
hole_radius = 25.0;     
flat_offset = 8.0;      // Flat side offset

// Hole center coordinates
hole_x = 65.0;
hole_y = 40.0;

// Engraving depth (0.6mm deep) and extrusion height for difference cut
engrave_depth = 0.6;
cut_height = 1.0;

module miter_triangle() {
    difference() {
        union() {
            // Main 45-degree right triangle block (3/4" thick)
            linear_extrude(height = thickness)
                polygon(points=[
                    [0, 0],               // Origin (Inner 90-degree corner against fence)
                    [leg_length, 0],      // Along the fence (X-axis)
                    [0, leg_length]       // Along the saw path/blade line (Y-axis)
                ]);
        }
        
        // --- D-SHAPED CLAMPING HOLE ---
        translate([hole_x, hole_y, -1]) {
            difference() {
                // Round body of the hole
                cylinder(r = hole_radius, h = thickness + 2);
                
                // Block that cuts off the bottom to form the flat D-side (parallel to X-axis / fence)
                translate([-hole_radius - 5, -hole_radius - 20, -1])
                    cube([hole_radius * 2 + 10, 20 + (hole_radius - flat_offset), thickness + 4]);
            }
        }
        
        // ==========================================
        // --- TOP SURFACE ENGRAVINGS (Z = thickness - 0.6) ---
        // ==========================================
        
        // 1. "FENCE" label (UNCHANGED)
        translate([hole_x, (hole_y - flat_offset) / 2, thickness - engrave_depth])
            linear_extrude(height = cut_height)
                text("FENCE", size = 6.0, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
                
        // 2. "90" at the 90-degree corner (UNCHANGED)
        translate([18, 18, thickness - engrave_depth])
            linear_extrude(height = cut_height)
                text("90", size = 8.0, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
                
        // 3. Bottom-Left "45" (Aligned with Y = 18, pushed further out to X = 150)
        translate([150, 18, thickness - engrave_depth])
            linear_extrude(height = cut_height)
                text("45", size = 8.0, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");

        // 4. Top "45" (Aligned with X = 18, pushed further out to Y = 150)
        translate([18, 150, thickness - engrave_depth])
            linear_extrude(height = cut_height)
                text("45", size = 8.0, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");

        // ==========================================
        // --- BOTTOM SURFACE ENGRAVINGS (Z = -0.4) ---
        // (Scaled horizontally by -1 to un-mirror when viewed from below)
        // ==========================================
        
        // 1. "FENCE" label (bottom - UNCHANGED)
        translate([hole_x, (hole_y - flat_offset) / 2, -engrave_depth])
            scale([-1, 1, 1])
                linear_extrude(height = cut_height)
                    text("FENCE", size = 6.0, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
                
        // 2. "90" at the 90-degree corner (bottom - UNCHANGED)
        translate([18, 18, -engrave_depth])
            scale([-1, 1, 1])
                linear_extrude(height = cut_height)
                    text("90", size = 8.0, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
                
        // 3. Bottom-Left "45" (bottom - aligned with Y = 18, X = 150)
        translate([150, 18, -engrave_depth])
            scale([-1, 1, 1])
                linear_extrude(height = cut_height)
                    text("45", size = 8.0, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");

        // 4. Top "45" (bottom - aligned with X = 18, Y = 150)
        translate([18, 150, -engrave_depth])
            scale([-1, 1, 1])
                linear_extrude(height = cut_height)
                    text("45", size = 8.0, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
    }
}

// Render on the build plate
miter_triangle();