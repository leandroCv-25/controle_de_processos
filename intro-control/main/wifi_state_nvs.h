#ifndef WIFI_STATE_NVS_H_s
#define WIFI_STATE_NVS_H_

#include "esp_err.h"

/**
 * Saves wifi state on NVS
 * @return ESP_OK if successful.
 */
esp_err_t save_wifi_state_nvs(int state);

/**
 * Loads the previously saved wifi state from NVS.
 * @return the state previously saved or 0.
 */
int load_wifi_state_nvs(void);

#endif /* WIFI_STATE_NVS_H_ */
