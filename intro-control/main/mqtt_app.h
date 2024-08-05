#ifndef MQTT_APP_H_
#define MQTT_APP_H_

// Callback typedef
typedef void (*mqtt_recevied_msg_event_callback_t)(char *str_data);

#include "mqtt_client.h"

esp_mqtt_client_handle_t mqtt_app_start(mqtt_recevied_msg_event_callback_t cb, char *device_name);

void mqtt_app_send_msg(esp_mqtt_client_handle_t client, int msg);

#endif