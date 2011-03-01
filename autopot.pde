#include <avr/pgmspace.h>

const int heater_left PROGMEM = 9;
const int heater_right =7;

const int cooler_right = 8;

const int pump_left = 6;
const int pump_right = 4;

const int stirrer_left = 5;
const int stirrer_right = 3;

const bool left = false;
const bool right = true;

bool heater_on;
bool stirrer_on;

// safety temp should be calculated by looking at the
// amount of water.  Less water == higher safety
/*const int safety_temp = 200;*/

int last_heat_switch;
int last_stir_switch;

void on(int pin) { // {{{
  digitalWrite(pin, HIGH);
} // }}}

void off(int pin) { // {{{
  digitalWrite(pin, LOW);
} // }}}

void setup() { // {{{
  pinMode(heater_left, OUTPUT);
  pinMode(cooler_right, OUTPUT);
  pinMode(heater_right, OUTPUT);
  pinMode(pump_left, OUTPUT);
  pinMode(stirrer_left, OUTPUT);
  pinMode(stirrer_right, OUTPUT);
  pinMode(pump_right, OUTPUT);
  last_heat_switch = millis();
} // }}}

void maintain_stirrer(int currMillis, int oscillation_time, bool side) { // {{{
   int stirrer = (side == left ? stirrer_left : stirrer_right );
   if (abs( currMillis - last_stir_switch ) > oscillation_time) {
     last_stir_switch = currMillis;
     if (stirrer_on) {
        off(stirrer);
        stirrer_on = false;
     } else {
        on(stirrer);
        stirrer_on = true;
     }
   }
} // }}}

void maintain_heater(int currTemp, int currMillis, int dest_temp, int threshold, int oscillation_time, bool side) { // {{{
  int heater = (side == left ? heater_left : heater_right );
  if (currTemp < threshold) {
    on(heater);
    heater_on = true;
  } else if (currTemp < dest_temp) {
    if (abs( currMillis - last_heat_switch ) > oscillation_time) {
      last_heat_switch = currMillis;
      if (heater_on) {
         off(heater);
         heater_on = false;
      } else {
         on(heater);
         heater_on = true;
      }
    }
  } else {
    off(heater);
    heater_on = false;
  }
} // }}}

void loop() { // {{{
  int currTemp = analogRead(A0);
  int currMillis = millis();
  maintain_heater(currTemp, currMillis, 500, 300, 100, left);
  maintain_stirrer(currMillis, 200, left);
} // }}}

// vim: ft=arduino foldmethod=marker
