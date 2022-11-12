/* --- external modules -- */

/* threads library with dependencies */
// https://github.com/adrianschlatter/threadlib
// in the libraries directory
// $ git clone https://github.com/openscad/scad-utils.git
// $ git clone https://github.com/openscad/list-comprehension-demos.git
// $ wget https://raw.githubusercontent.com/MisterHW/IoP-satellite/master/OpenSCAD%20bottle%20threads/thread_profile.scad
//$ git clone https://github.com/adrianschlatter/threadlib.git
use <threadlib/threadlib.scad>

/* --- external modules -- */

/* --- settings --- */
target = "rack"; /* composition, bottom, bottom1, bottom2, top, top1, top2, rack, rack1, rack2, egg, dev */
release = false;
$fn = release ? 120 : 30;
k = 1.0;

/* egg */
egg_length = 110 * k;
egg_w = 12 * k;
egg_wall_w = 5 * k;

/* dividing and bayonet */
egg_dividing_h = 20 * k;

dh1 = 8 * k;
dh2 = egg_length - 14 * k;

bayonet_thread_type = "G2 1/4";
thread_bottom_specs = thread_specs(str(bayonet_thread_type, "-int"));
thread_bottom_specs_ext = thread_specs(str(bayonet_thread_type, "-ext"));
bayonet_thread_turns = 2;
bayonet_d = thread_bottom_specs[2] * k /* D support */;
bayonet_p = thread_bottom_specs_ext[0] * k /* P */;
bayonet_h = (bayonet_thread_turns + 1) * bayonet_p;

/* rack bayonet */
rack_bayonet_thread_type = "G1 3/4";
thread_rack_specs = thread_specs(str(rack_bayonet_thread_type, "-int"));
rack_bayonet_thread_turns = 2;
rack_bayonet_d = thread_rack_specs[2] * k /* D support */;
rack_bayonet_p = thread_rack_specs[0] * k /* P */;
rack_bayonet_h = (rack_bayonet_thread_turns + 1) * rack_bayonet_p;
rack_bayonet_h_delta = -7 * k;
/* --- settings --- */



/* --- main --- */
main();
/* --- main --- */



module main() {
    if (target == "composition") {
        difference() {
            union() {
                color("orange")
                egg_bottom_part();
                
                color("cyan")
                egg_upper_part();
            }

            
            translate([-100/2, 0, -120/2])
            cube([100, 70, 120]);
        }
        board_rack_with_thread();
    }
    
    if (target == "bottom" || target == "bottom1" || target == "bottom2") {
        egg_bottom_part();
    }
    
    if (target == "top" || target == "top1" || target == "top2") {
        //translate([120, 0, 0])
        egg_upper_part();
    }
    
    if (target == "rack" || target == "rack1" || target == "rack2") {
        board_rack_with_thread();
    }
    
    if (target == "egg") {
        egg(length = egg_length - egg_wall_w);
    }
    
    if (target == "dev") {
        egg_bottom_part();
        board_rack_with_thread();
    }
}

module egg_part1() {
    egg(length = egg_length, end = dh1);
}

module egg_part2() {
    egg(length = egg_length, start = dh1, end = dh2);
}

module egg_part3() {
    egg(length = egg_length, start = dh2);
}

module egg_bottom_part() {
    mount_h = 2 * k;
    if (target == "composition" || target == "bottom" || target == "bottom1") {
        // egg part
        difference() {
            egg(length = egg_length, end = egg_dividing_h);
            
            egg(length = egg_length - egg_wall_w, end = egg_dividing_h + mount_h);
        }
    }
    
    if (target == "composition" || target == "bottom" || target == "bottom2") {
        // thread and mounting plate
        mount_lev = -egg_length/2 + egg_dividing_h;
        mount_r = egg_eq(x = egg_dividing_h, length = egg_length);
        mount_hole_r = mount_r * 0.85;
        well_d = bayonet_d - 8*k;
        difference() {
            union() {
                // mount
                egg(length = egg_length, start = egg_dividing_h, end = egg_dividing_h + mount_h);
                
                // bayonet with thread
                translate([0, 0, mount_lev + mount_h + bayonet_p/2])
                bolt(bayonet_thread_type, turns = bayonet_thread_turns, fn=$fn);
            }
            // cut
            translate([0, 0, mount_lev - 1])
            cylinder(h = mount_h + bayonet_h + 2, d = well_d);
        }
        
        // rack mouting thread
        cut_r = egg_eq(x = egg_dividing_h - rack_bayonet_h,  length = egg_length - egg_wall_w);

        translate([0, 0, mount_lev + rack_bayonet_h_delta])
        nut(rack_bayonet_thread_type, turns = rack_bayonet_thread_turns, Douter = well_d, fn=$fn);
        
        
        thread_outer_specs = thread_specs(str(bayonet_thread_type, "-ext"));
        outer_bolt_d = thread_outer_specs[2] * k;
        difference() {
            translate([0, 0, mount_lev + rack_bayonet_h_delta])
            cylinder(h = abs(rack_bayonet_h_delta), d = outer_bolt_d);        
            
            translate([0, 0, mount_lev + rack_bayonet_h_delta - 1])
            cylinder(h = abs(rack_bayonet_h_delta) + 2, d = well_d);
        }
    }
}

