Wcard=46.0;     // Largeur carte CLG
Hcard=37.5;     // Hauteur carte CLG
Wext=35;        // Largeur additionnelle (à droite carte CLG)
Hext=10;        // Hauteur additionnelle (au dessus carte CLG)
Pcard=14;       // Profondeur carte (pins arduino notamment)
Ecard=2;        // Marge autour de la carte
SupCard=1;      // Rebord sour la carte pour support latéral
PSupCard=3;     // Profondeur du rebord
E=3;            // Épaisseur boitier
CableX=26;      // Position passage fil CLG-CO2
cirbandy=6;     // Position barre transversale sous arduino
cirbandh=10;    // Largeur barre transversale sous arduino
co2X=21.5;      // Position X capteur CO2 (premier trou)
co2Y=1.5;       // Position Y capteur CO2 (trou)
co2YY=co2Y-0.5; // Position Y capteur CO2 (trou isolé)
trouX=44.8;     // Ecartement X des trous capteur CO2
trouY=28.9;     // Ecartement Y des trous capteur CO2
coreW=34.5;     // Largeur du noyau galvanomètre
coreH=27;       // Hauteur du noyau galvanomètre
galvaP=13;      // Profondeur du galvanomètre
galvaX=42;      // Position X du centre noyau galvanomètre
visE=52;        // Écartement entre les vis de fixations galvanomètre
piedP=4;        // Hauteurs des pieds fixation CO2
Hlid1=18.5;     // Hauteur coin hg couvercle sup (coince CLG)
Wlid1=7.5;      // Largeur coince CLG
ee=0.2;         // Tolérance mécanique
Pco2=19;        // Profondeur du capteur CO2
Ogalva=41.5-Pcard-galvaP; // Dépassement galva (pour ergo fixation)
Wtot=Wcard+Ecard*2+Wext;
Htot=Hcard+Hext+Ecard*2+coreH+E*2;
Hgalva=58;      // Hauteur haut galva
XXgalva=75;     // Position droite galva
Xgalva=10.5;    // Position gauche galva
Yled=64.2;      // Position leds
YYled=71.5;    
Xled=10.3;
XXled=28;
Rled=(YYled-Yled)/2;
XShole=[E*2, Wtot-E*2]; // Abcisses des trous de fixation couvercle
YShole=[-E*2, -coreH, Hcard+Hext+Ecard*2-E*2]; // Ordonnées


// 3 trous du capteur CO2 (utilisé à la fois pour le cylindre et le trou dans le dit cylindre)
module trous(r, h){
    translate([co2X+trouX,co2Y,0]) cylinder(r=r, h=h);
    translate([co2X, co2YY,0]) cylinder(r=r, h=h);
    translate([co2X+trouX, co2Y+trouY,0]) cylinder(r=r, h=h);
}

// Support du circuit CLG seul
module elecSupport(){
    difference(){
        cube([Wtot,Hcard+Hext+Ecard*2,Pcard]);  // Box au dessus axe (sans partie fix galva)
        translate([Ecard+SupCard,Ecard+SupCard,E]) cube([Wcard-SupCard*2, Hcard-SupCard*2,Pcard]); // Trou plus petit que circuit pour support
        translate([Ecard,Ecard,Pcard-PSupCard]) cube([Wcard, Hcard, Pcard]);  // Trou taille circuit pour insertion, 3m avant le haut
        translate([CableX+Ecard, Hcard,-1]) cube([Wcard-CableX-SupCard,Hcard,50]); // Trou passage cable vers CO2
    }
    translate([0, cirbandy+Ecard, 0]) cube([Wcard+2*Ecard,cirbandh, Pcard-PSupCard]); // Barre horizontale pour support entre pins arduino
}

// Support circuit + support CO2 + support galvanomètre
module elecPlusCo2(){
    // Pieds à l'arrière pour fixation CO2
    difference(){
        union(){
            elecSupport();
            translate([0,0,-piedP]) trous(3.25, piedP); // Cyclindres pour chaque pied
        }
        translate([0,0,-5]) trous(1.25, 20); // Et trou dans ledit cylindre
    }
    // Zones inutile à droite (enfin, elle servira quand même pour supporter le couvercle et autres
    translate([Wcard+2*Ecard,0,Pcard]) cube([Wext,Hcard+2*Ecard+Hext, galvaP]);
    
    // Zone galvanomètre
    difference(){
        union(){
            translate([0, -coreH/2-E*2, 0]) cube([Wtot, coreH/2+E*2,Pcard+galvaP]); // Une moitié de galva à profondeur totale
            translate([0, -coreH-E*2, 0]) cube([E*4,coreH+E*2, Pcard+galvaP]); // Plus un peu sur les côtés jusqu'en bas, à prof totale aussi
            translate([Wtot-E*4, -coreH-E*2, 0]) cube([E*4,coreH+E*2, Pcard+galvaP]); // Idem, de l'autre côté
            translate([0,-coreH-E*2,Pcard+galvaP-E]) cube([Wtot, coreH+E*2,E]); // Et profondeur 3mm seulement dans la zone basse du galva (place pour pouvoir visser)
        }
        translate([galvaX,-coreH/2-E,-1]) {
            cylinder(r=coreH/2, h=Pcard+galvaP+2); // Trou noyau galva
            scale([1,0.5,1]) cylinder(r=coreW/2, h=Pcard+galvaP+2); // Oreilles (note: inutile actuellement, car contenu dans cube suivant)
            translate([-21,-6.5,0]) cube([42,13,Pcard+galvaP+2]);   // Version carrée des oreilles
            translate([-visE/2,-2,0]) cylinder(r=2, h=Pcard+galvaP+2); // Trou vis galva
            translate([visE/2,-2,0]) cylinder(r=2, h=Pcard+galvaP+2);  // idem
            translate([-visE/2,-2,0]) cylinder(r=7, h=Pcard+galvaP-2); // Cylindre autour de la vis (laissant prof 3mm, même là où on était à prof totale)
            translate([visE/2,-2,0]) cylinder(r=7, h=Pcard+galvaP-2);  // idem
        }
    }
}

