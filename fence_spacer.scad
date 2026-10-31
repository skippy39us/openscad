// =============================================================================
// Heavy-Duty Parametric Fence Spacer with Internal Ribs
// Parametric inch conventions matching x-degree-clamping-triangle.scad
// =============================================================================

$fn = 128;
inch = 25.4;

// -----------------------------------------------------------------------------
// USER PARAMETERS (Specified in inches or mm using * inch)
// -----------------------------------------------------------------------------
outer_x       = 2.0 * inch;       // Width (~38.1mm nominal 1x2, or 2.0 * inch actual)
outer_y       = 200.0;            // Length along fence (matches 200mm triangle base)
outer_z       = 3/4 * inch;       // Height / thickness (matches 3/4" clamping triangle)

border        = 3/8 * inch;       // Perimeter wall thickness (~9.5mm)
rib_thickness = 1/4 * inch;       // Internal dividing rib thickness (~6.35mm)
num_openings  = 4;                // Number of divided rectangular openings

// -----------------------------------------------------------------------------
// GEOMETRY CALCULATIONS
// -----------------------------------------------------------------------------
inner_x           = outer_x - (2 * border);
total_open_span_y = outer_y - (2 * border);
total_ribs_y      = (num_openings - 1) * rib_thickness;
cutout_y          = (total_open_span_y - total_ribs_y) / num_openings;

// -----------------------------------------------------------------------------
// MAIN MODEL
// -----------------------------------------------------------------------------
difference() {
    // Outer solid block
    cube([outer_x, outer_y, outer_z]);

    // Evenly spaced through-openings
    for (i = [0 : num_openings - 1]) {
        y_pos = border + i * (cutout_y + rib_thickness);
        translate([border, y_pos, -1])
            cube([inner_x, cutout_y, outer_z + 2]);
    }
}
