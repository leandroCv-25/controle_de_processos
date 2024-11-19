#include <max6675.h>
#include <ArduinoRS485.h>
#include <ArduinoModbus.h>

// Definicoes do escravo e da comunicacao serial
#define SLAVE_ID 1              // endereco do escravo Modbus RTU
#define BAUDRATE 115200         // 115200 bps
#define UART_CONFIG SERIAL_8N1  // 8 data bits, sem paridade, 1 stop bits

#define NUMBER_HOLDING_REGISTERS 5
#define HOLDING_REGISTERS_ADDRESS 0x0001

#define pinHeater 22  // Pino usado acionar um relê do heater
#define COIL_ADDRESS 0x0001

// mapeamento dos pinos de entradas e saidas
const int outputCoilMap[] = { pinHeater };  // pino referentes ao led buildin
#define NUMBER_COILS 1                      // uma saida digital

#define pinFlowSensor1 18  // Pino usado para ler os pulsos do sensor de vazão 1
#define pinFlowSensor2 19  // Pino usado para ler os pulsos do sensor de vazão 2
#define pinFlowSensor3 20  // Pino usado para ler os pulsos do sensor de vazão 3

/* Definições: GPIOs do Arduino utilizado na comunicação com o 
   MAX6675 */
#define GPIO_SO 8
#define GPIO_CLK 9

#define GPIO_CS1 10  //Chip select termopar 1
#define GPIO_CS2 11  //Chip select termopar 2

int pulse_sensor1;
int pulse_sensor2;
int pulse_sensor3;


float vazaoagua;  //Variável para armazenar o valor em L/min

/* Criação de objeto para comunicação com termopar */
MAX6675 termopar1(GPIO_CLK, GPIO_CS1, GPIO_SO);
MAX6675 termopar2(GPIO_CLK, GPIO_CS2, GPIO_SO);

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(pinHeater, OUTPUT);

  setupFlowSensor(pinFlowSensor1, 1);
  setupFlowSensor(pinFlowSensor2, 2);
  setupFlowSensor(pinFlowSensor3, 3);

  RS485Class rs = RS485Class(Serial, 1, 7, 7);

  // Inicializa o servidor Modbus RTU
  if (!ModbusRTUServer.begin(rs, SLAVE_ID, BAUDRATE, UART_CONFIG)) {
    Serial.println("Falha ao iniciar o Servidor Modbus RTU!");
    while (1) {
      digitalWrite(LED_BUILTIN, HIGH);
      delay(500);
      digitalWrite(LED_BUILTIN, LOW);
      delay(500);
    }
  }

  digitalWrite(LED_BUILTIN, HIGH);

  // bobinas a partir do endereço COIL_ADDRESS
  ModbusRTUServer.configureCoils(COIL_ADDRESS, NUMBER_COILS);
  // associa holding registers (registradores)
  ModbusRTUServer.configureHoldingRegisters(HOLDING_REGISTERS_ADDRESS, NUMBER_HOLDING_REGISTERS);
}

void loop() {
  ModbusRTUServer.poll();

  for (int i = 0; i < NUMBER_COILS; i++) {
    // atualiza o pino digital conforme o estado da bobina no servidor
    digitalWrite(outputCoilMap[i], ModbusRTUServer.coilRead(COIL_ADDRESS + i));
  }

  ModbusRTUServer.holdingRegisterWrite(HOLDING_REGISTERS_ADDRESS, termopar1.readCelsius());


  flowSensorPulse();

  ModbusRTUServer.holdingRegisterWrite(HOLDING_REGISTERS_ADDRESS + 2, pulseToFlow(1));
  ModbusRTUServer.holdingRegisterWrite(HOLDING_REGISTERS_ADDRESS + 3, pulseToFlow(2));
  ModbusRTUServer.holdingRegisterWrite(HOLDING_REGISTERS_ADDRESS + 4, pulseToFlow(3));

  ModbusRTUServer.holdingRegisterWrite(HOLDING_REGISTERS_ADDRESS + 1, termopar2.readCelsius());
}
