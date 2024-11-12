#include <ArduinoRS485.h>
#include <ArduinoModbus.h>

// Definicoes do escravo e da comunicacao serial
#define SLAVE_ID 1              // endereco do escravo Modbus RTU
#define BAUDRATE 115200         // 115200 bps
#define UART_CONFIG SERIAL_8N1  // 8 data bits, sem paridade, 1 stop bits

//OUTPUTS
#define motor_forward 5
#define motor_reverse 6
#define pin_test 13

//INPUTS
#define enconder_A 3
#define enconder_B 4
#define endSwitch 7

#define pulses_per_rotation 1632
#define rotations 59

#define NUMBER_HOLDING_REGISTERS 8
#define HOLDING_REGISTERS_ADDRESS 0x0000
//Var enconder counter for know the pulses
volatile long enconderCount;

long previousTime = 0;
long currentTime = 0;
long p = 0;

float ePrevious = 0;
float eIntegral = 0;

//var PID
float kP = 1;
float kI = 0.0001;
float kD = 0.2;

//current control signal
float currentControlSignal;

//Var current angle
float currentAngle = 0;
float currentAngleInInt = 0;

//Var target angle
float setPointAngle = 0;
int setPointAngleInInt = 0;


void motorForward(int speed) {
  analogWrite(motor_forward, speed);
  analogWrite(motor_reverse, 0);
}

void motorReverse(int speed) {
  analogWrite(motor_reverse, speed);
  analogWrite(motor_forward, 0);
}

void motorStop() {
  analogWrite(motor_reverse, 0);
  analogWrite(motor_forward, 0);
}

void handleEnconder() {
  if (digitalRead(enconder_A) > digitalRead(enconder_B)) {
    enconderCount--;
  } else {
    enconderCount++;
  }
}

void pidControl(int setPoint) {
  long setPointPulse = (int)((float)setPoint / 32767) * (rotations * pulses_per_rotation);

  currentTime = micros();
  float deltaT = ((float)(currentTime - previousTime)) / 1.0e6;


  int e = enconderCount - setPointPulse;
  float eDerivative = (e - ePrevious) / deltaT;
  eIntegral += e * deltaT;


  currentControlSignal = kP * e + kD * eDerivative + kI * eIntegral;


  currentControlSignal > 255 ? currentControlSignal = 255.00 : currentControlSignal < -255 ? currentControlSignal = -255.00
                                                                                           : currentControlSignal = currentControlSignal;

  if (currentControlSignal > 0) {
    motorReverse(fabs(currentControlSignal));
  } else if (currentControlSignal < 0) {
    motorForward(fabs(currentControlSignal));
  } else {
    motorStop();
  }

  previousTime = currentTime;
  ePrevious = e;
}

void setup() {

  pinMode(motor_forward, OUTPUT);
  pinMode(motor_reverse, OUTPUT);
  pinMode(pin_test, OUTPUT);

  pinMode(enconder_A, INPUT);
  pinMode(enconder_B, INPUT);
  pinMode(endSwitch, INPUT);

  motorForward(150);
  delay(300);
  while (digitalRead(endSwitch)) {
    motorReverse(200);
    delay(50);
  }
  motorStop();

  enconderCount = 0;
  attachInterrupt(digitalPinToInterrupt(enconder_A), handleEnconder, RISING);

  setPointAngleInInt = 32767;


  while (currentAngleInInt != 32767) {
    currentAngleInInt = (int)((float)enconderCount / (rotations * pulses_per_rotation)) * 32767;
    pidControl(setPointAngleInInt);
  }

  // Inicializa o servidor Modbus RTU
  if (!ModbusRTUServer.begin(SLAVE_ID, BAUDRATE, UART_CONFIG)) {
    Serial.println("Falha ao iniciar o Servidor Modbus RTU!");
    while (1)
      ;
  }

  // associa holding registers (registradores)
  ModbusRTUServer.configureHoldingRegisters(HOLDING_REGISTERS_ADDRESS, NUMBER_HOLDING_REGISTERS);
}

void loop() {

  ModbusRTUServer.poll();

  setPointAngleInInt = ModbusRTUServer.holdingRegisterRead(HOLDING_REGISTERS_ADDRESS);
  kP = ModbusRTUServer.holdingRegisterRead(HOLDING_REGISTERS_ADDRESS + 4);
  kI = ModbusRTUServer.holdingRegisterRead(HOLDING_REGISTERS_ADDRESS + 5);
  kD = ModbusRTUServer.holdingRegisterRead(HOLDING_REGISTERS_ADDRESS + 6);

  pidControl(setPointAngleInInt);

  setPointAngle = ((float)setPointAngleInInt / 32767.00) * 90;
  currentAngle = ((float)currentAngleInInt / 32767.00) * 90;

  ModbusRTUServer.holdingRegisterWrite(HOLDING_REGISTERS_ADDRESS + 1, setPointAngle);
  ModbusRTUServer.holdingRegisterWrite(HOLDING_REGISTERS_ADDRESS + 2, currentAngle);
  ModbusRTUServer.holdingRegisterWrite(HOLDING_REGISTERS_ADDRESS + 3, currentControlSignal);

  ModbusRTUServer.
  
}
