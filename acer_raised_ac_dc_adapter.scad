include <BOSL2/std.scad>
include <BOSL2/beziers.scad>

$fn=20;

//width, height, rounding_dia, thick
acer_data = [76-0.4, 26-0.4, 5, 125-12];

wall_thick = 6;

//NOTE: actual height is stand_height/sqrt(2)
stand_height = 25;

base_tol = 0.4;

// [lip grab, wall_thick]
click_data = [1.5, 1];

module lil_stick(length, width, thick, angle=30) {
  zrot(90+angle) {
      cuboid([length-width/2, width, thick]);
      xmove(-length/2+width/4) cyl(r=width/2, h=thick);    
  }
}

module sticks(length, width, thick, amt_bend, num, angle=30) {
    xmove(-(width+amt_bend)*num/2) for (i=[0 : num-1]) {
        xmove((width/2+amt_bend)*i) lil_stick(length, width, thick, angle=angle);
    }
}

module click(cut = false) {
   for (i=[-1, 1]) { 
    ymove(i*(click_data[1]*2+base_tol*2+(cut ? base_tol/2 : 0))) {
      ymove(-i*(base_tol/2)) xrot(180*(i==-1 ? 1 : 0)) right_triangle([wall_thick, click_data[0]+click_data[1]], center=true);
      if (!cut) {
        translate([-wall_thick, (click_data[0]/2)*-i, 0]) rect([wall_thick, click_data[1]+base_tol]);
      }
    }
  }
  if (cut) {
    rect([wall_thick, wall_thick-click_data[1]*2]);
    xmove(-wall_thick) rect([wall_thick, wall_thick+click_data[0]*2-click_data[1]*2]);
  }
}

module click_rod(height = wall_thick/2, cut = false) {
  linear_extrude(height=height+(cut ? base_tol : base_tol/2), center=true) {
    for (i=[-1, 1]) {
      xmove(i*(acer_data[3]/2+wall_thick/2)) zrot((i==1 ? 0 : 180)) click(cut=cut);
      rect([acer_data[3]-wall_thick*2, wall_thick/2+click_data[0]+base_tol*3/2+(cut ? click_data[0]+base_tol : click_data[0])], chamfer=(cut ? 0 : base_tol*11/8));
    }
  } 
}

module click_rods(height = wall_thick/2, cut = false) {
  for (i=[-1, 1]) {
    translate([i*(acer_data[0]/2+stand_height-base_tol*5/2)+(i==1 ? -wall_thick/2 : wall_thick/2), 0, acer_data[3]/2+wall_thick/2-0.1]) yrot(90) click_rod(cut=cut);
    translate([0, i*(acer_data[1]/2+stand_height-base_tol*5/2)+(i==1 ? -wall_thick/2 : wall_thick/2), acer_data[3]/2+wall_thick/2-0.1]) zrot(90) yrot(90) click_rod(cut=cut);
  }
}

module grab_rib(thick, dims) {
  diff("__grab_rib_cuts") {
    ellipse(r=dims);
    tag("__grab_rib_cuts") {
      xmove(cos(atan(dims[0]/dims[1]))*thick) ymove(sin(atan(dims[0]/dims[1]))*thick) ellipse(r=dims);  
    }
  }
}

module acer_grab_stand(ang=45) {
  diff("acer_grab_main_cuts") {
    //main rect
    linear_extrude(wall_thick, center=true) rect([acer_data[0]+wall_thick*2, acer_data[1]+wall_thick*2]);  
    //side angle stands
    for (i=[1, -1]) {
      for (j=[ang, -ang]) {
        ymove((j/ang)*(acer_data[1]+stand_height)/2) xmove(i*(acer_data[0]+stand_height)/2) zrot(j*-i)    {
          cuboid([wall_thick, stand_height, wall_thick]); 
          ymove(-(-j/ang)*stand_height/2) zcyl(r=wall_thick/2, h=wall_thick);
        }
        //xmove(i*(acer_data[0]/2-(wall_thick+1))) ymove(acer_data[1]/2+wall_thick/2-base_tol) sticks(wall_thick, 0.4, wall_thick, 1, 5, angle=-90-30);
      }
      //top/bot straight pieces
      ymove((acer_data[1]+stand_height/2-wall_thick*3/4)*i) cuboid([acer_data[0]+stand_height*2-wall_thick, wall_thick, wall_thick]);
      //side pieces
      xmove((acer_data[0]-stand_height/2-wall_thick*3/4)*i) cuboid([wall_thick, acer_data[1]+stand_height*2-wall_thick, wall_thick]);
      //the pie slices for the side grasps
      ymove(i*(acer_data[1]/2+stand_height-base_tol*5/2-wall_thick/2)) xrot(90) pie_slice(r=wall_thick*2, ang=180, h=wall_thick, center=true);
      xmove(i*(acer_data[0]/2+stand_height-base_tol*5/2-wall_thick/2)) zrot(90) xrot(90) pie_slice(r=wall_thick*2, ang=180, h=wall_thick, center=true);
    }
    tag("acer_grab_main_cuts") {
      linear_extrude(wall_thick+base_tol, center=true) rect([acer_data[0]+base_tol, acer_data[1]+base_tol], rounding=acer_data[2]/2);  
      for (i=[1, 1]) {
        for (j=[1, -1]) {
          zmove(i*(wall_thick-base_tol)) ymove(j*(acer_data[1]/2+base_tol)) xrot(45) cuboid([acer_data[0]+base_tol+acer_data[2], wall_thick, wall_thick], rounding=acer_data[2]/2);
            zmove(i*(wall_thick-base_tol)) xmove(j*(acer_data[0]/2+base_tol)) yrot(45) cuboid([wall_thick, acer_data[1]+base_tol+acer_data[2], wall_thick], rounding=acer_data[2]/2);
        }
      }
      click_rods(cut = true);
      //debug cut  //ymove(acer_data[1]/2+stand_height-wall_thick/4) cuboid([wall_thick*3, wall_thick/2, wall_thick*4]);
    }
  }
}
//rack(pitch=1, teeth=10, thickness=5, backing=1, helical=0, pressure_angle=30);

//click();

click_rods(cut=false);
//click_rod();
acer_grab_stand();


//grab_rib(2, [4, 6]);
