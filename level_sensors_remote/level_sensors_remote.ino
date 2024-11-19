#include "HX711.h"
#include <ArduinoRS485.h>
#include <ArduinoModbus.h>

// Definicoes do escravo e da comunicacao serial
#define SLAVE_ID 1              // endereco do escravo Modbus RTU
#define BAUDRATE 115200         // 115200 bps
#define UART_CONFIG SERIAL_8N1  // 8 data bits, sem paridade, 1 stop bits

#define PinTrigger 2  // Pino usado para disparar os pulsos do sensor
#define PinEcho 3     // pino usado para ler a saida do sensor

#define DOUT 4  // HX711 DATA OUT = pino 4 do Arduino
#define CLK 5   // HX711 SCK IN = pino 5 do Arduino



//Endereço de Memoria da distância para o nível máximo
#define HOLDING_REGISTERS_ADDRESS_D_LEVEL_MAX 0x0001
//variavel de distância para o nível máximo
float uLevelMax = 4;
//Endereço de Memoria da distância para o nível máximo
#define HOLDING_REGISTERS_ADDRESS_B_LEVEL_MAX 0x0006
//variavel de distância para o nível máximo
float bLevelMax = 15;
//Endereço de Memoria da distância para o nível minimo
#define HOLDING_REGISTERS_ADDRESS_D_LEVEL_MIN 0x0002
//variavel de distância para o nível minimo
float uLevelMin = 26;
//Endereço de Memoria do fator de calibração da balança
#define HOLDING_REGISTERS_ADDRESS_CALIBRATION_FACTOR 0x0003
//Endereço de memoria do nível do sensor ultrassônico
#define HOLDING_REGISTERS_ADDRESS_U_LEVEL 0x0004
//Endereço de memoria do nível da balança
#define HOLDING_REGISTERS_ADDRESS_B_LEVEL 0x0005


//Endereço de Coil para zerar a balança
#define COIL_ADDRESS_ZERO 0x0001

HX711 balanca;                     // define instancia balança HX711
float calibration_factor = 42130;  // fator de calibração para teste inicial

void setup() {
  // Configura pino de Trigger como saída e inicializa com nível baixo
  pinMode(PinTrigger, OUTPUT);
  digitalWrite(PinTrigger, LOW);
  pinMode(PinEcho, INPUT);  // configura pino ECHO como entrada
  pinMode(LED_BUILTIN, OUTPUT);


  balanca.begin(DOUT, CLK);  // inicializa a balança         // salta uma linha

  balanca.set_scale();  // configura a escala da Balança
  zeraBalanca();

  RS485Class rs = RS485Class(Serial, 1, 7, 7);
  // Inicializa o servidor Modbus RTU
  if (!ModbusRTUServer.begin(rs, SLAVE_ID, BAUDRATE, UART_CONFIG)) {
    while (1) {
      digitalWrite(LED_BUILTIN, HIGH);
      delay(500);
      digitalWrite(LED_BUILTIN, LOW);
      delay(500);
    }
  }

  digitalWrite(LED_BUILTIN, HIGH);

  // bobinas a partir do endereço COIL_ADDRESS
  ModbusRTUServer.configureCoils(COIL_ADDRESS_ZERO, 1);
  // associa holding registers (registradores)
  ModbusRTUServer.configureHoldingRegisters(HOLDING_REGISTERS_ADDRESS_D_LEVEL_MAX, 6);
}

void zeraBalanca() {
  balanca.tare();  // zera a Balança
}

void loop() {

  ModbusRTUServer.poll();

  uLevelMax = ModbusRTUServer.holdingRegisterRead(HOLDING_REGISTERS_ADDRESS_D_LEVEL_MAX);
  uLevelMin = ModbusRTUServer.holdingRegisterRead(HOLDING_REGISTERS_ADDRESS_D_LEVEL_MIN);
  calibration_factor = ModbusRTUServer.holdingRegisterRead(HOLDING_REGISTERS_ADDRESS_CALIBRATION_FACTOR);
  bLevelMax = ModbusRTUServer.holdingRegisterRead(HOLDING_REGISTERS_ADDRESS_B_LEVEL_MAX);

  // Envia pulso para o disparar o sensor
  DisparaPulsoUltrassonico();

  float TimeEcho = pulseIn(PinEcho, HIGH);

  float dist = CalculaDistancia(TimeEcho);

  ModbusRTUServer.holdingRegisterWrite(HOLDING_REGISTERS_ADDRESS_U_LEVEL, map(dist, uLevelMin, uLevelMax, 0, 100));

  balanca.set_scale(calibration_factor);  // ajusta fator de calibração

  ModbusRTUServer.holdingRegisterWrite(HOLDING_REGISTERS_ADDRESS_B_LEVEL, map(balanca.get_units(), 0, bLevelMax, 0, 100));
}
