#!/bin/bash
# Скрипт для аутентификации в Container Registry через сервисный аккаунт

# Читаем ключ из JSON файла
SERVICE_ACCOUNT_ID=$(cat authorized_key.json | grep service_account_id | cut -d'"' -f4)
ACCESS_KEY_ID=$(cat authorized_key.json | grep key_id | cut -d'"' -f4)
PRIVATE_KEY=$(cat authorized_key.json | grep private_key | cut -d'"' -f4)

# Создаем JWT токен для аутентификации
echo "Аутентификация в Container Registry..."
docker login --username iam --password "$(yc iam create-token)" cr.yandex.ru