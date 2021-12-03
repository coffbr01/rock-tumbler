// Number of sides on curves. Higher number is smoother. Don't do more than 500 unless you enjoy killing computers.
$fn = 250;

/* [Rendering] */
// 1 to render the cap, 0 to omit it
render_cap = 1;
// 1 to render the barrel, 0 to omit it
render_barrel = 1;
// 1 to render the barrel peg, 0 to omit it
render_barrel_peg = 1;
// 1 to render the cap peg, 0 to omit it
render_cap_peg = 1;

/* [Barrel (in mm)] */
// Outer Radius
barrel_outer_radius = 42.25;
// Thickness
barrel_thickness = 2;
// Height, as measured from the outside
barrel_height = 73.25;
// Radius of the ridges inside the barrel
barrel_ridge_radius = 5;
// Height of the ridges inside the barrel
barrel_ridge_height = 50;

/* [Cap (in mm)] */
// Height of the smaller part of the cap
cap_lower_height = 18;
// Height of the larger part of the cap
cap_upper_height = 7;
// How much larger (radius) the larger part of the cap is than the barrel
cap_upper_overhang = 10.75;

/* [Pegs (in mm)] */
// Radius of the pegs
peg_radius = 3;
// How deep the pegs are inserted
peg_inset_depth = 10;
// The amount that the peg will stick out of the barrel
barrel_peg_height = 17;
// The amount that the peg will stick out of the cap
cap_peg_height = 14;

// calculated convenience variables
barrel_inner_radius = barrel_outer_radius - barrel_thickness;
barrel_inner_height = barrel_height - barrel_thickness;
cap_upper_radius = barrel_outer_radius + cap_upper_overhang;

module barrel_cap() {
    // larger radius part of the cap, top part
    difference() {
        cylinder(h=cap_upper_height, r=cap_upper_radius);
        cylinder(h=cap_upper_height, r=peg_radius);
    }
    // smaller radius part of the cap, the one that surrounds the barrel
    translate([0, 0, cap_upper_height]) {
        difference() {
            cylinder(h=cap_lower_height, r=barrel_outer_radius + barrel_thickness);
            cylinder(h=cap_lower_height, r=barrel_outer_radius);
        }
    }
    // peg inset
    peg_inset();
}

module peg(h) {
    cylinder(h, r=peg_radius);
}

module peg_inset() {
    difference() {
        // peg inset outer wall (inside the barrel)
        cylinder(h=peg_inset_depth + barrel_thickness, r=peg_radius + barrel_thickness);
        // peg inset inner wall (outside the barrel)
        cylinder(h=peg_inset_depth, r=peg_radius);
    }
}

module barrel_ridge(x, y) {
    // move ridge to the edge of the barrel, and above the bottom wall
    translate([x, y, barrel_thickness]) {
        intersection() {
            // core ridge
            cylinder(h=barrel_ridge_height, r=barrel_ridge_radius);
            // cut ridge in half, with contour of barrel inside radius
            translate([-x, -y, 0]) {
                cylinder(h=barrel_ridge_height, r=barrel_inner_radius);
            }
        }
    }
}

module barrel() {
    // core barrel
    difference() {
        // outside
        cylinder(h=barrel_height, r=barrel_outer_radius);    
        // inside
        translate([0, 0, barrel_thickness]) {
            cylinder(h=barrel_inner_height, r=barrel_inner_radius);
        }
        // peg inset initial cut
        cylinder(h=barrel_thickness, r=peg_radius);
    }
    // peg inset
    peg_inset();
    // inside ridges
    barrel_ridge(barrel_inner_radius, 0);
    barrel_ridge(-barrel_inner_radius, 0);
    barrel_ridge(0, barrel_inner_radius);
    barrel_ridge(0, -barrel_inner_radius);
}

// render barrel
if (render_barrel) {
    barrel();
}

// render pegs
if (render_barrel_peg) {
    translate([-barrel_outer_radius - 10, 5, 0]) {
        peg(barrel_peg_height + peg_inset_depth);
    }
}
if (render_cap_peg) {
    translate([-barrel_outer_radius - 10, -5, 0]) {
        peg(cap_peg_height + peg_inset_depth);
    }
}

// render cap
if (render_cap) {
    translate([barrel_outer_radius + cap_upper_radius + 10, 0, 0]) {
        barrel_cap();
    }
}