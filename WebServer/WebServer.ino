#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>


// Set WiFi credentials
#define WIFI_SSID "urznet"
#define WIFI_PASS "dlpdaiyadmqclrqlhaldadlpdaiyadmqdcdolldbm"

// Set AP credentials
#define AP_SSID "CO2COVID"
#define AP_PASS "WearAMask"

#define vert 14
#define orange 5
#define rouge 4
#define btAP 15
#define bleuEsp 2
#define galva 13


int intens=0;
ESP8266WebServer server(80);

void setup() {  
  // Setup serial port
  Serial.begin(115200);
  Serial.println();   

  
  // Leds et inter
  pinMode(vert, OUTPUT);
  pinMode(orange, OUTPUT);
  pinMode(rouge, OUTPUT);
  pinMode(btAP, INPUT);
  pinMode(bleuEsp, OUTPUT);
  pinMode(galva, OUTPUT);
  digitalWrite(vert, LOW);
  digitalWrite(orange, LOW);
  digitalWrite(rouge, HIGH);
  digitalWrite(galva, 0);
  delay(1000);
  digitalWrite(rouge, LOW);  
  
  // Begin WiFi
  WiFi.softAP("CO2COVID", "WearAMask");
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  
  // Connecting to WiFi...
  Serial.print("Connecting to ");
  Serial.print(WIFI_SSID);
  // Loop continuously while WiFi is not connected
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(100);
    Serial.print(".");
  }
  Serial.println(WiFi.localIP());
  if (MDNS.begin("coo")) {              // Start the mDNS responder for esp8266.local
    Serial.println("mDNS responder started");
  } else {
    Serial.println("Error setting up MDNS responder!");
  }

  server.on("/", rootPage);
  server.begin();
}


void rootPage(){
  Serial.println("handling root");
  if(server.hasArg("intens")){
    intens=server.arg("intens").toInt();
  }
  if(server.hasArg("led")){
    int x=server.arg("led").toInt();
    if(x&1) digitalWrite(rouge, HIGH);
    else digitalWrite(rouge, LOW);
    if(x&2) digitalWrite(vert, HIGH);
    else digitalWrite(vert, LOW);
    if(x&4) digitalWrite(orange, HIGH);
    else digitalWrite(orange, LOW);
    if(x&8) digitalWrite(bleuEsp, HIGH);
    else digitalWrite(bleuEsp, LOW);
  }
  server.send(200, "text/plain", "Bonjour "+String(millis()) +" Vcc="+analogRead(A0));
}


void loop() {
  delay(10);
  server.handleClient();
  analogWrite(galva, intens);
  int x=digitalRead(btAP);
  if(x) {
    digitalWrite(rouge, HIGH);
    digitalWrite(vert, HIGH);
    digitalWrite(orange, HIGH);
    intens=0;
  }
}
