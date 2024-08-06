#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>

#include "freertos/FreeRTOS.h"
#include "freertos/event_groups.h"
#include "freertos/task.h"

#include "esp_log.h"
#include "esp_event.h"
#include "esp_timer.h"

#include "driver/ledc.h"

#include "rgb_led.h"
#include "tasks_common.h"

/*
    initializes the RGB LED settings per channel, including
    the GPIO for each color, mode and timer configuration.
*/

bool pwm_init_handle = false;
bool light = false;

// Queue handle used to manipulate the main queue of events
static QueueHandle_t rgb_app_queue_handle;

ledc_info_t led_ch[RGB_LED_CHANNEL_NUM];

static void rgb_led_pwm_init(void)
{
    int rgb_ch;

    // Red
    led_ch[0].channel = LEDC_CHANNEL_0;
    led_ch[0].gpio = RGB_LED_RED_GPIO;
    led_ch[0].mode = LEDC_LOW_SPEED_MODE;
    led_ch[0].timer_index = LEDC_TIMER_0;

    // GREEN
    led_ch[1].channel = LEDC_CHANNEL_1;
    led_ch[1].gpio = RGB_LED_GREEN_GPIO;
    led_ch[1].mode = LEDC_LOW_SPEED_MODE;
    led_ch[1].timer_index = LEDC_TIMER_0;

    // BLUE
    led_ch[2].channel = LEDC_CHANNEL_2;
    led_ch[2].gpio = RGB_LED_BLUE_GPIO;
    led_ch[2].mode = LEDC_LOW_SPEED_MODE;
    led_ch[2].timer_index = LEDC_TIMER_0;

    // Configure timer
    ledc_timer_config_t ledc_timer = {
        .duty_resolution = LEDC_TIMER_8_BIT,
        .freq_hz = 100,
        .speed_mode = LEDC_LOW_SPEED_MODE,
        .timer_num = LEDC_TIMER_0};

    ledc_timer_config(&ledc_timer);

    // config channels
    for (rgb_ch = 0; rgb_ch < RGB_LED_CHANNEL_NUM; rgb_ch++)
    {
        ledc_channel_config_t ledc_channel = {
            .channel = led_ch[rgb_ch].channel,
            .duty = 0,
            .hpoint = 0,
            .gpio_num = led_ch[rgb_ch].gpio,
            .intr_type = LEDC_INTR_DISABLE,
            .speed_mode = led_ch[rgb_ch].mode,
            .timer_sel = led_ch[rgb_ch].timer_index,
        };

        ledc_channel_config(&ledc_channel);
    }

    pwm_init_handle = true;
}

// sets the RGB color
static void rgb_led_set_color(uint8_t red, uint8_t green, uint8_t blue)
{
    // value should be 0 - 255 for 8 bit number
    ledc_set_duty(led_ch[0].mode, led_ch[0].channel, red);
    ledc_update_duty(led_ch[0].mode, led_ch[0].channel);

    ledc_set_duty(led_ch[1].mode, led_ch[1].channel, green);
    ledc_update_duty(led_ch[1].mode, led_ch[1].channel);

    ledc_set_duty(led_ch[2].mode, led_ch[2].channel, blue);
    ledc_update_duty(led_ch[2].mode, led_ch[2].channel);
}

BaseType_t rgb_app_send_message(rgb_app_message_e msgID)
{
    rgb_app_queue_message_t msg;
    msg.msgID = msgID;
    return xQueueSend(rgb_app_queue_handle, &msg, portMAX_DELAY);
}

// Color to indicate WiFi aplication has started
void rgb_led_wifi_app_started(void)
{
    rgb_app_send_message(RGB_APP_MSG_WIFI_STARTED);
}

void rgb_led_off(void)
{
    rgb_app_send_message(RGB_APP_MSG_OFF);
}

// Color to indicate Wifi is connected
void rgb_led_wifi_connected(void)
{
    rgb_app_send_message(RGB_APP_MSG_CONNECTED);
}

// Color to indicate Wifi has problem with pass
void rgb_led_wifi_problem(void)
{
    rgb_app_send_message(RGB_APP_MSG_PROBLEM);
}

static void rgb_app_task(void *pvParameters)
{
    rgb_app_queue_message_t msg;

    while (true)
    {
        if (xQueueReceive(rgb_app_queue_handle, &msg, portMAX_DELAY))
        {
            switch (msg.msgID)
            {
            case RGB_APP_MSG_OFF:
                rgb_led_set_color(0, 0, 0);
                break;
            case RGB_APP_MSG_WIFI_STARTED:
                rgb_led_set_color(0, 50, 0);
                vTaskDelay(pdMS_TO_TICKS(1000));
                break;
            case RGB_APP_MSG_CONNECTED:
                rgb_led_set_color(0, 50, 50);
                vTaskDelay(pdMS_TO_TICKS(2000));
                rgb_led_off();
                break;

            case RGB_APP_MSG_PROBLEM:
                for (int i = 0; i < 15; i++)
                {
                    rgb_led_set_color(50, 50, 0);
                    vTaskDelay(pdMS_TO_TICKS(1000));
                    rgb_led_set_color(0, 0, 0);
                    vTaskDelay(pdMS_TO_TICKS(1000));
                }
                break;
            }
        }
    }
}

void rgb_led_init(void)
{
    rgb_led_pwm_init();

    // Create message queue
    rgb_app_queue_handle = xQueueCreate(10, sizeof(rgb_app_queue_message_t));

    // Start the WiFi application task
    xTaskCreate(&rgb_app_task, "rgb_app_task", RGB_APP_TASK_STACK_SIZE, NULL, RGB_APP_TASK_PRIORITY, NULL);
}
