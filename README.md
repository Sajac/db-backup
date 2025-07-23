# БД бэкап скрипт

Автоматический бэкап баз данных PostgreSQL и MariaDB.

## Назначение

Скрипт `db-backup.sh` создает сжатые дампы базы данных, сохраняет их в `/opt/backups`, логирует действия и хранит только последние 7 дампов, удаляя более старые.

По умолчанию:
Бэкапы хранятся в каталоге `/opt/backups`
Логи хранятся в файле `/opt/backups`
## Настройка .env

Создайте файл `.env` в папке со скриптом:
```
DB_TYPE=postgres        # Тип базы данных (БД): postgres или mariadb
DB_HOST=localhost       # Адрес БД localhost или ip сервера (если другой сервер)
DB_PORT=5432            # Порт подключения к БД Postgres - 5432, MariaDB - 3306 (стандартные порты)
DB_USER=postgres        # Учетная запись для подключения к БД
DB_PASSWORD=secret      # Пароль от учетной записи 
DB_NAME=mydatabase      # Название БД
```

## Установка зависимостей

Убедитесь, что установлены утилиты:

Для PostgreSQL: pg_dump (пакет postgresql-client)
Для MariaDB: mysqldump  (пакет mariadb-client)
Также нужен gzip, bash

Проверить что пакет установлен:
```
dpkg -l | grep -E 'postgresql-client|mariadb-client|gzip'
```
Если пакеты не установлены, то устанавливаем

```
sudo apt update
sudo apt install postgresql-client mariadb-client gzip
```

## Пример логов

```log
2025-07-23 14:01:12 [SUCCESS] Backup created: mydatabase-2025-07-23_14-01.sql.gz, Size: 15M
2025-07-23 14:05:12 [ERROR] Backup failed for mydatabase
2025-07-23 14:10:33 [SUCCESS] Backup created: mydatabase-2025-07-23_14-10.sql.gz, Size: 16M
```

## Добавление скрипта в cron 

Откройте crontab:
```
crontab -e
```

Добавьте строку:
```
0 2 * * * /path/to/db-backup.sh >> /var/log/db-backup.log 2>&1
```
Это запустит скрипт каждый день в 2:00 ночи.

