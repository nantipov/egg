
/* --- settings --- */
target = "bottom"; /* composition, composition2, bottom, middle, top, massive_top, rack, egg, dev */
release = false;
$fn = release ? 120 : 30;
k = 1.0;

/* egg */
egg_length = 120 * k;
egg_w = 12 * k;
egg_wall_w = 2.5 * k;

/* dividing */
dh1 = 14 * k; // 13
dh2 = egg_length - 13 * k; //13

/* deltas */
bottom_solid_plate_h = 9;//7
rack_level_delta = bottom_solid_plate_h - 2 * k;
rack_depth_delta = -5 * k;
/* --- settings --- */



/* --- main --- */
main();
/* --- main --- */



module main() {
    if (target == "composition" || target == "composition2") {
        
        edge_wall_rotate_vec = target == "composition" ? [0, 0, 0] : [0, 0, 90];
        
        difference() {
            union() {
                color("orange")
                egg_bottom();
                
                /*
                color("cyan")
                egg_middle();
                
                color("orange")
                egg_top();
                */
                
                color("orange")
                egg_massive_top();
            }
            
            rotate(edge_wall_rotate_vec)
            translate([-100/2, 0, -120/2])
            cube([100, 70, 120]);
        }
        translate([0, rack_depth_delta, -egg_length/2 + rack_level_delta])
        board_rack();
    }
    
    if (target == "bottom") {
        rotate([0, 180, 0])
        egg_bottom();
    }
    
    if (target == "middle") {
        egg_middle();
    }
    
    if (target == "massive_top") {
        egg_massive_top();
    }
    
    if (target == "top") {
        egg_top();
    }
    
    if (target == "rack") {
        rotate([90, 0, 0])
        board_rack();
    }
    
    if (target == "egg") {
        egg(length = egg_length - egg_wall_w);
    }
    
    if (target == "dev") {
        //charger_board(with_extension=true);
        egg_bottom();
        
        
        translate([0, rack_depth_delta, -egg_length/2 + rack_level_delta])
        board_rack();
        
        //egg_top();
        //egg_middle();
    }
}

module egg_bottom() {
    //screw_positions_degree = [90, -90];
    //dh1_r = egg_eq(dh1 - egg_length/2, egg_length);
    charger_card_h = dh1 - 7*k;//bottom_solid_plate_h;
    charger_card_h_r = egg_eq(charger_card_h - egg_length/2, egg_length);
    charger_board_rotation_vector = [45, 0, 180];
    
    if (!release) {
        %
        translate([0, charger_card_h_r, -egg_length / 2 + charger_card_h])
        rotate(charger_board_rotation_vector)
        charger_board(with_extension=false);            
    }
    
    // egg bottom part
    difference() {
        egg(length = egg_length, end = dh1);
        
        // cut inner
        inner_egg();
        
        // cut screw hole
        /*
        union() {
            for (pos_d = screw_positions_degree) {
                rotate([0, 0, pos_d])
                translate([dh1_r, 0, -egg_length / 2])
                screw_component(screw_part_diff=true);
            }
        }
        */
        
        // cut rack nest in case it might touch the walls
        translate([0, rack_depth_delta, -egg_length/2 + rack_level_delta])
        board_rack(show_dev_board=false, stand_k=1.2);
        
        // cut charger card
        translate([0, charger_card_h_r, -egg_length / 2 + charger_card_h])
        rotate(charger_board_rotation_vector)
        charger_board(with_extension=true);
    }
    
    // solid bottom
    difference() {
        egg(length = egg_length, end = bottom_solid_plate_h);
        
        // cut rack nest from solid bottom
        translate([0, rack_depth_delta, -egg_length/2 + rack_level_delta])
        board_rack(show_dev_board=false, stand_k=1.2);
        /*
        // cut screw hole
        union() {
            for (pos_d = screw_positions_degree) {
                rotate([0, 0, pos_d])
                translate([dh1_r, 0, -egg_length / 2])
                screw_component(screw_part_diff=true);
            }
        }
        */
        
        // cut charger card
        translate([0, charger_card_h_r, -egg_length / 2 + charger_card_h])
        rotate(charger_board_rotation_vector)
        charger_board(with_extension=true);
    }

    // screw
    /*
    difference() {
        union() {
            for (pos_d = screw_positions_degree) {
                rotate([0, 0, pos_d])
                translate([dh1_r, 0, -egg_length / 2])
                screw_component(screw_part=true);
            }
        }
        
        outer_thick_egg(start = 0, end = dh1);
        // cut screw hole
        union() {
            for (pos_d = screw_positions_degree) {
                rotate([0, 0, pos_d])
                translate([dh1_r, 0, -egg_length / 2])
                screw_component(screw_part_diff=true);
            }
        }
    }
    */

