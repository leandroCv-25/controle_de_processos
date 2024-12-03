void incrpulso1() {
  pulse_sensor1++;
}

void incrpulso2() {
  pulse_sensor2++;
}

void incrpulso3() {
  pulse_sensor3++;
}

void setupFlowSensor(int gpio, int number) {
  pinMode(gpio, INPUT);

  switch (number) {
    case 1:
      attachInterrupt(digitalPinToInterrupt(gpio), incrpulso1, RISING);
      break;
    case 2:
      attachInterrupt(digitalPinToInterrupt(gpio), incrpulso2, RISING);
      break;
    case 3:
      attachInterrupt(digitalPinToInterrupt(gpio), incrpulso3, RISING);
      break;
    default:
      break;
  }  //Configura a porta digital, para interrupção
}

void flowSensorPulse() {
  pulse_sensor1 = 0;
  pulse_sensor2 = 0;
  pulse_sensor3 = 0;
}

float pulseToFlow(int number) {
  switch (number) {
    case 1:
      return pulse_sensor1 *2.222;
    case 2:
      return pulse_sensor2 *2.222;
      break;
    case 3:
      return pulse_sensor3 *2.222;
      break;
    default:
      break;
  }
}