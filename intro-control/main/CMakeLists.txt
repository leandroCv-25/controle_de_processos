idf_component_register(SRCS "button_app.c" "rgb_led.c" "wifi_app.c" "mqtt_app.c" "motor_drive.c" "main.c"
                    INCLUDE_DIRS ".")

target_add_binary_data(${COMPONENT_TARGET} "isrgrootx1.pem" TEXT)
