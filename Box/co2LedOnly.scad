// Juste pour visualiser le capteur. Pas à imprimer
module mh(){
    difference() {
        color("red") {
            cube([57.5, 34.7, 2]);
            cube([12.05, 4.7, 5]);
            translate([0,10,0]) cube([57.5, 15.15, 14.6]);
        }
        translate([54, 2.5, -1]) cylinder(r=1.25, h=10);
        translate([54, 31.5, -1]) cylinder(r=1.25, h=10);
        translate([9.5, 31.5, -1]) cylinder(r=1.25, h=10);
    }
    
    translate([16, -40.5, 4]) color("green") cube([45.3, 37.1, 1]);
}


module supportMh(){
    translate([-6, -43.5, -4]) cube([69.5, 81.2, 2]);
    translate([15, -3, -4]) cube([45.5, 2.5, 16]);
    translate([-3, -3, -4]) cube([2.5, 6, 6]);
    translate([-3, 31.7, -4]) cube([2.5, 6, 6]);
    translate([58, -3, -4]) cube([2.5, 6, 6]);
    translate([58, 31.7, -4]) cube([2.5, 6, 6]);
    translate([-6, 35.2, -4]) cube([67, 2.5, 27]);
    translate([54.5, 2.25, -4]) cylinder(r=2, h=4);
    translate([54.5, 2.25, -4]) cylinder(r=1, h=8);
    translate([54, 31.5, -4]) cylinder(r=2, h=4);
    translate([54, 31.5, -4]) cylinder(r=1, h=8);
    translate([9.5, 31.5, -4]) cylinder(r=2, h=4);
    translate([9.5, 31.5, -4]) cylinder(r=1, h=8);
    translate([3, 8, -4]) cylinder(r=3, h=4);
    translate([-6, -43.5, -4]) cube([69.5, 2.5, 27]);
    translate([15, -19.4, -4]) cube([46.3, 11, 7.5]);
    translate([61, -41, -4]) cube([2.5, 78.7, 27]);
    translate([9, -19.4, -4]) cube([6, 11, 27]);
    translate([-6, -43.5, -4]) cube([2.5, 78.7, 27]);
    translate([41,-31,-4]) cube([4,4,7.5]);
    translate([24,-31,-4]) cube([4,4,7.5]);
    translate([15, -41, -4]) cube([46.3, 1, 7.5]);
}

module boite(){
    difference(){
        supportMh();
        translate([60.5, -21.5, 8]) cube([10, 12, 17]);
        translate([60.5, -34, 10]) cube([10, 6, 4]);
        for(x=[0:8:69]){
            translate([x, 30, -2]) cube([4, 10, 8]);
        }
        for(y=[-40:8:10]) translate([-7, y, -2]) cube([10, 4, 10]);
        for(x=[0:23:69]) {
            translate([x, 30, 21]) cube([4, 10, 4]);
            translate([x, -45, 21]) cube([4, 10, 4]);
        }
        for(y=[-28:22:35]){
            translate([-7, y, 21]) cube([10, 4, 4]);
            translate([57, y, 21]) cube([10, 4, 4]);            
        }
    }
}

module couvercle(){
    difference(){
        translate([-3.25,-40.75,21]) cube([64, 75.75, 2]);
        translate([8.25,-20.15, 20]) cube([7.5,12.5,5]);
        translate([36.75, -36, 20]) cylinder(r=3.25, h=10, $fn=30);
        translate([48.75, -36, 20]) cylinder(r=3.25, h=10, $fn=30);
        translate([42.75, -36, 20]) cylinder(r=3.25, h=10, $fn=30);
    }
    for(y=[-28:22:35]){
        translate([-6, y+0.5, 21]) cube([10, 3, 2]);
        translate([57, y+0.5, 21]) cube([6.5, 3, 2]);            
    }
   for(x=[0:23:60]) {
        translate([x+0.5, 30, 21]) cube([3, 7.75, 2]);
        translate([x+0.5, -43.5, 21]) cube([3, 3, 2]);
    } 
    translate([44.2,-15.6,0]) rotate([0,0,45]) translate([-4,-4,12.75]) cube([8,8,10]);
    translate([57.75, -20, 21]) cube([5.5, 10, 2]);
    translate([57, -20, 13.5]) cube([3, 10, 8]);
}

//boite();
translate([0,0,10]) color("orange") couvercle();

//translate([0,0,0]) mh();