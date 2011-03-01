#include <avr/pgmspace.h>

const int HEATER_LEFT = 9;
const int HEATER_RIGHT = 7;

const int COOLER_RIGHT = 8;

const int PUMP_LEFT = 6;
const int PUMP_RIGHT = 4;

const int STIRRER_LEFT = 5;
const int STIRRER_RIGHT = 3;

const bool LEFT = false;
const bool RIGHT = true;


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
int curr_temp = analogRead(A0) / 4; // max 256
int curr_millis = millis();
int state_switch_time;

void on(int pin) { // {{{
  digitalWrite(pin, HIGH);
} // }}}

void off(int pin) { // {{{
  digitalWrite(pin, LOW);
} // }}}

void setup() { // {{{
  pinMode(HEATER_LEFT, OUTPUT);
  pinMode(COOLER_RIGHT, OUTPUT);
  pinMode(HEATER_RIGHT, OUTPUT);
  pinMode(PUMP_LEFT, OUTPUT);
  pinMode(STIRRER_LEFT, OUTPUT);
  pinMode(STIRRER_RIGHT, OUTPUT);
  pinMode(PUMP_RIGHT, OUTPUT);
  last_heat_switch = millis();
} // }}}

void maintainStirrer(int oscillation_time, bool side) { // {{{
  int stirrer = (side == LEFT ? STIRRER_LEFT : STIRRER_RIGHT );
  if (abs( curr_millis - last_stir_switch ) > oscillation_time) {
    last_stir_switch = curr_millis;
    if (stirrer_on) {
       off(stirrer);
       stirrer_on = false;
    } else {
       on(stirrer);
       stirrer_on = true;
    }
  }
} // }}}

void maintainHeater(int dest_temp, int threshold, int oscillation_time, bool side) { // {{{
  int heater = (side == LEFT ? HEATER_LEFT : HEATER_RIGHT );
  if (curr_temp < threshold) {
    on(heater);
    heater_on = true;
  } else if (curr_temp < dest_temp) {
    if (abs( curr_millis - last_heat_switch ) > oscillation_time) {
      last_heat_switch = curr_millis;
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

void maintainPump(int oscillation_time, bool from, bool to) { // {{{
  int pump = (from == LEFT ? PUMP_LEFT : PUMP_RIGHT );
  if (abs( curr_millis - last_pump_switch ) > oscillation_time) {
    last_pump_switch = curr_millis;
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
  state_switch_time = curr_millis;
  off(HEATER_LEFT);
  off(COOLER_RIGHT);
  off(HEATER_RIGHT);
  off(PUMP_LEFT);
  off(STIRRER_LEFT);
  off(STIRRER_RIGHT);
  off(PUMP_RIGHT);
} // }}}

void tea_or_coffee(int final_temp, int steep_time) { // {{{
  // these will probably be proportional
  int threshold = final_temp - 20;
  int pump_time = 5000;

  // Heat left while stirring
  if (state == 1) {
     maintainHeater(final_temp, threshold, 100, LEFT);
     maintainStirrer(200, LEFT);
     // Until we reach 212
     if (curr_temp >= final_temp) setState(state + 1);
  // Pump left to right
  } else if (state == 2) {
     maintainPump(50, LEFT, RIGHT);
     // for 5 seconds
     if (curr_millis - state_switch_time > pump_time) setState(state + 1);
  // Maintain heat right while stirring
  } else if (state == 3) {
     maintainHeater(final_temp, threshold, 100, RIGHT);
     maintainStirrer(200, RIGHT);
     // for 10 seconds
     if (curr_millis - state_switch_time > steep_time) setState(state + 1);
  // Pump right to left
  } else if (state == 4) {
     maintainPump(50, RIGHT, LEFT);
     // for 5 seconds
     if (curr_millis - state_switch_time > pump_time) setState(state + 1);
  } else if (state == 5) {
  // Maintain heat right while stirring
     maintainHeater(final_temp, threshold, 100, LEFT);
  }
} // }}}

void loop() { // {{{
  curr_temp = analogRead(A0) / 4; // max 256
  curr_millis = millis();
  tea_or_coffee(212, 10000);
} // }}}

// vim: ft=arduino foldmethod=marker
