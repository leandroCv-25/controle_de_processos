const float VelocidadeSom_mpors = 340;        // em metros por segundo
const float VelocidadeSom_mporus = 0.000340;  // em metros por microsegundo

// Funçao para enviar o pulso de trigger
void DisparaPulsoUltrassonico() {
  // Para fazer o HC-SR04 enviar um pulso ultrassonico, nos temos
  // que enviar para o pino de trigger um sinal de nivel alto
  // com pelo menos 10us de duraçao
  digitalWrite(PinTrigger, HIGH);
  delayMicroseconds(10);
  digitalWrite(PinTrigger, LOW);
}


// Função para calcular a distancia em metros
float CalculaDistancia(float tempo_us) {
  return ((tempo_us * VelocidadeSom_mporus) * 100 / 2);
}