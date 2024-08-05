#ifndef RGB_LED_H_
#define RGB_LED_H_
// RGB LED GPIOs
#define RGB_LED_RED_GPIO 14
#define RGB_LED_GREEN_GPIO 12
#define RGB_LED_BLUE_GPIO 13

// RGB LED Color mix channels
#define RGB_LED_CHANNEL_NUM 3

// RGB LED configuration
typedef struct
{
    int channel;
    int gpio;
    int mode;
    int timer_index;
} ledc_info_t;

typedef enum rgb_app_message
{
    RGB_APP_MSG_OFF,
    RGB_APP_MSG_WIFI_STARTED,
    RGB_APP_MSG_CONNECTED,
    RGB_APP_MSG_PROBLEM,
} rgb_app_message_e;

typedef struct rgb_app_queue_message
{
    rgb_app_message_e msgID;
} rgb_app_queue_message_t;

// Color to indicate WiFi aplication has started or disconnected
void rgb_led_wifi_app_started(void);

// Color to indicate Wifi is connected
void rgb_led_wifi_connected(void);

// Color to indicate Wifi is connecting
void rgb_led_wifi_connecting(void);

// Color to indicate Wifi has problem with pass
void rgb_led_wifi_problem(void);

// RGB Led trun off
void rgb_led_off(void);

void rgb_led_init(void);

#endif