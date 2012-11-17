// The Arduino code.

#define ANALOG_IN 1

void setup() {
  Serial.begin(115200); // possible values: 9600, 14400, 19200, 28800, 38400, 57600, or 115200
  pinMode(ANALOG_IN, INPUT);
}

void loop() {
  int val = analogRead(ANALOG_IN);
  Serial.write( val & 0xff);
}

