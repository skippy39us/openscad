// Framework Laptop Stand
//     A parametric stand to hold multiple laptops with custom slot thicknesses.
//
// Copyright 2023 Framework Computer Inc <https://frame.work>
//     This work is licensed under a Creative Commons Attribution 4.0 
//     International License.

include <MCAD/boxes.scad>;

width = 100;
height = 50;
wall = 5;
end = 15;
r = 15;
$fn = 128;

// Specify slot widths (in mm) for each laptop.
// Add or adjust sizes as needed:
laptop_slots = [17.5, 23, 20];

// Helper function to calculate the starting Y position for each slot
function slot_y(i, v, wall, end) = (i == 0) ? (end + wall) : (slot_y(i - 1, v, wall, end) + v[i - 1] + wall);

num_slots = len(laptop_slots);
total_length = slot_y(num_slots - 1, laptop_slots, wall, end) + laptop_slots[num_slots - 1] + end + wall;

difference() {
    // Rounded cube as the core structure to cut out
    translate([0, 0, -r]) roundedCube([width, total_length, height+r], r, false);
    
    // Make the bottom flat
    translate([0, 0, -r]) cube([width, total_length, r]);
    
    // Cut out each laptop slot with its specific width
    for (i = [0:num_slots-1]) {
        translate([0, slot_y(i, laptop_slots, wall, end), wall]) cube([width, laptop_slots[i], height]);
    }
    
    // Round the ends
    translate([0, 0, wall+r]) rotate([0, 90, 0]) cylinder(h = width, r = r);
    translate([0, 0, wall+r]) cube([width, r, height]);
    translate([0, total_length, wall+r]) rotate([0, 90, 0]) cylinder(h = width, r = r);
    translate([0, total_length - r, wall+r]) cube([width, r, height]);
}
