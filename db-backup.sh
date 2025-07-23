#!/bin/bash

set -e

# Загрузка .env
ENV_FILE="$(dirname "$0")/.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "$(date '+%F %T') [ERROR] .env file not found!" >> /var/log/db-backup.log
  exit 1
fi
source "$ENV_FILE"

# Подготовка переменных
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M') # Формат времени бэкапа
BACKUP_DIR="/opt/backups"           # Директория хранения бэкапа 
LOG_FILE="/var/log/db-backup.log"   # Директория хранения логов
mkdir -p "$BACKUP_DIR"              # Создать директорию для бэкапов

# Определяем какая у нас БД 
case "$DB_TYPE" in
  "postgres")
    DUMP_CMD="PGPASSWORD=\"$DB_PASSWORD\" pg_dump -U $DB_USER -h $DB_HOST -p $DB_PORT $DB_NAME"
    ;;
  "mariadb" | "mysql")
    DUMP_CMD="mysqldump -u$DB_USER -p$DB_PASSWORD -h $DB_HOST -P $DB_PORT $DB_NAME"
    ;;
  *)
    echo "$(date '+%F %T') [ERROR] Unsupported DB_TYPE: $DB_TYPE" >> "$LOG_FILE"
    exit 1
    ;;
esac

# Запуск дампа
FILENAME="${DB_NAME}-${TIMESTAMP}.sql.gz"
OUTPUT_PATH="${BACKUP_DIR}/${FILENAME}"

if eval "$DUMP_CMD" | gzip > "$OUTPUT_PATH"; then
  FILESIZE=$(du -h "$OUTPUT_PATH" | cut -f1)
  echo "$(date '+%F %T') [SUCCESS] Backup created: $FILENAME, Size: $FILESIZE" >> "$LOG_FILE"
else
  echo "$(date '+%F %T') [ERROR] Backup failed for $DB_NAME" >> "$LOG_FILE"
  exit 1
fi

# Удаление бэкапов, если их больше 7
cd "$BACKUP_DIR"
ls -1t "${DB_NAME}-"*.sql.gz | tail -n +8 | xargs -r rm -f
