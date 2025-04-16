#!/bin/sh

echo "Activating SSH server...";
service ssh start && bash
if [ "$APP_ENV" = "local" ]; then
  echo "Running in local environment..."
  if [ "$APP_TASK" = "api" ]; then
    echo "Running API"
    php artisan serve --host=0.0.0.0 --port=8000
  elif [ "$APP_TASK" = "consume" ]; then
    echo "Running consumer"
    php artisan queue:work
  else
    echo "Invalid environment: APP_ENV: $APP_ENV | APP_TASK: $APP_TASK. Shutting down the container."
    exit 1
  fi
elif [ "$APP_ENV" = "stage" ]; then
  if [ "$APP_TASK" = "api" ]; then
    echo "Running API"
    php-fpm -D && nginx -g 'daemon off;'
  elif [ "$APP_TASK" = "api-swoole" ]; then
    echo "Running swoole..."
    php /var/www/html/artisan octane:start --server=swoole --host=0.0.0.0 --port=5050

  elif [ "$APP_TASK" = "consume" ]; then
    echo "Running consumer"
    php artisan queue:work
  else
    echo "Invalid environment: APP_ENV: $APP_ENV | APP_TASK: $APP_TASK. Shutting down the container."
    exit 1
  fi
elif [ "$APP_ENV" = "production" ]; then
  if [ "$APP_TASK" = "api" ]; then
    echo "Running API"
    php-fpm -D && nginx -g 'daemon off;'
  elif [ "$APP_TASK" = "api-swoole" ]; then
    echo "Running swoole..."
    php /var/www/html/artisan octane:start --server=swoole --host=0.0.0.0 --port=5050  
  elif [ "$APP_TASK" = "consume" ]; then
    echo "Running consumer"
    php artisan queue:work
  else
    echo "Invalid environment: APP_ENV: $APP_ENV | APP_TASK: $APP_TASK. Shutting down the container."
    exit 1
  fi
else
  echo "Invalid environment: APP_ENV: $APP_ENV | APP_TASK: $APP_TASK. Shutting down the container."
fi
