#include <EEPROM.h>

const int rouge=2;
const int orange=3;
const int vert=6;
const int pwmCo2=4;

const int adrSeuil=0;
struct Seuils {
  char m1, m2, m3, m4;
  int s1;
  int s2;
  int s3;
};

Seuils seuils;

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(rouge, OUTPUT);
  pinMode(orange, OUTPUT);
  pinMode(vert, OUTPUT);

  Serial.begin(115200);
  while(!Serial){}
  pinMode(pwmCo2, INPUT);

  EEPROM.get(adrSeuil, seuils);
  if(seuils.m1=='C' && seuils.m2=='L' && seuils.m3=='G' && seuils.m4==':'){
    ;
  }else{
    seuils.m1='C';
    seuils.m2='L';
    seuils.m3='G';
    seuils.m4=':';
    seuils.s1=600;
    seuils.s2=800;
    seuils.s3=1000;
    EEPROM.put(adrSeuil, seuils);
  }
}

void testLed(int led, int num){
  for(int i=0; i<num; i++){
    digitalWrite(led, HIGH);
    delay(300);
    digitalWrite(led, LOW);
    delay(200);
  }
}

void loop() {
  char buf[40];
  
  if(Serial.available()){
    String k=Serial.readStringUntil(' ');
    long v;
    if(k=="st"){
      seuils.s1=Serial.parseInt();
      Serial.readStringUntil(' ');
      seuils.s2=Serial.parseInt();
      Serial.readStringUntil(' ');
      seuils.s3=Serial.parseInt();
    }
    else if(k=="tl"){
      for(int i=0; i<5; i++){
        testLed(vert, 1);
        testLed(orange, 2);
        testLed(rouge, 3);
      }
    }
    while(Serial.available()>0){
      int x=Serial.read();
      Serial.print("<");
      Serial.print(x, HEX);
      Serial.print(">");
    }
    EEPROM.put(adrSeuil, seuils);
    sprintf(buf, "seuils %d %d %d", seuils.s1, seuils.s2, seuils.s3);
    Serial.println(buf);
  }
  
  long pr=pulseIn(pwmCo2, HIGH, 2000000);
  sprintf(buf, "pulse %ld %ld end", pr, pr/500);
  Serial.println(buf);
  digitalWrite(rouge, LOW);
  digitalWrite(orange, LOW);
  digitalWrite(vert, LOW);
  digitalWrite(LED_BUILTIN, LOW);
  int prr=pr/500;
  if(prr<300){
    digitalWrite(vert, HIGH);
    digitalWrite(orange, HIGH);
    digitalWrite(rouge, HIGH);
  }
  else if(prr<seuils.s1) digitalWrite(vert, HIGH);
  else if(prr<seuils.s2) digitalWrite(orange, HIGH);
  else digitalWrite(rouge, HIGH);
  if(prr>seuils.s3) digitalWrite(LED_BUILTIN, HIGH);
  int perio=16;
  if(prr>seuils.s3+800) perio=1;
  else if(prr>seuils.s3+600) perio=2;
  else if(prr>seuils.s3+400) perio=4;
  else if(prr>seuils.s3+200) perio=8;
  int j=0;
  int l=1;
  for(int i=0; i<50;i++){
    j++;
    delay(100);
    if(prr>seuils.s3 && j>=perio){
        l=1-l;
        j=0;
        if(l){
            digitalWrite(rouge, HIGH);
            if(perio==8) digitalWrite(vert, HIGH);
            else if(perio==4) digitalWrite(vert, LOW);
            else if(perio==2) digitalWrite(orange, HIGH);
            else if(perio==1){
                digitalWrite(orange, HIGH);
                digitalWrite(vert, HIGH);
            }
        }else{
            digitalWrite(rouge, LOW);
            if(perio==8) digitalWrite(vert, LOW);
            else if(perio==4) digitalWrite(vert, HIGH);
            else if(perio==2) digitalWrite(orange, LOW);
            else if(perio==1){
                digitalWrite(orange, LOW);
                digitalWrite(vert, LOW);
            }
        }
    }
  }
  if(prr>seuils.s3){
    digitalWrite(vert, LOW);
    digitalWrite(orange, LOW);
    digitalWrite(rouge, LOW);
  }
}
