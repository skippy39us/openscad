// Fully Parametric Miter Indexing Triangle for RAS Fence with Conditional Dual D-Holes & Labels
// Optimized for Flashforge Adventurer 5M (Max bed size 220x220mm)

$fn = 128; 
inch = 25.4;

// ==========================================
// --- USER CONFIGURABLE ANGLE ---
// ==========================================
input_angle = 22.5; // Try any angle (e.g., 11.5, 22.5, 30, 45, 60, etc.)

// --- BED-FIT & GEOMETRY LOGIC ---
is_flipped = (input_angle > 45.0);
effective_angle = is_flipped ? (90.0 - input_angle) : input_angle;

base_length = 200.0;                          // Max leg along the fence (X-axis)
leg_height  = base_length * tan(effective_angle); // Height along Y-axis

// --- EXACT LABEL MAPPING ---
angle_x = is_flipped ? (90.0 - input_angle) : input_angle; 
angle_y = is_flipped ? input_angle : (90.0 - input_angle);

// Parameters
thickness = 3/4 * inch; // 19.05mm (3/4 inch thick)

// --- PROPORTIONAL D-HOLE SIZING ---
hole_radius = min(20.0, max(10.0, leg_height * 0.38)); 
flat_offset = 7.0;

// --- AUTOMATIC SAFETY GUARDS FOR CONDITIONAL HOLE 2 ---
include_hole1 = true;
include_hole2 = (leg_height > 65.0) && (effective_angle > 18.0);

// Hole 1: X-axis fence orientation
hole1_x = include_hole2 ? 75.0 : 48.0;
hole1_y = min(20.5, leg_height * 0.32);

// Hole 2: Perpendicular Y-axis fence orientation
hole2_x = 32.0;
hole2_y = min(42.0, leg_height * 0.55);

// --- CRISP, LEGIBLE FONT SIZING FOR CORNERS ---
font_size = max(4.5, min(6.5, effective_angle * 0.45));

// --- SAFE FENCE BRIDGE POSITIONING & FONT SCALING (HOLE 1) ---
d_hole_bottom_y = hole1_y - (hole_radius - flat_offset);
fence_font_size = min(3.5, max(1.8, d_hole_bottom_y * 0.55));
fence_label_y = max(fence_font_size * 0.75, d_hole_bottom_y / 2.0);

// --- PERPENDICULAR BRIDGE POSITIONING & FONT SCALING (HOLE 2) ---
d_hole_left_x = hole2_x - (hole_radius - flat_offset);
fence_font_size_2 = 2.2; 
fence_label_x_2 = max(fence_font_size_2 * 0.75, d_hole_left_x / 2.0);

// ==========================================
// --- REFERENCE POSITIONS FOR TEXT ---
// ==========================================
ref_90 = [12.0, 12.0];
ref_x_tip = [min(base_length * 0.82, max(110.0, base_length * 0.55)), 12.0];
ref_y_tip = [12.0, min(leg_height * 0.85, max(40.0, leg_height * 0.65))];

// Engraving depths and cut extrusion height
engrave_depth = 0.6;
cut_height = 1.5;

