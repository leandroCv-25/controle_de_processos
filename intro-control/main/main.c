#include <stdio.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include "esp_log.h"

#include "driver/gpio.h"

#include "stepper_motor_drive.h"

static const char *TAG = "Main - Stepper motor";

void app_main(void)
{
    static stepper_motor_control_context_t motor_ctrl_ctx = {
        .step_gpio = 18,
        .diretion_gpio = 19,
        .pulses_per_rotation = 200,
        .size_gear = 13,
    };

    gpio_num_t homeSensor = 34;
    esp_rom_gpio_pad_select_gpio(homeSensor);
    gpio_set_direction(homeSensor, GPIO_MODE_INPUT);

    stepper_motor_drive_config(&motor_ctrl_ctx, homeSensor);

    vTaskDelay(pdMS_TO_TICKS(1000));

    // while (true)
    // {

    //     ESP_LOGI(TAG, "Setando Posição 150");
    //     set_servo_motor_position(&motor_ctrl_ctx, 150);
    //     ESP_LOGI(TAG, "Position %.2f mm", get_servo_motor_position(&motor_ctrl_ctx));
    //     ESP_LOGI(TAG, "ERROR %.3f mm", get_servo_motor_error(&motor_ctrl_ctx));
    //     ESP_LOGI(TAG, "OUTPUT %.3f", get_servo_motor_control_output(&motor_ctrl_ctx));

    //     vTaskDelay(pdMS_TO_TICKS(2000));
    //     ESP_LOGI(TAG, "Position %.2f mm", get_servo_motor_position(&motor_ctrl_ctx));
    //     ESP_LOGI(TAG, "Velocidade %.2f RPM", get_servo_motor_speed(&motor_ctrl_ctx));
    //     ESP_LOGI(TAG, "ERROR %f mm", get_servo_motor_error(&motor_ctrl_ctx));
    //     ESP_LOGI(TAG, "OUTPUT %.3f %%\n\n\n", get_servo_motor_control_output(&motor_ctrl_ctx));

    //     for (int i = 150; i > 0; i--)
    //     {
    //         ESP_LOGI(TAG, "Setando Posição %d", i);
    //         set_servo_motor_position(&motor_ctrl_ctx, i);
    //         vTaskDelay(pdMS_TO_TICKS(2000));
    //         ESP_LOGI(TAG, "Position %.2f mm", get_servo_motor_position(&motor_ctrl_ctx));
    //         ESP_LOGI(TAG, "Velocidade %.2f RPM", get_servo_motor_speed(&motor_ctrl_ctx));
    //         ESP_LOGI(TAG, "ERROR %f mm", get_servo_motor_error(&motor_ctrl_ctx));
    //         ESP_LOGI(TAG, "OUTPUT %.3f %%\n\n\n", get_servo_motor_control_output(&motor_ctrl_ctx));
    //     }
    // }
}