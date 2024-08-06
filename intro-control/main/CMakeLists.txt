idf_component_register(SRCS "wifi_state_nvs.c" "button_app.c" "rgb_led.c" "wifi_app.c" "mqtt_app.c" "main.c" "servo_motor_drive.c"
                    INCLUDE_DIRS ".")

target_add_binary_data(${COMPONENT_TARGET} "isrgrootx1.pem" TEXT)