module miter_triangle() {
    difference() {
        union() {
            // Main right triangle block with dynamic bed-safe dimensions
            linear_extrude(height = thickness)
                polygon(points=[
                    [0, 0],               // Origin (Inner 90-degree corner against fence)
                    [base_length, 0],     // Along the fence (X-axis)
                    [0, leg_height]       // Along the saw path/blade line (Y-axis)
                ]);
        }
        
        // ==========================================
        // --- CLAMPING HOLES ---
        // ==========================================
        
        // 1. D-Hole 1 (X-axis fence)
        if (include_hole1) {
            translate([hole1_x, hole1_y, -1]) {
                difference() {
                    cylinder(r = hole_radius, h = thickness + 2);
                    translate([-hole_radius - 5, -hole_radius - 20, -1])
                        cube([hole_radius * 2 + 10, 20 + (hole_radius - flat_offset), thickness + 4]);
                    translate([-hole_radius - 5, hole_radius * 0.3, -1])
                        cube([hole_radius * 2 + 10, hole_radius * 2, thickness + 4]);
                }
            }
        }
        
        // 2. D-Hole 2 (Y-axis fence - Conditional)
        if (include_hole2) {
            translate([hole2_x, hole2_y, -1]) {
                rotate([0, 0, 90]) { 
                    difference() {
                        cylinder(r = hole_radius, h = thickness + 2);
                        translate([-hole_radius - 5, -hole_radius - 20, -1])
                            cube([hole_radius * 2 + 10, 20 + (hole_radius - flat_offset), thickness + 4]);
                        translate([-hole_radius - 5, hole_radius * 0.3, -1])
                            cube([hole_radius * 2 + 10, hole_radius * 2, thickness + 4]);
                    }
                }
            }
        }
        
        // ==========================================
        // --- TOP SURFACE ENGRAVINGS (Z = thickness - 0.6) ---
        // ==========================================
        
        // 1. "FENCE" label for Hole 1 (top)
        if (include_hole1) {
            translate([hole1_x, fence_label_y, thickness - engrave_depth])
                linear_extrude(height = cut_height)
                    text("FENCE", size = fence_font_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
        }
        
        // 2. Perpendicular "FENCE" label for Hole 2 (top - rotated 270 degrees to face the opposite way)
        if (include_hole2) {
            translate([fence_label_x_2, hole2_y, thickness - engrave_depth])
                rotate([0, 0, 270])
                    linear_extrude(height = cut_height)
                        text("FENCE", size = fence_font_size_2, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
        }
                
        // 3. "90" (top)
        translate(ref_90)
            translate([0, 0, thickness - engrave_depth])
                linear_extrude(height = cut_height)
                    text("90", size = font_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
                
        // 4. X-axis Tip Label (top)
        translate(ref_x_tip)
            translate([0, 0, thickness - engrave_depth])
                linear_extrude(height = cut_height)
                    text(str(angle_x), size = font_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");

        // 5. Y-axis Tip Label (top)
        translate(ref_y_tip)
            translate([0, 0, thickness - engrave_depth])
                linear_extrude(height = cut_height)
                    text(str(angle_y), size = font_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");

        // ==========================================
        // --- BOTTOM SURFACE ENGRAVINGS (Z = -0.1) ---
        // ==========================================
        
        // 1. "FENCE" label for Hole 1 (bottom)
        if (include_hole1) {
            translate([hole1_x, fence_label_y, -0.1])
                scale([-1, 1, 1])
                    linear_extrude(height = cut_height)
                        text("FENCE", size = fence_font_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
        }
        
        // 2. Perpendicular "FENCE" label for Hole 2 (bottom)
        if (include_hole2) {
            translate([fence_label_x_2, hole2_y, -0.1])
                rotate([0, 0, 270])
                    scale([-1, 1, 1])
                        linear_extrude(height = cut_height)
                            text("FENCE", size = fence_font_size_2, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
        }
                
        // 3. "90" (bottom)
        translate(ref_90)
            translate([0, 0, -0.1])
                scale([-1, 1, 1])
                    linear_extrude(height = cut_height)
                        text("90", size = font_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
                
        // 4. X-axis Tip Label (bottom)
        translate(ref_x_tip)
            translate([0, 0, -0.1])
                scale([-1, 1, 1])
                    linear_extrude(height = cut_height)
                        text(str(angle_x), size = font_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");

        // 5. Y-axis Tip Label (bottom)
        translate(ref_y_tip)
            translate([0, 0, -0.1])
                scale([-1, 1, 1])
                    linear_extrude(height = cut_height)
                        text(str(angle_y), size = font_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
    }
}

// Render on the build plate
miter_triangle();