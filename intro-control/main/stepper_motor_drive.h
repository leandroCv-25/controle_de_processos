#ifndef STEPPER_MOTOR_DRIVE_H_
#define STEPPER_MOTOR_DRIVE_H_

/**
 * @brief Estrutura para representar o contexto do motor
 *
 */
typedef struct
{
    int step_gpio;
    int step_gpio_state;
    int error;
    int diretion_gpio;
    int pulses_per_rotation;
    float size_gear;
    float vmax;
    int report_pulses;
    int expect_position;
    int delta_pulses;
    int home_sensor;
    int isReady;
} stepper_motor_control_context_t;

/**
 * @brief Seta a Posicao esperada do motor
 *
 * @param motor_ctrl_ctx Contexto de controle de motor
 * @param new_speed mm
 */
void set_stepper_motor_position(stepper_motor_control_context_t *motor_ctrl_ctx, float new_speed,float vmax);

/**
 * @brief Obtem a posição do motor em mm
 *
 * @param motor_ctrl_ctx Contexto de controle de motor
 * @return float
 */
float get_stepper_motor_position(stepper_motor_control_context_t *motor_ctrl_ctx);

/**
 * @brief Obtem a velocidade do motor em mm/s
 *
 * @param motor_ctrl_ctx Contexto de controle de motor
 * @return float
 */
float get_stepper_motor_speed(stepper_motor_control_context_t *motor_ctrl_ctx);

float get_stepper_motor_error(stepper_motor_control_context_t *motor_ctrl_ctx);

float get_stepper_motor_control_output(stepper_motor_control_context_t *motor_ctrl_ctx);

/**
 * @brief Função para a configuração do motor passo
 *
 */
void stepper_motor_drive_config(void*pvParameters);

#endif