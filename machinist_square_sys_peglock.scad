// 1. Set rendering quality
$fn = 60;

// 2. Define clearance parameters (in mm)
extra_width = 0.5; // How much wider to make the slot
extra_depth = 1.0; // Extra length to ensure it cuts through completely

difference() {
    // Import the downloaded STL file
    import("machinist-square-holder.stl");


    q// Position and size the cutting volume (Negative Volume)
    // Adjust these X, Y, Z translation coordinates to align with your model's slot
    translate([10, -0.25, 5]) 
        cube([25 + extra_depth, 1.5 + extra_width, 10]);
}
