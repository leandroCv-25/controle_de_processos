#include <stdio.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include "esp_log.h"
#include "esp_timer.h"

#include "driver/pulse_cnt.h"
#include "driver/gpio.h"

#include "bdc_motor.h"
#include "pid_ctrl.h"

#include "servo_motor_drive.h"

#define M_PI 3.14159265358979323846

static const char *TAG = "PWM MOTOR BDC";

// Função de CALLBACK do PID
static void pid_loop_cb(void *args)
{
    servo_motor_control_context_t *ctx = (servo_motor_control_context_t *)args;
    pcnt_unit_handle_t pcnt_unit = ctx->pcnt_encoder;
    pid_ctrl_block_handle_t pid_ctrl = ctx->pid_ctrl;
    bdc_motor_handle_t motor = ctx->motor;

    // get the result from rotary encoder
    int cur_pulse_count = 0;
    ESP_ERROR_CHECK(pcnt_unit_get_count(pcnt_unit, &cur_pulse_count));

    ctx->delta_pulses = cur_pulse_count - ctx->report_pulses;
    ctx->report_pulses = cur_pulse_count;

    int error = 0;
    float new_speed = 0;
    // calculate the position error
    error = (ctx->expect_position - ctx->report_pulses);

    ctx->controlData.error = error;
    if (error > 0)
    {
        ESP_ERROR_CHECK(bdc_motor_forward(motor));
        // set the new speed
        pid_compute(pid_ctrl, error, &new_speed);
        ctx->controlData.output_control = new_speed;
        bdc_motor_set_speed(motor, (uint32_t)new_speed);
    }
    else if (error < 0)
    {
        error = abs(error);
        ESP_ERROR_CHECK(bdc_motor_reverse(motor));
        // set the new speed
        pid_compute(pid_ctrl, error, &new_speed);
        ctx->controlData.output_control = new_speed;
        bdc_motor_set_speed(motor, (uint32_t)new_speed);
    }
    else
    {
        bdc_motor_brake(motor);
        ctx->controlData.output_control = 0;
    }
}

void servo_motor_pid_update(servo_motor_control_context_t *motor_ctrl_ctx, float kp, float kd, float ki)
{
    motor_ctrl_ctx->controlData.kp = kp;
    motor_ctrl_ctx->controlData.ki = ki;
    motor_ctrl_ctx->controlData.kd = kd;

    pid_ctrl_parameter_t pid_update_param = {
        .kp = kp,
        .ki = ki,
        .kd = kd,
        .cal_type = PID_CAL_TYPE_INCREMENTAL,
        .max_output = BDC_MCPWM_DUTY_TICK_MAX - 1,
        .min_output = 0,
        .max_integral = 1000,
        .min_integral = -1000,
    };

    ESP_ERROR_CHECK(pid_update_parameters(motor_ctrl_ctx->pid_ctrl, &pid_update_param));
}

void set_servo_motor_position(servo_motor_control_context_t *motor_ctrl_ctx, float new_position)
{
    motor_ctrl_ctx->expect_position = (int)(motor_ctrl_ctx->pulses_per_rotation * new_position / (M_PI * 2 * (motor_ctrl_ctx->size_gear)));
}

float get_servo_motor_position(servo_motor_control_context_t *motor_ctrl_ctx)
{

    return ((float)(motor_ctrl_ctx->report_pulses) / (motor_ctrl_ctx->pulses_per_rotation)) * M_PI * 2 * (motor_ctrl_ctx->size_gear);
}

float get_servo_motor_speed(servo_motor_control_context_t *motor_ctrl_ctx)
{
    return (motor_ctrl_ctx->delta_pulses) * 60000 / ((motor_ctrl_ctx->pulses_per_rotation) * BDC_PID_LOOP_PERIOD_MS);
}

float get_servo_motor_error(servo_motor_control_context_t *motor_ctrl_ctx)
{
    return ((float)(motor_ctrl_ctx->controlData.error) / (motor_ctrl_ctx->pulses_per_rotation)) * M_PI * 2 * (motor_ctrl_ctx->size_gear);
}

