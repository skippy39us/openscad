// Fully Parametric Miter Indexing Triangle for RAS Fence with Ladder Ribs & Truss Bracing
// Matching heavy-duty rib conventions from fence_spacer.scad
// Optimized for Flashforge Adventurer 5M (Max bed size 220x220mm)

$fn = 128; 
inch = 25.4;

// ==========================================
// --- USER CONFIGURABLE ANGLE ---
// ==========================================
input_angle = 22.5; // Try any angle (e.g., 11.5, 15, 22.5, 30, 45, 60, etc.)

// --- BED-FIT & GEOMETRY LOGIC ---
is_flipped = (input_angle > 45.0);
effective_angle = is_flipped ? (90.0 - input_angle) : input_angle;

base_length = 200.0;                              // Max leg along the fence (X-axis)
leg_height  = base_length * tan(effective_angle); // Height along blade line (Y-axis)

// --- EXACT LABEL MAPPING ---
angle_x = is_flipped ? (90.0 - input_angle) : input_angle; 
angle_y = is_flipped ? input_angle : (90.0 - input_angle);

// --- PARAMETRIC DIMENSIONS (matching fence_spacer.scad) ---
thickness       = 3/4 * inch; // 19.05mm (3/4 inch thick)
border          = 3/8 * inch; // ~9.525mm perimeter wall
rib_thickness   = 1/4 * inch; // ~6.35mm dividing ribs
pocket_corner_r = 3.0;        // 3.0mm fillet on pocket corners for strength & printability

// Hypotenuse inner offset (perpendicular distance = border)
hyp_offset_y = border / cos(effective_angle);
function y_top(x) = leg_height * (1.0 - x / base_length) - hyp_offset_y;

// --- PARAMETRIC BAY CALCULATIONS ---
min_bay_h    = 18.0; // Minimum vertical opening needed for clamp pad insertion
corner_block = 22.0; // Solid gusset at 90° corner for indexing stability and label placement
x_min        = corner_block;

req_y = min_bay_h + hyp_offset_y + border;
x_max = (req_y >= leg_height) ? x_min : base_length * (1.0 - req_y / leg_height);
span  = max(0, x_max - x_min);

target_bay_w = 38.0; // ~1.5 inches target pocket width matching clamp pads
num_bays     = (span < 15.0) ? 0 : max(1, round((span + rib_thickness) / (target_bay_w + rib_thickness)));
bay_w        = (num_bays == 0) ? 0 : (span - (num_bays - 1) * rib_thickness) / num_bays;

// Engraving depths and cut extrusion height
engrave_depth = 0.6;
cut_height    = 1.2;

// --- FONT SIZING & POSITIONS ---
font_size_90 = max(5.0, min(7.5, effective_angle * 0.35));
ref_90       = [11.0, 11.0];

fence_font_size = min(3.8, max(2.6, border * 0.38));
fence_x_pos     = (num_bays > 0) ? (x_min + bay_w / 2.0) : 35.0;

tip_x           = min(base_length - 25.0, max(x_max + 14.0, (x_max + base_length) / 2.0));
h_at_tip_x      = leg_height * (1.0 - tip_x / base_length);
tip_y           = min(10.0, h_at_tip_x / 2.0);
font_size_tip_x = min(6.0, max(4.0, h_at_tip_x * 0.28));

tip_y_val                = min(leg_height - 12.0, max(28.0, leg_height * 0.75));
has_vertical_fence_label = (leg_height > 60.0);

// --- 2D POCKET MODULE ---
module pocket_polygon(pts) {
    offset(r = pocket_corner_r)
        offset(delta = -pocket_corner_r)
            polygon(pts);
}

