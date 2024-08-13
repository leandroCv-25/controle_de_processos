#include <stdio.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include "esp_log.h"

#include "driver/gpio.h"

#include "stepper_motor_drive.h"

#define M_PI 3.14159265358979323846

static const char *TAG = "Motor Step";

static void stepper_task(void *pvParameters)
{
    stepper_motor_control_context_t *motor_ctrl_ctx = (stepper_motor_control_context_t *)pvParameters;
    while (true)
    {
        if (motor_ctrl_ctx->expect_position > motor_ctrl_ctx->report_pulses)
        {
            gpio_set_level(motor_ctrl_ctx->diretion_gpio, true);
            gpio_set_level(motor_ctrl_ctx->step_gpio, true);
            vTaskDelay(pdMS_TO_TICKS(10));
            gpio_set_level(motor_ctrl_ctx->step_gpio, false);
            vTaskDelay(pdMS_TO_TICKS(10));
            motor_ctrl_ctx->report_pulses++;
        }
        else if (motor_ctrl_ctx->expect_position < motor_ctrl_ctx->report_pulses)
        {
            gpio_set_level(motor_ctrl_ctx->step_gpio, true);
            vTaskDelay(pdMS_TO_TICKS(10));
            gpio_set_level(motor_ctrl_ctx->step_gpio, false);
            vTaskDelay(pdMS_TO_TICKS(10));
            motor_ctrl_ctx->report_pulses--;
        }
    }
}

void set_step_motor_position(stepper_motor_control_context_t *motor_ctrl_ctx, float new_position)
{
    motor_ctrl_ctx->expect_position = (int)(motor_ctrl_ctx->pulses_per_rotation * new_position / (M_PI * (motor_ctrl_ctx->size_gear)));
}

float get_step_motor_position(stepper_motor_control_context_t *motor_ctrl_ctx)
{

    return ((float)(motor_ctrl_ctx->report_pulses) / (motor_ctrl_ctx->pulses_per_rotation)) * M_PI * (motor_ctrl_ctx->size_gear);
}

// float get_step_motor_speed(stepper_motor_control_context_t *motor_ctrl_ctx)
// {
//     return (motor_ctrl_ctx->delta_pulses) * 60000 / ((motor_ctrl_ctx->pulses_per_rotation) * BDC_PID_LOOP_PERIOD_MS);
// }

// float get_step_motor_error(stepper_motor_control_context_t *motor_ctrl_ctx)
// {
//     return ((float)(motor_ctrl_ctx->controlData.error) / (motor_ctrl_ctx->pulses_per_rotation)) * M_PI *  (motor_ctrl_ctx->size_gear);
// }

// float get_step_motor_control_output(stepper_motor_control_context_t *motor_ctrl_ctx)
// {
//     return 100 * (motor_ctrl_ctx->controlData.output_control) / BDC_MCPWM_DUTY_TICK_MAX;
// }

void stepper_motor_drive_config(stepper_motor_control_context_t *motor_ctrl_ctx, int home_sensor)
{

    motor_ctrl_ctx->expect_position = 0;

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
    while (gpio_get_level(home_sensor))
    {
        gpio_set_level(motor_ctrl_ctx->step_gpio, true);
        vTaskDelay(pdMS_TO_TICKS(10));
        gpio_set_level(motor_ctrl_ctx->step_gpio, false);
        vTaskDelay(pdMS_TO_TICKS(10));
    }

    motor_ctrl_ctx->expect_position = 0;
    motor_ctrl_ctx->report_pulses = 0;

    xTaskCreate(&stepper_task, "stepper_task", 8094, motor_ctrl_ctx, 1, NULL);
}
