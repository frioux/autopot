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


int state = 1;

// safety temp should be calculated by looking at the
// amount of water.  Less water == higher safety
/*const int safety_temp = 200;*/

bool heater_on;
bool stirrer_on;
bool pump_on;
int last_heat_switch;
int last_stir_switch;
int last_pump_switch;
int currTemp = analogRead(A0) / 4; // max 256
int currMillis = millis();
int state_switch_time;

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

void maintain_stirrer(int oscillation_time, bool side) { // {{{
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

void maintain_heater(int dest_temp, int threshold, int oscillation_time, bool side) { // {{{
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

void maintain_pump(int oscillation_time, bool from, bool to) { // {{{
  int pump = (from == left ? pump_left : pump_right );
  if (abs( currMillis - last_pump_switch ) > oscillation_time) {
    last_pump_switch = currMillis;
    if (pump_on) {
       off(pump);
       pump_on = false;
    } else {
       on(pump);
       pump_on = true;
    }
  }
} // }}}

void setState(int new_state) { // {{{
  state = new_state;
  state_switch_time = currMillis;
  off(heater_left);
  off(cooler_right);
  off(heater_right);
  off(pump_left);
  off(stirrer_left);
  off(stirrer_right);
  off(pump_right);
} // }}}

void loop() { // {{{
  currTemp = analogRead(A0) / 4; // max 256
  currMillis = millis();
  // Heat left while stirring
  if (state == 1) {
     maintain_heater(212, 190, 100, left);
     maintain_stirrer(200, left);
     // Until we reach 212
     if (currTemp >= 212) setState(state + 1);
  // Pump left to right
  } else if (state == 2) {
     maintain_pump(50, left, right);
     // for 5 seconds
     if (currMillis - state_switch_time > 5000) setState(state + 1);
  // Maintain heat right while stirring
  } else if (state == 3) {
     maintain_heater(212, 190, 100, right);
     maintain_stirrer(200, right);
     // for 10 seconds
     if (currMillis - state_switch_time > 10000) setState(state + 1);
  // Pump right to left
  } else if (state == 4) {
     maintain_pump(50, right, left);
     // for 5 seconds
     if (currMillis - state_switch_time > 5000) setState(state + 1);
  } else if (state == 5) {
  // Maintain heat right while stirring
     maintain_heater(212, 190, 100, left);
  }
} // }}}

// vim: ft=arduino foldmethod=marker