    // connection skirt
    connection_skirt_d = (egg_eq(-(egg_length - egg_wall_w)/2 + dh1, egg_length - egg_wall_w) - 1*k) * 2;
    translate([0, 0, -egg_length/2 + dh1 - 1*k])
    difference() {
        
        cylinder(h = 5*k, d = connection_skirt_d);

        // cut in center
        translate([0, 0, -1])
        cylinder(h = 5*k+2, d = connection_skirt_d - 2*k);

        translate([0, 0, -(-egg_length/2 + dh1 - 1*k)])
        outer_thick_egg(start = 0, end = dh1);
        
        // cut at screw parts
        /*
        union() {
            for (pos_d = screw_positions_degree) {
                rotate([0, 0, pos_d])
                translate([dh1_r, 0, 0])
                screw_component(screw_part=true);
            }
        }
        */
    }
}

module egg_middle() {
    //screw_positions_degree = [90, -90];
    difference() {
        egg(length = egg_length, start = dh1, end = dh2);
        
        inner_egg();
    }
    
    // screw
    /*
    dh1_r = egg_eq(dh1 - egg_length/2, egg_length);
    difference() {
        union() {
            for (pos_d = screw_positions_degree) {
                rotate([0, 0, pos_d])
                translate([dh1_r, 0, -egg_length / 2 + dh1])
                screw_component(thread_insert_part=true);
            }
        }
        
        outer_thick_egg(start = dh1, end = dh2);
    }
    */
}

module egg_massive_top() {
    difference() {
        egg(length = egg_length, start = dh1);
        
        inner_egg();
    }
}


module egg_top() {
    difference() {
        egg(length = egg_length, start = dh2);
        
        inner_egg();
    }
    
    // antenna holder
    h_from_top = 4 * k;
    h_holder = egg_length - dh2 - h_from_top;
    antenna_d = egg_eq(egg_length/2 - h_from_top, egg_length)*2;
    
    translate([0, 0, egg_length/2-h_from_top-h_holder])
    difference() {
        union() {
            cylinder(h = h_holder, d = antenna_d);
            
            // skirt
            //cylinder(h = 1*k, d = antenna_d+3*k);
        }
        
        // cut center
        translate([0, 0, -1])
        cylinder(h = h_holder+3*k, d = antenna_d - 4*k);
    }
    
    // connection skirt
    connection_skirt_d = (egg_eq(-egg_length/2 + dh2, egg_length - egg_wall_w) - 0.5 * k) * 2;
    translate([0, 0, -egg_length/2 + dh2 + 1*k])
    rotate([180, 0, 0])
    difference() {
        cylinder(h = 3*k, d = connection_skirt_d);
        
        // cut in center
        translate([0, 0, -1])
        cylinder(h = 3*k+3, d = connection_skirt_d - 2*k);
        
        // cut on sides
        //translate([-(connection_skirt_d+2)/2, -connection_skirt_d*0.5/2, 0])
        //cube([connection_skirt_d+2, connection_skirt_d*0.5, 2*k+2]);
    }
}

module screw_component(screw_part=false, thread_insert_part=false, screw_part_diff=false) {
    insert_d = 4.4 * k;
    insert_h = 5.7 * k;
    insert_part_h = insert_h + 1 * k;
    bolt_thread_d = 3.8 * k;
    bolt_hat_d = 5.7 * k;
    edge_distance = 7 * k;
    over_edge_spare_w = 4 * k; //8
    
    w = bolt_hat_d * 1.5 + edge_distance;
    l = bolt_hat_d * 2;
    
    if (screw_part) {
        difference() {
            translate([-w, -l/2, 0])
            cube([w + over_edge_spare_w, l, dh1]);
            
            translate([-w + edge_distance - bolt_thread_d/2, 0, 1])
            cylinder(h = dh1 + 2, d = bolt_thread_d);
        }
    }

    if (screw_part_diff) {
        translate([-w + edge_distance - bolt_thread_d/2, 0, 0])
        cylinder(h = dh1 + 2, d = bolt_thread_d);
        
        translate([-w + edge_distance - bolt_thread_d/2, 0, 0])
        cylinder(h = dh1 - 6 * k, d = bolt_hat_d);
    }

    if (thread_insert_part) {
        difference() {
            translate([-w, -l/2, 0])
            cube([w + over_edge_spare_w, l, insert_part_h]);
            
            translate([-w + edge_distance - bolt_thread_d/2, 0, -1])
            cylinder(h = insert_part_h + 2, d = insert_d);
        }
    }
}

module inner_egg() {
    egg(length = egg_length - egg_wall_w);
}

module outer_thick_egg(start, end) {
    thick_length = egg_length + egg_wall_w * 12;
    length_delta = (thick_length - egg_length)/2;
    difference() {
        egg(length = thick_length, start=start + length_delta - 1, end=end + 1 + length_delta);
        
        egg(length = egg_length, start=start, end=end + 1);
    }
}

module egg(length, start=-1000, end=-1000) {
    rotate_extrude()
    translate([0, -length/2, 0])
    rotate([0, 0, 90])
    polygon(egg_half_poly(
        length,
        start == -1000 ? 0 : start,
        end == -1000 ? length : end
    ));
}

function egg_half_poly(length, start, end) =
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


module board_rack(show_dev_board=true, stand_k=1) {
    board_holes_data = board_holes();
    holes_w = board_holes_data[0];
    holes_h = board_holes_data[1];
    hole_d = board_holes_data[2] - 0.5;
    
