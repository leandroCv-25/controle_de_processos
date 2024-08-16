#include <stdio.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include "esp_log.h"
#include "esp_timer.h"

#include "driver/gpio.h"

#include "stepper_motor_drive.h"

#define M_PI 3.14159265358979323846

static const char *TAG = "Motor Step";
int clock = 0;

static void stepper_timer_cb(void *pvParameters)
{
    stepper_motor_control_context_t *motor_ctrl_ctx = (stepper_motor_control_context_t *)pvParameters;

    if (clock > 100.0 / (motor_ctrl_ctx->vmax))
    {
         
        if (motor_ctrl_ctx->expect_position > motor_ctrl_ctx->report_pulses)
        {
            //  ESP_LOGI(TAG, "%d",motor_ctrl_ctx->report_pulses);
            gpio_set_level(motor_ctrl_ctx->diretion_gpio, true);
            motor_ctrl_ctx->step_gpio_state = !motor_ctrl_ctx->step_gpio_state;
            gpio_set_level(motor_ctrl_ctx->step_gpio, motor_ctrl_ctx->step_gpio_state);
            if (motor_ctrl_ctx->step_gpio_state == 0)
            {
                motor_ctrl_ctx->report_pulses++;
            }
        }
        else if (motor_ctrl_ctx->expect_position < motor_ctrl_ctx->report_pulses)
        {
            //  ESP_LOGI(TAG, "%d",motor_ctrl_ctx->report_pulses);
            gpio_set_level(motor_ctrl_ctx->diretion_gpio, false);
            motor_ctrl_ctx->step_gpio_state = !motor_ctrl_ctx->step_gpio_state;
            gpio_set_level(motor_ctrl_ctx->step_gpio, motor_ctrl_ctx->step_gpio_state);
            if (motor_ctrl_ctx->step_gpio_state == 0)
            {
                motor_ctrl_ctx->report_pulses--;
            }
        }
        motor_ctrl_ctx->delta_pulses = clock;
        clock = 0;
    }
    else
    {
        clock++;
    }
}

void set_stepper_motor_position(stepper_motor_control_context_t *motor_ctrl_ctx, float new_position, float vmax)
{
    motor_ctrl_ctx->vmax = vmax;
    motor_ctrl_ctx->expect_position = (int)(motor_ctrl_ctx->pulses_per_rotation * new_position / (M_PI * (motor_ctrl_ctx->size_gear)));
}

float get_stepper_motor_position(stepper_motor_control_context_t *motor_ctrl_ctx)
{

    return ((float)(motor_ctrl_ctx->report_pulses) / (motor_ctrl_ctx->pulses_per_rotation)) * M_PI * (motor_ctrl_ctx->size_gear);
}

float get_stepper_motor_speed(stepper_motor_control_context_t *motor_ctrl_ctx)
{

    return (120000 * M_PI * (motor_ctrl_ctx->size_gear)) / ((motor_ctrl_ctx->pulses_per_rotation) * (motor_ctrl_ctx->delta_pulses));
}

float get_stepper_motor_error(stepper_motor_control_context_t *motor_ctrl_ctx)
{
    return motor_ctrl_ctx->expect_position - motor_ctrl_ctx->report_pulses;
}

float get_stepper_motor_control_output(stepper_motor_control_context_t *motor_ctrl_ctx)
{
    return motor_ctrl_ctx->expect_position - motor_ctrl_ctx->report_pulses;
}

void stepper_motor_drive_config(void *pvParameters)
{

    stepper_motor_control_context_t *motor_ctrl_ctx = (stepper_motor_control_context_t *)pvParameters;

    motor_ctrl_ctx->expect_position = 0;
    motor_ctrl_ctx->isReady = 0;

    ESP_LOGI(TAG, "Criando o STEP motor");
    esp_rom_gpio_pad_select_gpio(motor_ctrl_ctx->step_gpio);
    gpio_set_direction(motor_ctrl_ctx->step_gpio, GPIO_MODE_OUTPUT);
    esp_rom_gpio_pad_select_gpio(motor_ctrl_ctx->diretion_gpio);
    gpio_set_direction(motor_ctrl_ctx->diretion_gpio, GPIO_MODE_OUTPUT);

    // Homing
    gpio_set_level(motor_ctrl_ctx->diretion_gpio, true);
    for (int i = 0; i < 15; i++)
    {
        gpio_set_level(motor_ctrl_ctx->step_gpio, true);
        vTaskDelay(pdMS_TO_TICKS(10));
        gpio_set_level(motor_ctrl_ctx->step_gpio, false);
        vTaskDelay(pdMS_TO_TICKS(10));
    }
    gpio_set_level(motor_ctrl_ctx->diretion_gpio, false);
    while (gpio_get_level(motor_ctrl_ctx->home_sensor))
    {
        gpio_set_level(motor_ctrl_ctx->step_gpio, true);
        vTaskDelay(pdMS_TO_TICKS(10));
        gpio_set_level(motor_ctrl_ctx->step_gpio, false);
        vTaskDelay(pdMS_TO_TICKS(10));
    }

    motor_ctrl_ctx->step_gpio_state = 0;
    motor_ctrl_ctx->expect_position = 0;
    motor_ctrl_ctx->report_pulses = 0;

    ESP_LOGI(TAG, "Criando o timer para fazer o calculo do PID periodicamente");
    const esp_timer_create_args_t periodic_timer_args = {
        .callback = stepper_timer_cb,
        .arg = motor_ctrl_ctx,
        .name = "pid_loop"};
    esp_timer_handle_t pid_loop_timer = NULL;
    ESP_ERROR_CHECK(esp_timer_create(&periodic_timer_args, &pid_loop_timer));

    ESP_LOGI(TAG, "Start! o controle vai começar a calcular agora");
    ESP_ERROR_CHECK(esp_timer_start_periodic(pid_loop_timer, 125));

    motor_ctrl_ctx->isReady = 1;

    // Fim da task
    vTaskDelete(NULL);
}