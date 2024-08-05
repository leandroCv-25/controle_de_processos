#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>

#include "esp_system.h"
#include "nvs_flash.h"
#include "esp_event.h"
#include "esp_netif.h"
#include "esp_log.h"

#include "mqtt_client.h"

#include "mqtt_app.h"
#include "rgb_led.h"

static const char *TAG = "mqtt";

extern const uint8_t mqtt_cert_io_pem_start[] asm("_binary_isrgrootx1_pem_start");
extern const uint8_t mqtt_cert_io_pem_end[] asm("_binary_isrgrootx1_pem_end");

char control_data[28];
char current_data[28];

void mqtt_app_recevied_msg(char *str_data);

mqtt_recevied_msg_event_callback_t mqtt_recevied_msg_event_cb;

static void mqtt_event_handler(void *handler_args, esp_event_base_t base, int32_t event_id, void *event_data)
{
    ESP_LOGD(TAG, "Event dispatched from event loop base=%s, event_id=%ld", base, event_id);
    esp_mqtt_event_handle_t event = event_data;
    esp_mqtt_client_handle_t client = event->client;
    int msg_id;
    switch ((esp_mqtt_event_id_t)event_id)
    {
    case MQTT_EVENT_CONNECTED:
        ESP_LOGI(TAG, "MQTT_EVENT_CONNECTED");
        msg_id = esp_mqtt_client_subscribe(client, control_data, 1);
        ESP_LOGI(TAG, "sent subscribe successful, msg_id=%d", msg_id);

        // msg_id = esp_mqtt_client_unsubscribe(client, "/topic/qos1");
        // ESP_LOGI(TAG, "sent unsubscribe successful, msg_id=%d", msg_id);
        break;
    case MQTT_EVENT_DISCONNECTED:
        ESP_LOGI(TAG, "MQTT_EVENT_DISCONNECTED");
        rgb_led_wifi_problem();
        break;

    case MQTT_EVENT_SUBSCRIBED:
        ESP_LOGI(TAG, "MQTT_EVENT_SUBSCRIBED, msg_id=%d", event->msg_id);
        break;
    case MQTT_EVENT_UNSUBSCRIBED:
        ESP_LOGI(TAG, "MQTT_EVENT_UNSUBSCRIBED, msg_id=%d", event->msg_id);
        break;
    case MQTT_EVENT_PUBLISHED:
        ESP_LOGI(TAG, "MQTT_EVENT_PUBLISHED, msg_id=%d", event->msg_id);
        break;
    case MQTT_EVENT_DATA:
        ESP_LOGI(TAG, "MQTT_EVENT_DATA");
        printf("TOPIC=%.*s\r\n", event->topic_len, event->topic);
        printf("DATA=%.*s\r\n", event->data_len, event->data);

        mqtt_app_recevied_msg(event->data);

        break;
    case MQTT_EVENT_ERROR:
        ESP_LOGI(TAG, "MQTT_EVENT_ERROR");
        if (event->error_handle->error_type == MQTT_ERROR_TYPE_TCP_TRANSPORT)
        {
            ESP_LOGI(TAG, "Last error code reported from esp-tls: 0x%x", event->error_handle->esp_tls_last_esp_err);
            ESP_LOGI(TAG, "Last tls stack error number: 0x%x", event->error_handle->esp_tls_stack_err);
            ESP_LOGI(TAG, "Last captured errno : %d (%s)", event->error_handle->esp_transport_sock_errno,
                     strerror(event->error_handle->esp_transport_sock_errno));
        }
        else if (event->error_handle->error_type == MQTT_ERROR_TYPE_CONNECTION_REFUSED)
        {
            ESP_LOGI(TAG, "Connection refused error: 0x%x", event->error_handle->connect_return_code);
        }
        else
        {
            ESP_LOGI(TAG, "Unknown error type: 0x%x", event->error_handle->error_type);
        }
        break;
    default:
        ESP_LOGI(TAG, "Other event id:%d", event->event_id);
        break;
    }
}

void mqtt_app_send_msg(esp_mqtt_client_handle_t client, char* msg)
{
    int msg_id = esp_mqtt_client_publish(client, current_data, msg, 1, 1, 300);
    ESP_LOGI(TAG, "sent publish successful, msg_id=%d", msg_id);
}

void mqtt_app_recevied_msg(char *str_data)
{
    if (mqtt_recevied_msg_event_cb)
    {
        mqtt_recevied_msg_event_cb("Data");
    }
}

esp_mqtt_client_handle_t mqtt_app_start(mqtt_recevied_msg_event_callback_t cb, char *device_name)
{

    mqtt_recevied_msg_event_cb = cb;

    snprintf(control_data, 28, "/%s/controler",
             device_name);

    snprintf(current_data, 28, "/%s/data",
             device_name);

    ESP_LOGI(TAG, "Controle %s", control_data);

    esp_mqtt_client_config_t mqtt_cfg = {
        // .broker.address.transport = MQTT_TRANSPORT_OVER_WSS,
        .broker.address.uri = "mqtts://4138b3edeec543a6853636401d12dfdf.s2.eu.hivemq.cloud",
        .broker.address.port = 8883,
        .session.protocol_ver = MQTT_PROTOCOL_V_3_1_1,
        .broker.verification.certificate = (const char *)mqtt_cert_io_pem_start,
        // .network.disable_auto_reconnect = true,
        .credentials.client_id = device_name,
        .credentials.username = "loboCv",
        .credentials.authentication.password = "123456789",
        .session.keepalive = 60,
        .session.disable_clean_session = false,
        .session.disable_keepalive = false,
        .session.last_will.qos = 0,
        .session.last_will.retain = true,
    };

    esp_mqtt_client_handle_t client = esp_mqtt_client_init(&mqtt_cfg);

    esp_mqtt_client_register_event(client, ESP_EVENT_ANY_ID, mqtt_event_handler, NULL);
    esp_mqtt_client_start(client);

    return client;
}