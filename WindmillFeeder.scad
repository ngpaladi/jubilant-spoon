// units are mm
$fn = 200;
include <BOSL2/std.scad>
include <BOSL2/gears.scad>

print_preview = false;

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
axle_retainer_clip_width = 1;
axle_retainer_clip_depth = 1;

reel_diameter = 180;

rotation_tolerance = 0.05;      // fractional "play"
friction_fit_tolerance = 0.01;  // fractional "play"


function tolerate(x,tolerance) = x*(1-tolerance);
advance_wheel_radius = tape_holes_per_rotation*4*1.07/2/PI-tape_hole_depth;


// every model is described such that the object is oruiented as it would be printed, centered on the z-axis, with the bottom resting on the x-y plane

module axle_retainer_clip(location=[0,0,0], rotation=[0,0,0]){
    translate(location)
        rotate(rotation)
            translate([0,0,tolerate(axle_retainer_clip_width,rotation_tolerance)/2])
                difference(){
                    cylinder(tolerate(axle_retainer_clip_width,rotation_tolerance), washer_diameter/2, washer_diameter/2,center=true);
                    cylinder(axle_retainer_clip_width, axle_diameter/2-axle_retainer_clip_depth, axle_diameter/2,center=true);
                    translate([0,0,-axle_retainer_clip_width])
                        linear_extrude(2*axle_retainer_clip_width)
                            polygon([[0,0],[-washer_diameter,-washer_diameter],[washer_diameter,-washer_diameter]]);
                }
            }

module axle(length,location=[0,0,0], rotation=[0,0,0]){
    translate(location)
        rotate(rotation)
                difference(){
                    translate([0,0,length/2+axle_retainer_clip_width])
                    cylinder(h=length+2*axle_retainer_clip_width,r=tolerate(axle_diameter/2,rotation_tolerance), center=true);
                    axle_retainer_clip(location=[0,0,length]);                    
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


module side(location=[0,0,0], rotation=[0,0,0]){
    translate(location){
        rotate(rotation){
            linear_extrude(height=wall_width){
                offset(r=axle_diameter)
                        polygon([[50,-gear_outer_radius-tape_trough_depth-tape_thickness-wall_width],
                                [-reel_diameter/2,-gear_outer_radius-tape_trough_depth-tape_thickness-wall_width],
                                [-reel_diameter/2,reel_diameter/2],
                                [0,3*gear_outer_radius],
                                [gear_outer_radius,0],
                                [-2*gear_outer_radius,0],
                                [-reel_diameter/2,0],
                                [-0.99*reel_diameter/2,0.99*reel_diameter/2],
                                [-2*gear_outer_radius,2*gear_pitch_radius]],
                                [[0,1,2,3,4],[5,6,7,8]]);
            }
            linear_extrude(height=tape_width+wall_width){
                offset(r=wall_width/2.5)
                    offset(r=-wall_width/2.5){
                        polygon([[40,-advance_wheel_radius-tape_thickness],
                                [-40,-advance_wheel_radius-tape_thickness],
                                [-40,-advance_wheel_radius-wall_width-tape_thickness],
                                [40,-advance_wheel_radius-wall_width-tape_thickness]]);
                        polygon([[advance_wheel_radius+2*tape_width,-advance_wheel_radius],
                                [(advance_wheel_radius)/sqrt(2)+2*tape_thickness,-advance_wheel_radius],
                                [(advance_wheel_radius)/sqrt(2)+2*tape_thickness,-advance_wheel_radius+wall_width],
                                [advance_wheel_radius+2*tape_thickness,-advance_wheel_radius+wall_width]]);
                        polygon([[40,-advance_wheel_radius],
                                [30,-advance_wheel_radius],
                                [30,-advance_wheel_radius+wall_width],
                                [40,-advance_wheel_radius+wall_width]]);
                        
                    }
            }
            linear_extrude(height=2*tape_hole_offset+wall_width)
                offset(r=wall_width/2.5)
                    offset(r=-wall_width/2.5)
                        polygon([[(advance_wheel_radius)/sqrt(2)+2*tape_thickness,-advance_wheel_radius],
                                [40,-advance_wheel_radius],
                                [40,-advance_wheel_radius+wall_width],
                                [(advance_wheel_radius)/sqrt(2)+2*tape_thickness,-advance_wheel_radius+wall_width]]);
            translate([-reel_diameter/2,reel_diameter/2,0])
                    axle(tape_width+wall_width);
                
            translate([0,0,0])
                for(i=[0:1])
                    translate([0,i*2*gear_pitch_radius,0])
                            axle(tape_width+wall_width);

 
        }
    }
}



module printable_layout(){
//    for(i=[0:3])
//        axle_cap(location=[i*14,0,0]);
    upper_gear(location=[-60, 32,0]);
    lower_gear(location=[-60, 15,0]);
    axle_washer(tape_hole_offset,location=[20, 20, 0]);
    half_tape_advance_wheel(location=[0, 40,0]);
    side([0, 0, 0],[0,0,0]);
    axle_retainer_clip(location=[-30,10,0]);
    axle_retainer_clip(location=[-40,10,0]);
    axle_retainer_clip(location=[-40,20,0]);
}




module assembled_layout(){
    translate([0,0,tape_holes_per_rotation*4*1.07/2/PI-tape_hole_depth]){
        lower_gear([0,0,0], [90,0,0]);
        axle_retainer_clip([0,-tape_width+tape_hole_offset,0],[90,0,0]);
        upper_gear([0,-tape_width+tape_hole_offset,2*gear_pitch_radius], [-90,360/20/2,0]);
        axle_retainer_clip([0,-tape_width+tape_hole_offset,2*gear_pitch_radius],[90,0,0]);
        axle_washer(1*tape_hole_offset,[0,+tape_hole_offset,0], [90,0,0]);
        side([0, wall_width+tape_hole_offset,0],[90,0,0]);
        
    }
}


if($preview && !print_preview){
assembled_layout();
} else {
printable_layout();
}