module egg_upper_part() {
    mount_h = 2 * k;
    top_div_h = egg_dividing_h + (egg_length - egg_dividing_h)*2/3;
    // egg part
    difference() {
        union() {
            if (target == "composition" || target == "top") {
                egg(length = egg_length, start = egg_dividing_h + mount_h);
            }
            if (target == "top1") {
                egg(length = egg_length, start = egg_dividing_h + mount_h, end = top_div_h);
            }
            if (target == "top2") {
                egg(length = egg_length, start = top_div_h);
            }
        }
        
        egg(length = egg_length - egg_wall_w, start = egg_dividing_h);
    }
    
    if (target == "composition" || target == "top" || target == "top1") {
        // mount
        difference() {
            egg(length = egg_length, start = egg_dividing_h + mount_h, end = egg_dividing_h + 2*mount_h);
            
            translate([0, 0, -egg_length/2 + egg_dividing_h + mount_h - 1])
            cylinder(h = bayonet_h + 2, d = cut_r*2);
        }
        
        cut_r = egg_eq(x = egg_dividing_h + mount_h, length = egg_length)*0.97;
        // nut
        translate([0, 0, -egg_length/2 + egg_dividing_h + bayonet_p / 2 + mount_h])
        nut(bayonet_thread_type, turns = bayonet_thread_turns, Douter = cut_r*2, fn=$fn);
    }
}

/*
module egg_hull(length) {
    steps_quantity = release ? length : 50;
    step = length / steps_quantity;
    for (x0 = [-length/2 : step : length/2+1]) {
        y0 = egg_eq(x0, length);
        
        x1 = x0 + step;
        y1 = egg_eq(x1, length);
        
        hull() {
            translate([0, 0, x0])
            cylinder(h = step/2*k, r = y0);
            
            translate([0, 0, x1])
            cylinder(h = step/2*k, r = y1);
        }
    }
}
*/

module egg(length, start=-1000, end=-1000) {
    rotate_extrude()
    translate([0, -length/2, 0])
    rotate([0, 0, 90])
    polygon(egg_half_polly(
        length,
        start == -1000 ? 0 : start,
        end == -1000 ? length : end
    ));
}

function egg_half_polly(length, start, end) =
    concat(
    [[start, 0]],
        [for (x=[start : (release ? 0.5 : 1) : end]) [x, egg_eq(x - length/2, length)]],
        [[end, 0]]
    );

function egg_eq(x, length) =
    length / 1.25 / 2 * sqrt(
        (length * length - 4 * x * x) /
        (length * length + 8 * egg_w * x + 4 * egg_w * egg_w)
    );

module board_rack_with_thread() {
    if (target == "composition" || target == "rack" || target == "rack1") {
        board_rack();
    }
    if (target == "composition" || target == "rack" || target == "rack2") {
        board_rack_thread();
    }
}

module board_rack(with_cut=true) {
    board_holes_data = board_holes();
    holes_w = board_holes_data[0];
    holes_h = board_holes_data[1];
    hole_d = board_holes_data[2] - 0.5;
    
    rack_t = 3 * k;
    board_t = 2 * k;
    
    rack_w = egg_eq(x=holes_h/2, length=egg_length - egg_wall_w)*0.95*2;
    rack_h = holes_h+hole_d;
    rack_wi = rack_w-2*hole_d;
    rack_hi = rack_h-2*hole_d;
    rack_round_r = 3 * k;
    
    thread_lev = -egg_length/2 + egg_dividing_h + rack_bayonet_h_delta;

    difference() {
        hull() {
            translate([-rack_w/2+rack_round_r, 0, -rack_h/2+rack_round_r])
            rotate([-90, 0, 0])
            cylinder(h = rack_t, r = rack_round_r);
            
            translate([-rack_w/2+rack_round_r, 0, rack_h/2-rack_round_r])
            rotate([-90, 0, 0])
            cylinder(h = rack_t, r = rack_round_r);
            
            translate([rack_w/2-rack_round_r, 0, -rack_h/2+rack_round_r])
            rotate([-90, 0, 0])
            cylinder(h = rack_t, r = rack_round_r);
            
            translate([rack_w/2-rack_round_r, 0, rack_h/2-rack_round_r])
            rotate([-90, 0, 0])
            cylinder(h = rack_t, r = rack_round_r);
        }
        
        if (with_cut) {
            // cut middle
            translate([-rack_wi/2, -1, -rack_hi/2])
            cube([rack_wi, rack_t+2, rack_hi]);
            
            // cut top
            translate([-(holes_w - hole_d)/2, -1, holes_h/2 - hole_d/2 - 1])
            cube([holes_w - hole_d, rack_t+2, (rack_h-rack_hi)/2 + 2]);
            
            // cut bottom
            translate([-(holes_w - hole_d)/2, -1, -(holes_h/2 + hole_d/2 + 1)])
            cube([holes_w - hole_d, rack_t+2, (rack_h-rack_hi)/2 + 2]);
        }        
    }
    
