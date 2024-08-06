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
#include "driver/gpio.h"

#include "servo_motor_drive.h"

static const char *TAG = "MAIN";
button_handle_t button_connect;
servo_motor_control_context_t servo_motor_ctrl_ctx;

float kp = 0.3;
float ki = 0.2;
float kd = 0.1;
float setpoint = 0;
float vmax = 100.00;
int isClosedLoop = 1;
bool isConnected = false;

esp_mqtt_client_handle_t client;

static void request_conection(void *arg, void *usr_data)
{
    wifi_app_send_message(WIFI_APP_MSG_USER_REQUESTED_CONNECTION);
}

static void receved_msg(char *str_data)
{
    ESP_LOGI(TAG,"%s",str_data);
    sscanf(str_data, "{\"kp\":%f,\"ki\":%f,\"kd\":%f,\"setpoint\":%f,\"vmax\":%f,\"isClosedLoop\":%d}", &kp, &ki, &kd, &setpoint, &vmax, &isClosedLoop);
    ESP_LOGI(TAG,"{\"kp\":%f,\"ki\":%f,\"kd\":%f,\"setpoint\":%f,\"vmax\":%f,\"isClosedLoop\":%d}", kp, ki, kd, setpoint, vmax, isClosedLoop);

    if (isClosedLoop)
    {
        servo_motor_pid_update(&servo_motor_ctrl_ctx, kp, kd, ki);
        set_servo_motor_position(&servo_motor_ctrl_ctx, setpoint);
        // set_vmax_servo_motor(&servo_motor_ctrl_ctx, vmax);
    }
}

void send_msg(float position, float error, float output, float speed)
{
    char msg[200];
    sprintf(msg, "{\"position\":%f,\"error\":%f,\"output\":%f,\"speed\":%f}", position, error, output, speed);
    mqtt_app_send_msg(client, msg);
}

void wifi_application_connected_events(void)
{
    ESP_LOGI(TAG, "WiFi Application Connected!!");

    char device_name[] = "Position_0001";

    client = mqtt_app_start(&receved_msg, device_name);

    isConnected = true;
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

    button_connect = button_app_init(13, 1);

    resgister_event_callback(button_connect, BUTTON_LONG_PRESS_START, 8000, &request_conection, NULL);

    servo_motor_ctrl_ctx.pcnt_encoder = NULL;
    servo_motor_ctrl_ctx.pulses_per_rotation = 1632;
    servo_motor_ctrl_ctx.controlData.kp = kp;
    servo_motor_ctrl_ctx.controlData.ki = ki;
    servo_motor_ctrl_ctx.controlData.kd = kd;
    servo_motor_ctrl_ctx.controlData.error = 0;
    servo_motor_ctrl_ctx.controlData.output_control = 0;
    servo_motor_ctrl_ctx.size_gear = 13;

    gpio_num_t homeSensor = 34;
    esp_rom_gpio_pad_select_gpio(homeSensor);
    gpio_set_direction(homeSensor, GPIO_MODE_INPUT);

    motor_drive_config(&servo_motor_ctrl_ctx, 22, 23, 33, 32, 0, homeSensor);

    vTaskDelay(pdMS_TO_TICKS(1000));

    setpoint = 100;
    set_servo_motor_position(&servo_motor_ctrl_ctx, setpoint);

    while (true)
    {
        if (isClosedLoop && isConnected)
        {
            // send_msg(get_servo_motor_position(&servo_motor_ctrl_ctx), get_servo_motor_error(&servo_motor_ctrl_ctx), get_servo_motor_control_output(&servo_motor_ctrl_ctx), get_servo_motor_speed(&servo_motor_ctrl_ctx));
            ESP_LOGI(TAG, "Position %.2f mm", get_servo_motor_position(&servo_motor_ctrl_ctx));
            ESP_LOGI(TAG, "Velocidade %.2f RPM", get_servo_motor_speed(&servo_motor_ctrl_ctx));
            ESP_LOGI(TAG, "ERROR %f mm", get_servo_motor_error(&servo_motor_ctrl_ctx));
            ESP_LOGI(TAG, "OUTPUT %.3f %%\n\n\n", get_servo_motor_control_output(&servo_motor_ctrl_ctx));
        }
        vTaskDelay(pdMS_TO_TICKS(200));
    }
}