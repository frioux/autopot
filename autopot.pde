#include <avr/pgmspace.h>

const int heater_left PROGMEM = 9;
const int heater_right =7;

const int cooler_right = 8;

const int pump_left = 6;
const int pump_right = 4;

const int stirrer_left = 5;
const int stirrer_right = 3;
const int delay_ms = 50;

const int dest_temp = 500;
const int oscillation_time = 50;

// safety temp should be calculated by looking at the
// amount of water.  Less water == higher safety
const int safety_temp = 200;

int threshold = dest_temp - safety_temp;

int last_switch;

void on(int pin) {
  digitalWrite(pin, HIGH);
}

void off(int pin) {
  digitalWrite(pin, LOW);
}

void setup() {
  pinMode(heater_left, OUTPUT);
  pinMode(cooler_right, OUTPUT);
  pinMode(heater_right, OUTPUT);
  pinMode(pump_left, OUTPUT);
  pinMode(stirrer_left, OUTPUT);
  pinMode(stirrer_right, OUTPUT);
  pinMode(pump_right, OUTPUT);
  last_switch = millis();
}

bool heater_left_on;

void loop() {
  int currTemp = analogRead(A0);
  int currMillis = millis();
  if (currTemp < threshold) {
    on(heater_left);
    heater_left_on = true;
  } else if (currTemp < dest_temp) {
    if (abs( currMillis - last_switch ) > oscillation_time) {
      last_switch = currMillis;
      if (heater_left_on) {
         off(heater_left);
         heater_left_on = false;
      } else {
         on(heater_left);
         heater_left_on = true;
      }
    }
  } else {
    off(heater_left);
    heater_left_on = false;
  }
}

// vim: ft=arduino
