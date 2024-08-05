#include <stdio.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include "esp_system.h"
#include "esp_log.h"
#include <nvs_flash.h>
#include "mqtt_client.h"

#include "button_app.h"
#include "wifi_app.h"
#include "rgb_led.h"
#include "mqtt_app.h"
#include "motor_drive.h"

static const char *TAG = "MAIN";
button_handle_t button_connect;

float kp;
float ki;
float kd;
float setpoint;
float vmax;
int isClosedLoop;

static void request_conection(void *arg, void *usr_data)
{
    wifi_app_send_message(WIFI_APP_MSG_USER_REQUESTED_CONNECTION);
}

void wifi_application_connected_events(void)
{
    ESP_LOGI(TAG, "WiFi Application Connected!!");

    char device_name[] = "Position_0001";

    client = mqtt_app_start(&receved_msg, device_name);
}

static void receved_msg(char *str_data)
{
    sscanf(str_data, "{\"kp\":%f,\n\"ki\":%f,\n \"kd\":%f,\n\"setpoint\":%f,\n \"vmax\":%f,\n\"isClosedLoop\":%d}", &kp, &ki, &kd, &setpoint, &vmax, &isClosedLoop);
}

void send_msg(float position, float error, float output, float speed)
{
    char msg[200];
    sprintf(msg, "{\"position\":%f,\n\"error\":%f,\n \"output\":%f,\n\"speed\":%f}", position, error, output, speed);
    mqtt_app_send_msg(client, msg);
}

void app_main(void)
{

    /* Initialize NVS partition */
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND)
    {
        /* NVS partition was truncated
         * and needs to be erased */
        ESP_ERROR_CHECK(nvs_flash_erase());

        /* Retry nvs_flash_init */
        ESP_ERROR_CHECK(nvs_flash_init());
    }

    rgb_led_init();

    wifi_app_start(&wifi_application_connected_events);

    button_connect = button_app_init(13, 0);

    resgister_event_callback(button_connect, BUTTON_LONG_PRESS_START, 8000, &request_conection, NULL);

    while (true)
    {
        for (int i = 0; i < 150; i++)
        {
            ESP_LOGI(TAG, "Setando velocidade %d e Sentido horario", i);
            set_motor_direction(&motor_ctrl_ctx, MOTOR_FORWARD);
            set_motor_speed(&motor_ctrl_ctx, i);
            vTaskDelay(pdMS_TO_TICKS(100));
            ESP_LOGI(TAG, "Velocidade %.2f RPM", get_motor_speed(&motor_ctrl_ctx));
        }

        ESP_LOGI(TAG, "FREIANDO");
        motor_brake(&motor_ctrl_ctx);
        vTaskDelay(pdMS_TO_TICKS(100));

        for (int i = 0; i < 150; i++)
        {
            ESP_LOGI(TAG, "Setando velocidade %d e Sentido anti-horario", i);
            set_motor_direction(&motor_ctrl_ctx, MOTOR_REVERSE);
            set_motor_speed(&motor_ctrl_ctx, i);
            vTaskDelay(pdMS_TO_TICKS(100));
            ESP_LOGI(TAG, "Velocidade %.2f RPM", get_motor_speed(&motor_ctrl_ctx));
        }

        ESP_LOGI(TAG, "FREIANDO");
        motor_brake(&motor_ctrl_ctx);
        vTaskDelay(pdMS_TO_TICKS(100));
    }
}