#ifndef WIFI_APP_H_
#define WIFI_APP_H_

#include "freertos/FreeRTOS.h"

#define MAX_CONNECTION_RETRIES 5

// Callback typedef
typedef void (*wifi_event_callback_t)(void);

/**
 * Message IDs for the WiFi application task
 * @note Expand this based on your application requirements.
 */
typedef enum wifi_app_message
{
	WIFI_APP_MSG_NONE,
	WIFI_APP_MSG_SMART_CONFIG_START,
	WIFI_APP_MSG_SMART_CONFIG_CRED_RECV,
	WIFI_APP_MSG_SMART_CONFIG_DONE,
	WIFI_APP_MSG_STA_CONNECTED_GOT_IP,
	WIFI_APP_MSG_STA_DISCONNECTED,
	WIFI_APP_MSG_USER_REQUESTED_CONNECTION,
} wifi_app_message_e;

/**
 * Structure for the message queue
 * @note Expand this based on application requirements e.g. add another type and parameter as required
 */
typedef struct wifi_app_queue_message
{
	wifi_app_message_e msgID;
} wifi_app_queue_message_t;

/**
 * Sends a message to the queue
 * @param msgID message ID from the wifi_app_message_e enum.
 * @return pdTRUE if an item was successfully sent to the queue, otherwise pdFALSE.
 * @note Expand the parameter list based on your requirements e.g. how you've expanded the wifi_app_queue_message_t.
 */
BaseType_t wifi_app_send_message(wifi_app_message_e msgID);

/**
 * Starts the WiFi task
 */
void wifi_app_start(wifi_event_callback_t cb);

#endif