// Extrude each pocket individually in 3D (matching fence_spacer.scad)
// to ensure clean depth-peeling and solid walls in both F5 Preview and F6 Render
module all_pockets_3d() {
    if (num_bays > 0) {
        for (i = [0 : num_bays - 1]) {
            bx0 = x_min + i * (bay_w + rib_thickness);
            bx1 = bx0 + bay_w;
            x_mid = (bx0 + bx1) / 2;
            
            yt0 = y_top(bx0);
            yt1 = y_top(bx1);
            yt_mid = y_top(x_mid);
            bay_h = yt_mid - border;
            
            // Subdivide bays taller than 65mm with horizontal cross-ribs (truss)
            num_divs = max(1, round(bay_h / 65.0));
            div_h = (bay_h - (num_divs - 1) * rib_thickness) / num_divs;
            
            for (d = [0 : num_divs - 1]) {
                py0 = border + d * (div_h + rib_thickness);
                translate([0, 0, -1])
                    linear_extrude(height = thickness + 2, convexity = 10) {
                        if (d == num_divs - 1) {
                            // Top pocket bounded by hypotenuse
                            pocket_polygon([
                                [bx0, py0],
                                [bx1, py0],
                                [bx1, yt1],
                                [bx0, yt0]
                            ]);
                        } else {
                            // Lower rectangular pocket
                            py1 = py0 + div_h;
                            pocket_polygon([
                                [bx0, py0],
                                [bx1, py0],
                                [bx1, py1],
                                [bx0, py1]
                            ]);
                        }
                    }
            }
        }
    }
}

module miter_triangle() {
    difference() {
        // Main right triangle block
        linear_extrude(height = thickness, convexity = 10)
            polygon(points=[
                [0, 0],               // Origin (Inner 90-degree corner against fence)
                [base_length, 0],     // Along the fence (X-axis)
                [0, leg_height]       // Along the blade line (Y-axis)
            ]);
            
        // ==========================================
        // --- THROUGH-POCKET CUTOUTS ---
        // ==========================================
        all_pockets_3d();
                
        // ==========================================
        // --- TOP SURFACE ENGRAVINGS (Z = thickness - engrave_depth) ---
        // ==========================================
        
        // 1. "90" corner
        translate([ref_90[0], ref_90[1], thickness - engrave_depth])
            linear_extrude(height = cut_height)
                text("90", size = font_size_90, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
                
        // 2. Primary "FENCE" label along X-axis border
        translate([fence_x_pos, border / 2.0, thickness - engrave_depth])
            linear_extrude(height = cut_height)
                text("FENCE", size = fence_font_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
                
        // 3. Perpendicular "FENCE" label along Y-axis border (if height allows)
        if (has_vertical_fence_label) {
            translate([border / 2.0, min(42.0, leg_height * 0.45), thickness - engrave_depth])
                rotate([0, 0, 270])
                    linear_extrude(height = cut_height)
                        text("FENCE", size = fence_font_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
        }
        
        // 4. X-axis Tip Label
        translate([tip_x, tip_y, thickness - engrave_depth])
            linear_extrude(height = cut_height)
                text(str(angle_x), size = font_size_tip_x, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
                
        // 5. Y-axis Tip Label
        translate([border / 2.0, tip_y_val, thickness - engrave_depth])
            rotate([0, 0, 270])
                linear_extrude(height = cut_height)
                    text(str(angle_y), size = fence_font_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");

        // ==========================================
        // --- BOTTOM SURFACE ENGRAVINGS (Z = -0.1) ---
        // ==========================================
        
        // 1. "90" corner (bottom)
        translate([ref_90[0], ref_90[1], -0.1])
            scale([-1, 1, 1])
                linear_extrude(height = cut_height)
                    text("90", size = font_size_90, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
                    
        // 2. Primary "FENCE" label along X-axis border (bottom)
        translate([fence_x_pos, border / 2.0, -0.1])
            scale([-1, 1, 1])
                linear_extrude(height = cut_height)
                    text("FENCE", size = fence_font_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
                    
        // 3. Perpendicular "FENCE" label along Y-axis border (bottom)
        if (has_vertical_fence_label) {
            translate([border / 2.0, min(42.0, leg_height * 0.45), -0.1])
                rotate([0, 0, 270])
                    scale([-1, 1, 1])
                        linear_extrude(height = cut_height)
                            text("FENCE", size = fence_font_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
        }
        
        // 4. X-axis Tip Label (bottom)
        translate([tip_x, tip_y, -0.1])
            scale([-1, 1, 1])
                linear_extrude(height = cut_height)
                    text(str(angle_x), size = font_size_tip_x, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
                    
        // 5. Y-axis Tip Label (bottom)
        translate([border / 2.0, tip_y_val, -0.1])
            rotate([0, 0, 270])
                scale([-1, 1, 1])
                    linear_extrude(height = cut_height)
                        text(str(angle_y), size = fence_font_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
    }
}

// Render on build plate
miter_triangle();
