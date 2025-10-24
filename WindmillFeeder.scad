// units are mm
$fn = 200;
include <BOSL2/std.scad>
include <BOSL2/gears.scad>

print_preview = true;

tape_width = 8;
tape_hole_spacing = 4;
tape_hole_diameter = 1.5;
tape_hole_offset = 0.75;
tape_hole_depth = 1;
tape_holes_per_rotation = 12;
tape_hole_tolerance = 0.20;
tape_thickness = 1;
tape_trough_depth = 1;
wall_width = 2;

axle_diameter = 5;
washer_diameter = 9;
peg_diameter = 3;

rotation_tolerance = 0.05;      // fractional "play"
friction_fit_tolerance = 0.01;  // fractional "play"


function tolerate(x,tolerance) = x*(1-tolerance);
advance_wheel_radius = tape_holes_per_rotation*4*1.07/2/PI-tape_hole_depth;


// every model is described such that the object is oruiented as it would be printed, centered on the z-axis, with the bottom resting on the x-y plane


module axle(length,location=[0,0,0], rotation=[0,0,0]){
    translate(location)
        rotate(rotation)
            translate([0,0,length/2])
                difference(){
                    cylinder(h=length,r=tolerate(axle_diameter/2,rotation_tolerance), center=true);
                    cylinder(h=length*2,r=tolerate(peg_diameter/2, friction_fit_tolerance), center=true);
                }
    
}

module axle_washer(width,location=[0,0,0], rotation=[0,0,0]){
    translate(location){
        rotate(rotation){
            translate([0,0,width/2])
                difference(){
                    cylinder(h=width,r=washer_diameter/2, center=true);
                    cylinder(h=width*2,r=tolerate(axle_diameter/2,rotation_tolerance), center=true);;
                }
        }
    }
}
//module axle_cap(location=[0,0,0], rotation=[0,0,0]){
//    translate(location){
//        rotate(rotation){
//    translate([0,0,tape_hole_offset]){
//    difference(){
//        cylinder(h=2*tape_hole_offset,r=axle_diameter/2*.999,center=true);
//        axle(2.05*tape_hole_offset);
//    }
//    translate([0,0,-tape_hole_offset/2])
//        cylinder(h=tape_hole_offset,r=axle_diameter/2*1.5,center=true);
//}}}}
module half_tape_advance_wheel(location=[0,0,0], rotation=[0,0,0]){
    translate(location){
        rotate(rotation){
            r = advance_wheel_radius;
            difference(){
                union(){
                    cylinder(r=r, h=tape_hole_offset*2, center=true);
                        for(i=[0:tape_holes_per_rotation-1])
                            rotate(a=360/tape_holes_per_rotation*i,v=[0,0,1]){
                                translate([r+tolerate(tape_hole_depth/2,tape_hole_tolerance),0,0]){
                                    rotate([0,90,0])
                                        cylinder(r1=tolerate(tape_hole_diameter/2,tape_hole_tolerance), r2=tolerate(0.8*tape_hole_diameter/2,tape_hole_tolerance), h=tape_hole_depth, center=true);
                }
            }
        }
        translate([0, 0, -2*r])
            cube(4*r, center=true);
        translate([0,0,-tape_hole_offset*2])
            cylinder(tape_width*4, r=axle_diameter/2, center=true);
    }
}}}

module tape_advance_wheel(location=[0,0,0], rotation=[0,0,0]){
    translate(location){
        rotate(rotation){
    half_tape_advance_wheel();
    mirror([0,0,1])
    half_tape_advance_wheel();
}}}

module upper_gear(location=[0,0,0], rotation=[0,0,0]){
    translate(location){
        rotate(rotation){
                difference(){
                    union(){
                    translate([0,0,(tape_width-2*tape_hole_offset)/2])
                        spur_gear(2,20, tape_width-2*tape_hole_offset);
                    translate([0,0,tape_width-tape_hole_offset])
                        cylinder(tape_hole_offset*4, r=washer_diameter/2, center=true);
                    }
                    cylinder(tape_width*4, r=axle_diameter/2, center=true);
                }
}}}

