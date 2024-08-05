#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#include "esp_log.h"
#include "nvs_flash.h"

#include "wifi_state_nvs.h"
#include "wifi_app.h"

// Tag for logging to the monitor
static const char TAG[] = "nvs";

// NVS name space used for station mode credentials
const char app_nvs_state_wifi_namespace[] = "wifi_state";

esp_err_t save_wifi_state_nvs(int state)
{
	nvs_handle handle;
	esp_err_t esp_err;
	ESP_LOGI(TAG, "save_wifi_state_nvs: Saving state to flash");

	esp_err = nvs_open(app_nvs_state_wifi_namespace, NVS_READWRITE, &handle);
	if (esp_err != ESP_OK)
	{
		printf("save_wifi_state_nvs: Error (%s) opening NVS handle!\n", esp_err_to_name(esp_err));
		return esp_err;
	}

	// Set state
	esp_err = nvs_set_blob(handle, "state", &state, sizeof(state));
	if (esp_err != ESP_OK)
	{
		printf("save_wifi_state_nvs: Error (%s) setting stato to NVS!\n", esp_err_to_name(esp_err));
		return esp_err;
	}

	// Commit credentials to NVS
	esp_err = nvs_commit(handle);
	if (esp_err != ESP_OK)
	{
		printf("save_wifi_state_nvs: Error (%s) comitting state to NVS!\n", esp_err_to_name(esp_err));
		return esp_err;
	}
	nvs_close(handle);
	ESP_LOGI(TAG, "save_wifi_state_nvs: wrote state: %i", state);

	printf("save_wifi_state_nvs: returned ESP_OK\n");
	return ESP_OK;
}

int load_wifi_state_nvs(void)
{
	nvs_handle handle;
	esp_err_t esp_err;

	ESP_LOGI(TAG, "load_wifi_state_nvs: Loading Wifi state from flash");

	if (nvs_open(app_nvs_state_wifi_namespace, NVS_READONLY, &handle) == ESP_OK)
	{
		int state = 0;

		size_t state_size = sizeof(state);
		esp_err = nvs_get_blob(handle, "state", &state, &state_size);
		if (esp_err != ESP_OK)
		{
			printf("load_wifi_state_nvs: (%s) no state found in NVS\n", esp_err_to_name(esp_err));
			return state;
		}

		nvs_close(handle);

		printf("load_wifi_state_nvs: state: %i\n", state);
		return state;
	}
	else
	{
		return 0;
	}
}