    // pins
    translate([-holes_w/2, rack_t, -holes_h/2])
    rotate([-90, 0, 0])
    cylinder(h = board_t, d = hole_d);
    
    translate([-holes_w/2, rack_t, holes_h/2])
    rotate([-90, 0, 0])
    cylinder(h = board_t, d = hole_d);
    
    translate([holes_w/2, rack_t, -holes_h/2])
    rotate([-90, 0, 0])
    cylinder(h = board_t, d = hole_d);
    
    translate([holes_w/2, rack_t, holes_h/2])
    rotate([-90, 0, 0])
    cylinder(h = board_t, d = hole_d);
    
    // top arc
    translate([0, rack_t, holes_h/2+hole_d/2])
    rotate([180, 0, 0])
    linear_extrude(height=(rack_h-rack_hi)/2)   
    difference() {
        polygon(arc_oval_points(center_x=0, center_y=0, r1=holes_w/2+hole_d/2, r2=15*k, a0=0, a1=180));
        
        polygon(arc_oval_points(center_x=0, center_y=0, r1=holes_w/2-hole_d/2, r2=(15-hole_d)*k, a0=0, a1=180));
    }
    
    // bottom arc
    translate([0, 0, -holes_h/2+hole_d/2])
    rotate([180, 0, 0])
    linear_extrude(height=(rack_h-rack_hi)/2)   
    difference() {
        polygon(arc_oval_points(center_x=0, center_y=0, r1=holes_w/2+hole_d/2, r2=15*k, a0=0, a1=180));
        
        polygon(arc_oval_points(center_x=0, center_y=0, r1=holes_w/2-hole_d/2, r2=(15-hole_d)*k, a0=0, a1=180));
    }

    
    // show board in no-release (dev) mode
    if (!release) {
        %
        translate([0, rack_t, 0])
        board();
    }
}

module board_rack_thread() {
    board_holes_data = board_holes();
    holes_w = board_holes_data[0];
    holes_h = board_holes_data[1];
    hole_d = board_holes_data[2] - 0.5;
    
    rack_t = 3 * k;
    board_t = 2 * k;
    
    rack_w = egg_eq(x=holes_h/2, length=egg_length - egg_wall_w)*0.95*2;
    rack_h = holes_h+hole_d;
    rack_wi = rack_w-2*hole_d;
    rack_hi = rack_h-2*hole_d;
    rack_round_r = 3 * k;
    
    thread_lev = -egg_length/2 + egg_dividing_h + rack_bayonet_h_delta;
    // thread fix
    difference() {
        difference() {
            translate([0, 0, thread_lev])
            bolt(rack_bayonet_thread_type, turns = rack_bayonet_thread_turns, fn=$fn);
            
            translate([0, 0, thread_lev - 2])
            cylinder(h = rack_bayonet_h + 2, d = rack_wi);
        }
        
        board_rack(with_cut=false);
    }
}

module board() {
    w = 32 * k;
    h = 87 * k;
    t = 2 * k;
    
    board_holes_data = board_holes();
    holes_w = board_holes_data[0];
    holes_h = board_holes_data[1];
    hole_d = board_holes_data[2];

    difference() {
        translate([-w/2, 0, -h/2])
        cube([w, t, h]);
     
        // cut holes
        translate([-holes_w/2, -1, -holes_h/2])
        rotate([-90, 0, 0])
        cylinder(h = t + 2, d = hole_d);
        
        translate([-holes_w/2, -1, holes_h/2])
        rotate([-90, 0, 0])
        cylinder(h = t + 2, d = hole_d);
        
        translate([holes_w/2, -1, -holes_h/2])
        rotate([-90, 0, 0])
        cylinder(h = t + 2, d = hole_d);
        
        translate([holes_w/2, -1, holes_h/2])
        rotate([-90, 0, 0])
        cylinder(h = t + 2, d = hole_d);
    }
    
    translate([-holes_w/2 - 4, t, -holes_h/2+8])
    cube([10, 3, 10]);
}

//[holes_w, holes_h, hole_d];
function board_holes() = [27 * k, 82.5 * k, 3 * k];

function arc_oval_points(center_x, center_y, r1, r2, a0, a1) =
  [for (a=[a0:(a1-a0)/100:a1]) [center_x + cos(a) * r1, center_y + sin(a) * r2]];

function arc_points(center_x, center_y, r, a0, a1) =
  arc_oval_points(center_x, center_y, r, r, a0, a1);