    rack_t = 3 * k;
    board_t = 2 * k;
    
    rack_w = 39 * k;
    rack_h = holes_h+hole_d;
    
    rack_wi = rack_w-2*hole_d;
    rack_hi = rack_h-2*hole_d;
    rack_round_r = 3 * k;
    
    bottom_stand_h = 8 * k;
    side_stand_base_l = 10 * k;

    // frame
    translate([0, 0, bottom_stand_h])
    difference() {
        hull() {
            translate([-rack_w/2+rack_round_r, 0, rack_round_r])
            rotate([-90, 0, 0])
            cylinder(h = rack_t, r = rack_round_r);
            
            translate([-rack_w/2+rack_round_r, 0, rack_h-rack_round_r])
            rotate([-90, 0, 0])
            cylinder(h = rack_t, r = rack_round_r);
            
            translate([rack_w/2-rack_round_r, 0, rack_h-rack_round_r])
            rotate([-90, 0, 0])
            cylinder(h = rack_t, r = rack_round_r);
            
            translate([rack_w/2-rack_round_r, 0, rack_round_r])
            rotate([-90, 0, 0])
            cylinder(h = rack_t, r = rack_round_r);
        }
        
        // cut middle
        translate([-rack_wi/2, -1, rack_h/2-rack_hi/2])
        cube([rack_wi, rack_t+2, rack_hi]);
        
        // cut top
        translate([-(holes_w - hole_d)/2, -1, rack_h - ((rack_h-rack_hi)/2) - hole_d + 2])
        cube([holes_w - hole_d, rack_t+2, (rack_h-rack_hi)/2 + 2]);
        
        // cut bottom
        translate([-(holes_w - hole_d)/2, -1, -2])
        cube([holes_w - hole_d, rack_t+2, (rack_h-rack_hi)/2 + 2]);
    }
    
    // pins
    translate([-holes_w/2, rack_t, rack_h/2-holes_h/2+bottom_stand_h])
    rotate([-90, 0, 0])
    cylinder(h = board_t + 0.7*k, d = hole_d);
    
    translate([-holes_w/2, rack_t, rack_h/2+holes_h/2+bottom_stand_h])
    rotate([-90, 0, 0])
    cylinder(h = board_t + 0.7*k, d = hole_d);
    
    translate([holes_w/2, rack_t, rack_h/2-holes_h/2+bottom_stand_h])
    rotate([-90, 0, 0])
    cylinder(h = board_t + 0.7*k, d = hole_d);
    
    translate([holes_w/2, rack_t, rack_h/2+holes_h/2+bottom_stand_h])
    rotate([-90, 0, 0])
    cylinder(h = board_t + 0.7*k, d = hole_d);
    
    // bottom stand
    translate([-hole_d/2 - holes_w*stand_k/2, 0, 0])
    union() {
        translate([0, 0, 0])
        cube([hole_d*stand_k, rack_t*stand_k, bottom_stand_h]);
        
        translate([holes_w*stand_k, 0, 0])
        cube([hole_d*stand_k, rack_t*stand_k, bottom_stand_h]);
        
        cube([holes_w*stand_k, rack_t*stand_k, hole_d*stand_k]);
    }

    // side stands
    for (x_mirror = [0, 1]) {
        mirror([x_mirror, 0, 0])
        translate([rack_wi/2+hole_d*stand_k, 0, 0])
        rotate([0, -90, 0])
        linear_extrude(height = hole_d*stand_k)
        difference() {
            polygon([[0, 0], [(side_stand_base_l + rack_t)*stand_k, 0], [0, (side_stand_base_l + rack_t)*stand_k], [0, 0]]);
        }
    }

    // show board in no-release (dev) mode
    if (show_dev_board && !release) {
        %
        translate([0, rack_t, rack_h/2 + bottom_stand_h])
        board();
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

module charger_board(with_extension=false) {
    l = 28 * k + 0.5 * k;
    w = 17 * k + 0.5 * k;
    h = 3 * k + 0.5 * k;
    lc = 7.4 * k + 0.5 * k;
    wc = 9 * k + 0.5 * k;
    hbc = 4.82 * k; 
    lc_delta = 1.5 * k;
    hc_delta = 1.48 * k;
    hc = hbc - hc_delta;
    
    h_with_extension = with_extension ? hbc : h;
    lc_with_extension = with_extension ? lc + 50 : lc;
    wc_with_extension = with_extension ? wc/*10.51*k*/ : wc;
    hc_with_extension = with_extension ? hc/*5.77*k + 0.5*k*/ : hc;
    
    // board
    translate([-w/2, lc_delta, -hc_delta])
    cube([w, l, h_with_extension]);
    
    // connector
    translate([-wc_with_extension/2,  - lc_with_extension + lc, 0])
    cube([wc_with_extension, lc_with_extension, hc_with_extension]);
}

function arc_oval_points(center_x, center_y, r1, r2, a0, a1) =
  [for (a=[a0:(a1-a0)/100:a1]) [center_x + cos(a) * r1, center_y + sin(a) * r2]];

function arc_points(center_x, center_y, r, a0, a1) =
  arc_oval_points(center_x, center_y, r, r, a0, a1);