float get_servo_motor_control_output(servo_motor_control_context_t *motor_ctrl_ctx)
{
    return 100 * (motor_ctrl_ctx->controlData.output_control) / BDC_MCPWM_DUTY_TICK_MAX;
}

void motor_drive_config(servo_motor_control_context_t *motor_ctrl_ctx, int bdc_mcpwm_gpio_a, int bdc_mcpwm_gpio_b, int bdc_encoder_gpio_a, int bdc_encoder_gpio_b, int group_id, int home_sensor)
{

    // Fazer um HOME depois
    motor_ctrl_ctx->expect_position = 0;

    ESP_LOGI(TAG, "Criando o DC motor");
    bdc_motor_config_t motor_config = {
        .pwm_freq_hz = BDC_MCPWM_FREQ_HZ,
        .pwma_gpio_num = bdc_mcpwm_gpio_a, // Setando as portas da ponte H
        .pwmb_gpio_num = bdc_mcpwm_gpio_b,
    };
    bdc_motor_mcpwm_config_t mcpwm_config = {
        .group_id = group_id,                           // Setando o timer do MCPWM
        .resolution_hz = BDC_MCPWM_TIMER_RESOLUTION_HZ, // Colocando a resolução do Timer do motor
    };

    // Criando a variável de manipulação do motor
    bdc_motor_handle_t motor = NULL;
    // Atribuindo as configurações
    ESP_ERROR_CHECK(bdc_motor_new_mcpwm_device(&motor_config, &mcpwm_config, &motor));
    // Colocando nossa variável no contexto para podermos manipular o motor fora da função
    motor_ctrl_ctx->motor = motor;

    ESP_LOGI(TAG, "Habilitando o motor");
    ESP_ERROR_CHECK(bdc_motor_enable(motor));

    // Homing
    ESP_ERROR_CHECK(bdc_motor_forward(motor));
    bdc_motor_set_speed(motor, 25 * BDC_MCPWM_DUTY_TICK_MAX / 100);
    vTaskDelay(pdMS_TO_TICKS(500));
    while (gpio_get_level(home_sensor))
    {
        ESP_ERROR_CHECK(bdc_motor_reverse(motor));
        bdc_motor_set_speed(motor, 25 * BDC_MCPWM_DUTY_TICK_MAX / 100);
        vTaskDelay(pdMS_TO_TICKS(100));
    }

    ESP_LOGI(TAG, "Criando o driver que cuida de decodificar o encoder");
    pcnt_unit_config_t unit_config = {
        .high_limit = BDC_ENCODER_PCNT_HIGH_LIMIT, // Setando os limites de contagem
        .low_limit = BDC_ENCODER_PCNT_LOW_LIMIT,
        .flags.accum_count = true, // habilitando a acumular a contagem
    };

    // Criando o manipulador
    pcnt_unit_handle_t pcnt_unit = NULL;
    // Atribuindo a configuração no manipulador
    ESP_ERROR_CHECK(pcnt_new_unit(&unit_config, &pcnt_unit));
    // criando um filtro
    pcnt_glitch_filter_config_t filter_config = {
        .max_glitch_ns = 1000,
    };
    // Atribuindo o filtro no manipulador
    ESP_ERROR_CHECK(pcnt_unit_set_glitch_filter(pcnt_unit, &filter_config));

    // Criando o canal a (Variável que vai armazenar as portas)
    pcnt_chan_config_t chan_a_config = {
        .edge_gpio_num = bdc_encoder_gpio_a,
        .level_gpio_num = bdc_encoder_gpio_b,
    };
    pcnt_channel_handle_t pcnt_chan_a = NULL;
    ESP_ERROR_CHECK(pcnt_new_channel(pcnt_unit, &chan_a_config, &pcnt_chan_a));

    // Criando o canal b (Variável que vai armazenar as portas)
    pcnt_chan_config_t chan_b_config = {
        .edge_gpio_num = bdc_encoder_gpio_b,
        .level_gpio_num = bdc_encoder_gpio_a,
    };
    pcnt_channel_handle_t pcnt_chan_b = NULL;
    ESP_ERROR_CHECK(pcnt_new_channel(pcnt_unit, &chan_b_config, &pcnt_chan_b));

    // Configuração as opções de leitura para a contagem
    ESP_ERROR_CHECK(pcnt_channel_set_edge_action(pcnt_chan_a, PCNT_CHANNEL_EDGE_ACTION_DECREASE, PCNT_CHANNEL_EDGE_ACTION_INCREASE));
    ESP_ERROR_CHECK(pcnt_channel_set_level_action(pcnt_chan_a, PCNT_CHANNEL_LEVEL_ACTION_KEEP, PCNT_CHANNEL_LEVEL_ACTION_INVERSE));
    ESP_ERROR_CHECK(pcnt_channel_set_edge_action(pcnt_chan_b, PCNT_CHANNEL_EDGE_ACTION_INCREASE, PCNT_CHANNEL_EDGE_ACTION_DECREASE));
    ESP_ERROR_CHECK(pcnt_channel_set_level_action(pcnt_chan_b, PCNT_CHANNEL_LEVEL_ACTION_KEEP, PCNT_CHANNEL_LEVEL_ACTION_INVERSE));

    // Criando um ponte de reset no limite
    ESP_ERROR_CHECK(pcnt_unit_add_watch_point(pcnt_unit, BDC_ENCODER_PCNT_HIGH_LIMIT));
    ESP_ERROR_CHECK(pcnt_unit_add_watch_point(pcnt_unit, BDC_ENCODER_PCNT_LOW_LIMIT));

    // Habilitando
    ESP_ERROR_CHECK(pcnt_unit_enable(pcnt_unit));
    // Resetando a contagem para o inicio
    ESP_ERROR_CHECK(pcnt_unit_clear_count(pcnt_unit));

    // START
    ESP_ERROR_CHECK(pcnt_unit_start(pcnt_unit));

    // Colocando nossa variável no contexto para podermos manipular o enconder fora da função
    motor_ctrl_ctx->pcnt_encoder = pcnt_unit;

    ESP_LOGI(TAG, "Criando o bloco de controle PID");
    // Configuração do PID
    pid_ctrl_parameter_t pid_runtime_param = {
        .kp = motor_ctrl_ctx->controlData.kp,
        .ki = motor_ctrl_ctx->controlData.ki,
        .kd = motor_ctrl_ctx->controlData.kd,
        .cal_type = PID_CAL_TYPE_POSITIONAL, // Tipo de controle -> para o motor o ideal é incremental mesmo (Pensado na velocidade)
        .max_output = BDC_MCPWM_DUTY_TICK_MAX - 1,
        .min_output = 0,
        .max_integral = 1000,
        .min_integral = -1000,
    };

    // Criando a variável de manipulação do PID
    pid_ctrl_block_handle_t pid_ctrl = NULL;
    // Criando a variável de configuração
    pid_ctrl_config_t pid_config = {
        .init_param = pid_runtime_param,
    };
    // Atribuindo a configuração de controle
    ESP_ERROR_CHECK(pid_new_control_block(&pid_config, &pid_ctrl));
    // Colocando nossa variável no contexto para podermos manipular o controle pid fora da função
    motor_ctrl_ctx->pid_ctrl = pid_ctrl;

    ESP_LOGI(TAG, "Criando o timer para fazer o calculo do PID periodicamente");
    const esp_timer_create_args_t periodic_timer_args = {
        .callback = pid_loop_cb,
        .arg = motor_ctrl_ctx,
        .name = "pid_loop"};
    esp_timer_handle_t pid_loop_timer = NULL;
    ESP_ERROR_CHECK(esp_timer_create(&periodic_timer_args, &pid_loop_timer));


    ESP_LOGI(TAG, "Start! o controle vai começar a calcular agora");
    ESP_ERROR_CHECK(esp_timer_start_periodic(pid_loop_timer, BDC_PID_LOOP_PERIOD_MS * 1000));
}