// Module précédent avec 6 trous pour les vis
module withLidHole(){
    difference(){
        elecPlusCo2();
        // 6 trous, à E*2 de chaque bord (2 centraux au niveau séparation support clg support galva)
        for(x=XShole){
            for(y=YShole){
                translate([x,y, -1]) cylinder(r=1.25, h=50);
            }
        }
    }
}

// Unfinished : visualisation des composants (à ne pas imprimer donc)
module compoVis(){
    translate([15,6,-18]) cube([57.5,35,15]);
    translate([0,0,-20]) trous(r=0.5, h=50);
}

// Couvercle supérieur
module lid(){
    difference(){
        union(){
            translate([0, -coreH-E*2, Pcard+galvaP]) cube([Wtot, Htot, E]);   //  Plaque totale (à percer)
            translate([0, Hext+Hcard+Ecard*2-Hlid1, Pcard]) cube([Wlid1, Hlid1, galvaP+E]); // Plus bas dans angle haut gauche pour connecter avec support et coincer le circuit
            translate([0, Hcard+Ecard*2, Pcard]) cube([Wcard+Ecard*2-ee, Hext, galvaP+E]);  // suite
        }
        translate([Xgalva, -coreH-E*2+1, Pcard+galvaP-0.5]) cube([XXgalva-Xgalva, Hgalva, 50]); // Trou pour écran galva
        // Trous pour leds
        for(x=[Xled+Rled,(Xled+XXled)/2,XXled-Rled]){ 
            translate([x, Yled+Rled-coreH-E*2, -0.5]) cylinder(r=Rled, h=50);
        }
        // Trous fixation couvercle
        for(x=XShole){
            for(y=YShole){
                translate([x,y,-0.5]) cylinder(r=1.25, h=50);
                translate([x,y,Pcard+galvaP+E/2]) cylinder(r1=1.25, r2=3.25, h=E/2+0.01);
            }
        }
        // Mais en plus profond pour le trou haut gauche
        translate([XShole[0], YShole[2], Pcard+E]) cylinder(r=3.25, h=50);
        translate([XShole[0], YShole[2] ,Pcard+E/2]) cylinder(r1=1.25, r2=3.25, h=E/2+0.01);
    }
    // coince galva
    /*
    translate([Xgalva-E, -coreH/2-E*2, Pcard+galvaP]) cube([E,E*2,Ogalva]); 
    translate([Xgalva-E, -coreH/2-E*2, Pcard+galvaP+Ogalva]) cube([E*2, E*2, E]);
    translate([XXgalva, -coreH/2-E*2, Pcard+galvaP]) cube([E,E*2,Ogalva]);
    translate([XXgalva-E, -coreH/2-E*2, Pcard+galvaP+Ogalva]) cube([2*E, 2*E, E]);
    */
}

module lid2(){
    difference(){
        union(){
            translate([0,-coreH-E*2,-E-Pco2]) cube([Wtot,Htot,E]);
            translate([0,-coreH-E*2,-E-Pco2]) cube([Wtot,E,E+Pco2]);
            translate([E*4+ee,-coreH-E*2,-E-Pco2]) cube([Wtot-E*8-ee*2,E,Pco2+Pcard+galvaP]);
            translate([0,-coreH-E*2,-E-Pco2]) cube([E*3,Htot,E+Pco2]);
            translate([Wtot-E*3,-coreH-E*2,-E-Pco2]) cube([E*3,Htot,E+Pco2]);
            translate([0,-E*3+Hcard+Hext+Ecard*2,-E-Pco2]) cube([Wtot,E*3,E+Pco2]);
            translate([CableX+Ecard, Hcard+Hext+Ecard*2-E,-E-Pco2]) cube([Wcard-CableX-SupCard,E,Pco2+Pcard+E]);
            for(x=XShole){
                for(y=[YShole[1],YShole[2]]){
                    translate([x,y,-E-Pco2]) cylinder(r=5, h=Pco2+E);
                }
            }
        }
        for(x=XShole){
            for(y=[YShole[1],YShole[2]]){
                translate([x,y,-E-Pco2-1]) cylinder(r=3.25, h=Pco2+1);
                translate([x,y,-E-0.01]) cylinder(r1=3.25, r2=1.25, h=E/2);
                translate([x,y,-E]) cylinder(r=1.25,h=E*4);
            }
        }
        for(y=[-coreH+E*3:10:Hcard/2]){
            translate([E*1.5,y,-Pco2/2+0.5]) rotate([0,0,-45]) cube([E*6,E,Pco2+1], center=true);
            translate([Wtot-E*1.5,y,-Pco2/2+0.5]) rotate([0,0,45]) cube([E*6,E,Pco2+1], center=true);
        }
        for(y=[Hcard/2+E*2:7:Hcard+Hext-E]){
            translate([E*1.5,y,-Pco2/2+0.5]) rotate([0,0,30]) cube([E*6,E,Pco2+1], center=true);
            translate([Wtot-E*1.5,y,-Pco2/2+0.5]) rotate([0,0,-30]) cube([E*6,E,Pco2+1], center=true);
        }
    }
}

withLidHole();
translate([0,0,22]) color("blue") lid();
translate([0,0,-22]) color("green") lid2();
//color("red") compoVis();