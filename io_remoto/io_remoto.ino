#include <math.h>

#include <max6675.h>
#include <ArduinoRS485.h>
#include <ArduinoModbus.h>

// Definicoes do escravo e da comunicacao serial
#define SLAVE_ID 1              // endereco do escravo Modbus RTU
#define BAUDRATE 115200         // 115200 bps
#define UART_CONFIG SERIAL_8N1  // 8 data bits, sem paridade, 1 stop bits

#define NUMBER_HOLDING_REGISTERS 6
#define HOLDING_REGISTERS_ADDRESS 0x0000

#define pinHeater 22  // Pino usado acionar um relê do heater
#define COIL_ADDRESS 0x0000

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

#define ntc A0

int pulse_sensor1;
int pulse_sensor2;
int pulse_sensor3;

int k = 0;
int j = 0;
float mediaTemp = 0;

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

  Serial.begin(115200);

  RS485Class rs = RS485Class(Serial3, 14, 7, 7);

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

  // digitalWrite(LED_BUILTIN, HIGH);

  // bobinas a partir do endereço COIL_ADDRESS
  ModbusRTUServer.configureCoils(COIL_ADDRESS, NUMBER_COILS);
  // associa holding registers (registradores)
  ModbusRTUServer.configureHoldingRegisters(HOLDING_REGISTERS_ADDRESS, NUMBER_HOLDING_REGISTERS);

  interrupts();  //Habilita o interrupção no Arduino
  flowSensorPulse();
}

void loop() {
  ModbusRTUServer.poll();

  k++;
  int bitSensor = analogRead(ntc);
  float rSensor = (float)bitSensor * 1000 / (1023 - bitSensor);
  float tK = 3500 / log(rSensor / (0.0792913630639834));
  float temp = tK - 273;
  mediaTemp += temp*10;

  if (k == 100) {
    ModbusRTUServer.holdingRegisterWrite(HOLDING_REGISTERS_ADDRESS+1, mediaTemp);
    mediaTemp = 0;
    k = 0;
  }

  for (int i = 0; i < NUMBER_COILS; i++) {
    // atualiza o pino digital conforme o estado da bobina no servidor
    digitalWrite(outputCoilMap[i], !ModbusRTUServer.coilRead(COIL_ADDRESS + i));
  }

  ModbusRTUServer.holdingRegisterWrite(HOLDING_REGISTERS_ADDRESS, (uint16_t)(termopar1.readCelsius() * 1000));


  j++;
  if (j == 100) {
    ModbusRTUServer.holdingRegisterWrite(HOLDING_REGISTERS_ADDRESS + 3, pulseToFlow(1) * 1000);
    ModbusRTUServer.holdingRegisterWrite(HOLDING_REGISTERS_ADDRESS + 4, pulseToFlow(2) * 1000);
    ModbusRTUServer.holdingRegisterWrite(HOLDING_REGISTERS_ADDRESS + 5, pulseToFlow(3) * 1000);
    flowSensorPulse();
    j = 0;
  }

  delay(5);
  ModbusRTUServer.holdingRegisterWrite(HOLDING_REGISTERS_ADDRESS + 2, (uint16_t)(termopar2.readCelsius() * 1000));
  delay(5);
}
