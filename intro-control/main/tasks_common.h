#ifndef MAIN_TASKS_COMMON_H_
#define MAIN_TASKS_COMMON_H_

/**Priority task */
// WiFi application task
#define WIFI_APP_TASK_STACK_SIZE 4096
#define WIFI_APP_TASK_PRIORITY 0
#define WIFI_APP_TASK_CORE_ID 0

// RGB application task
#define RGB_APP_TASK_STACK_SIZE 2048
#define RGB_APP_TASK_PRIORITY 1
#define RGB_APP_TASK_CORE_ID 1

#endif /* MAIN_TASKS_COMMON_H_ */