module lower_gear(location=[0,0,0], rotation=[0,0,0]){
    translate(location){
        rotate(rotation){
        difference(){
            translate([0,0,(tape_width-tape_hole_offset)/2])
                spur_gear(2,20, tape_width-tape_hole_offset);
            translate([0,0,tape_width])
                cylinder(tape_width*4, r=axle_diameter/2, center=true);
        }
        half_tape_advance_wheel();
}}}

gear_pitch_radius = pitch_radius(2,20);
gear_outer_radius = outer_radius(2,20);
axle_length = tape_width;


module peg(location=[0,0,0], rotation=[0,0,0]){
    translate(location){
        rotate(rotation){
            translate([0,0,4/2+2/2])
                cylinder(h=4,r=tolerate(peg_diameter/2, friction_fit_tolerance),center=true);
                translate([0,0,2/2])
                    cylinder(h=2,r=axle_diameter,center=true);
            
        }}
    
}


module side(location=[0,0,0], rotation=[0,0,0]){
    translate(location){
        rotate(rotation){
            linear_extrude(height=wall_width){
                offset(r=wall_width)
                    offset(r=-wall_width)
                        polygon([[50,-gear_outer_radius-tape_trough_depth-tape_thickness-wall_width],
                                [-60,-gear_outer_radius-tape_trough_depth-tape_thickness-wall_width],
                                [-100,60],
                                [0,3*gear_outer_radius],
                                [gear_outer_radius,0],
                                [-2*gear_outer_radius,0],
                                [-50,0],
                                [-100*0.8,60*.8],
                                [-2*gear_outer_radius,2*gear_pitch_radius]],
                                [[0,1,2,3,4],[5,6,7,8]]);
            }
            linear_extrude(height=tape_hole_offset+wall_width){
                offset(r=wall_width/2.5)
                    offset(r=-wall_width/2.5)
                        polygon([[40,-advance_wheel_radius-tape_thickness],
                                [-40,-advance_wheel_radius-tape_thickness],
                                [-40,-advance_wheel_radius-wall_width-tape_thickness],
                                [40,-advance_wheel_radius-wall_width-tape_thickness]],
                                [[0,1,2,3]]);
            }
            translate([-100*0.92,60*.9,(2+wall_width)/2])
                    cylinder(h=2+wall_width,r1=tolerate(peg_diameter/2, friction_fit_tolerance),r2=tolerate(peg_diameter/2, friction_fit_tolerance*10), center=true);
                
            translate([0,0,(2+wall_width)/2])
                for(i=[0:1])
                    translate([0,i*2*gear_pitch_radius,0])
                            cylinder(h=2+wall_width,r1=tolerate(peg_diameter/2, friction_fit_tolerance),r2=tolerate(peg_diameter/2, friction_fit_tolerance*10), center=true);

 
        }
    }
}

module flipside(location=[0,0,0], rotation=[0,0,0]){
    translate(location){
        rotate(rotation){
            mirror([0,1,0])
                side();
        }}
}



module printable_layout(){
//    for(i=[0:3])
//        axle_cap(location=[i*14,0,0]);
    upper_gear(location=[15, 20,0]);
    lower_gear();
    axle_washer(tape_hole_offset,location=[20, 0, 0]);
    half_tape_advance_wheel(location=[0, 40,0]);
    axle(tape_width, location=[0,75,0]);
    axle(tape_width, location=[0,85,0]);
    axle(tape_width, location=[0,95,0]);
    flipside([50, 100,0],[0,0,135]);
    side([50, 50, 0],[0,0,135]);
}




module assembled_layout(){
    translate([0,0,tape_holes_per_rotation*4*1.07/2/PI-tape_hole_depth]){
        standard_gear([0,-tape_hole_offset,0], [90,0,0]);
        standard_gear([0,-tape_hole_offset,2*gear_pitch_radius], [90,360/20/2,0]);
        tape_advance_wheel(rotation=[90,0,0]);
        axle_washer(2*tape_hole_offset,[0,+tape_hole_offset,2*gear_pitch_radius], [90,360/20/2,0]);
        right_side([0, wall_width+tape_hole_offset,0],[90,0,0]);
        left_side([0, -tape_width-tape_hole_offset, 0],[-90,0,0]);
    }
}


if($preview && !print_preview){
assembled_layout();
} else {
printable_layout();
}
