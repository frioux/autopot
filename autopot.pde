#include <avr/pgmspace.h>

int PROGMEM heater_left = 9;
int PROGMEM heater_right =7;

int PROGMEM cooler_right = 8;

int PROGMEM pump_left = 6;
int PROGMEM pump_right = 4;

int PROGMEM stirrer_left = 5;
int PROGMEM stirrer_right = 3;
int delay_ms = 50;

void setup() {
  Serial.begin(9600);
  pinMode(heater_left, OUTPUT);
  pinMode(cooler_right, OUTPUT);
  pinMode(heater_right, OUTPUT);
  pinMode(pump_left, OUTPUT);
  pinMode(stirrer_left, OUTPUT);
  pinMode(stirrer_right, OUTPUT);
  pinMode(pump_right, OUTPUT);
}

void fasterer() {
  delay_ms = 50 + 50*((float)analogRead(A0)/1024);
}

void on(int pin) {
  delay(delay_ms);
  digitalWrite(pin, HIGH);
  fasterer();
}

void off(int pin) {
  delay(delay_ms);
  digitalWrite(pin, LOW);
  fasterer();
}

void loop() {
  on(heater_left);
  on(cooler_right);
  on(heater_right);
  on(pump_left);
  on(stirrer_right);
  on(stirrer_left);
  on(pump_right);

  off(heater_left);
  off(cooler_right);
  off(heater_right);
  off(pump_left);
  off(stirrer_right);
  off(stirrer_left);
  off(pump_right);
}

// vim: ft=arduino
