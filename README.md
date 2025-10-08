# Lint Heroes

Проект для настройки и запуска линтеров Python кода с использованием менеджера пакетов `uv` и Docker.

## Описание

Lint Heroes - это набор инструментов для проверки качества Python кода, включающий в себя:

- **pylint** - статический анализатор кода
- **flake8** - линтер с поддержкой flake8-bugbear
- **bandit** - анализатор безопасности
- **mypy** - проверка типов
- **pyright** - быстрая проверка типов от Microsoft
- **isort** - сортировка импортов

## Структура проекта

```
lint_heroes/
├── pyproject.toml          # Конфигурация для isort, pyright, mypy
├── bandit.yaml            # Конфигурация bandit
├── pyrightconfig.json     # Конфигурация pyright
├── req.txt                # Зависимости проекта
├── macos/                 # Файлы для macOS/Linux
│   ├── installall.sh      # Скрипт установки
│   └── lint_all.sh        # Скрипт запуска линтеров
├── windows/               # Файлы для Windows
│   ├── installall.bat     # Скрипт установки (Batch)
│   ├── installall.ps1     # Скрипт установки (PowerShell)
│   ├── lint_all.bat       # Скрипт запуска линтеров (Batch)
│   ├── lint_all.ps1       # Скрипт запуска линтеров (PowerShell)
│   └── WINDOWS_SETUP.md   # Подробное руководство для Windows
├── .run/                  # Конфигурации PyCharm
│   ├── Lint All.run.xml
│   ├── Lint All Windows.run.xml
│   └── Lint All PowerShell.run.xml
└── README.md              # Документация
```

## Установка

### Предварительные требования

- Python 3.11+ (рекомендуется)
- Менеджер пакетов `uv`
- Docker (для работы в контейнерах)

### Выбор версии Python

#### Интерактивный выбор версии

При запуске скриптов установки вы увидите список доступных версий Python и сможете выбрать нужную:

```
Available Python versions:
  1. python3.11 (Python 3.11.0) at /usr/bin/python3.11
  2. python3.12 (Python 3.12.0) at /usr/bin/python3.12
  3. python3.10 (Python 3.10.0) at /usr/bin/python3.10

Select Python version for linting tools:
Enter number (1-3) or press Enter for default (1):
```

#### Установка для нескольких версий Python

**macOS/Linux:**
```bash
# Интерактивная установка для нескольких версий
./macos/install_multiple.sh

# Или через алиас
lint-multi
```

**Windows:**
```powershell
# Интерактивная установка для нескольких версий
.\windows\install_multiple.ps1

# Или через алиас
lint-multi
```

#### Принудительный выбор версии

**macOS/Linux:**
```bash
# Указать конкретную версию
PY_BIN=python3.11 ./macos/installall.sh
```

**Windows PowerShell:**
```powershell
# Указать конкретную версию
.\windows\installall.ps1 -PythonPath python3.11
```

### Установка зависимостей

#### macOS/Linux
```bash
# Установка всех линтеров
./macos/installall.sh

# Запуск линтеров
./macos/lint_all.sh

# Или установка через uv
uv pip install -r req.txt
```

#### Windows

**Вариант 1: Batch файл (простой)**
```cmd
# Запуск установки
windows\installall.bat

# Запуск линтеров
windows\lint_all.bat

# Линтинг конкретного файла
windows\lint_all.bat path\to\file.py
```

**Вариант 2: PowerShell (рекомендуется)**
```powershell
# Запуск установки
.\windows\installall.ps1

# Запуск линтеров
.\windows\lint_all.ps1

# Линтинг конкретного файла
.\windows\lint_all.ps1 path\to\file.py
```

**Вариант 3: Через uv**
```cmd
# Установка через uv
uv pip install -r req.txt

# Установка pyright через npm
npm install -g pyright
```

**Подробное руководство для Windows:** см. `windows/WINDOWS_SETUP.md`

## Алиасы для удобного использования

После установки скрипты автоматически создают алиасы для вызова из любого места в терминале:

### macOS/Linux
```bash
# Алиасы добавляются в ~/.zshrc, ~/.bashrc или ~/.bash_profile
lint-heroes              # Запуск всех линтеров
lint-install             # Переустановка линтеров для текущей версии Python
lint-install-multiple     # Установка для нескольких версий Python
lint                     # Короткий алиас для lint-heroes
lint-multi               # Короткий алиас для lint-install-multiple

# Примеры использования:
lint-heroes                    # Проверка текущей директории
lint-heroes src/main.py        # Проверка конкретного файла
lint src/                      # Проверка директории
lint-multi                     # Установка для нескольких версий Python
```

### Windows

**Batch файлы:**
```cmd
# Алиасы создаются в %USERPROFILE%\bin\
lint-heroes              # Запуск всех линтеров
lint-install             # Переустановка линтеров для текущей версии Python
lint-install-multiple     # Установка для нескольких версий Python
lint                     # Короткий алиас для lint-heroes
lint-multi               # Короткий алиас для lint-install-multiple

# Примеры использования:
lint-heroes                    # Проверка текущей директории
lint-heroes src\main.py        # Проверка конкретного файла
lint src\                      # Проверка директории
lint-multi                     # Установка для нескольких версий Python
```

**PowerShell функции:**
```powershell
# Функции добавляются в PowerShell профиль
lint-heroes              # Запуск всех линтеров
lint-install             # Переустановка линтеров для текущей версии Python
lint-install-multiple     # Установка для нескольких версий Python
lint                     # Короткий алиас для lint-heroes
lint-multi               # Короткий алиас для lint-install-multiple

# Примеры использования:
lint-heroes                    # Проверка текущей директории
lint-heroes src\main.py        # Проверка конкретного файла
lint src\                      # Проверка директории
lint-multi                     # Установка для нескольких версий Python
```

### Активация алиасов

**macOS/Linux:**
```bash
# Перезагрузить профиль
source ~/.zshrc    # для zsh
source ~/.bashrc   # для bash
# или просто перезапустить терминал
```

**Windows:**
```cmd
# Для Batch файлов - добавить в PATH:
setx PATH "%PATH%;%USERPROFILE%\bin"
# или перезапустить терминал
```

```powershell
# Для PowerShell - перезагрузить профиль:
Import-Module $PROFILE
# или перезапустить PowerShell
```

## Конфигурация

### pyproject.toml

Основной файл конфигурации содержит настройки для:

- **isort**: Сортировка импортов с профилем "black", длина строки 120 символов
- **pyright**: Строгая проверка типов для Python 3.11
- **mypy**: Настройки проверки типов с игнорированием отсутствующих импортов
- **flake8**: Максимальная длина строки 150 символов

### bandit.yaml

Конфигурация безопасности:
- Пропуск проверки B311 (random)
- Исключение директорий: .venv, venv, build, dist, .mypy_cache, .pytest_cache, .idea, .git

### pyrightconfig.json

Конфигурация pyright:
- Строгий режим проверки типов
- Включение директории `src`
- Исключение тестов и кэш-директорий

## Использование

### Запуск всех линтеров

#### macOS/Linux
```bash
# Проверка текущей директории
./macos/lint_all.sh

# Проверка конкретного файла
./macos/lint_all.sh path/to/file.py

# Проверка конкретной директории
./macos/lint_all.sh path/to/directory/
```

#### Windows

**Batch файл:**
```cmd
# Проверка текущей директории
windows\lint_all.bat

# Проверка конкретного файла
windows\lint_all.bat path\to\file.py

# Проверка конкретной директории
windows\lint_all.bat path\to\directory\
```

**PowerShell:**
```powershell
# Проверка текущей директории
.\windows\lint_all.ps1

# Проверка конкретного файла
.\windows\lint_all.ps1 path\to\file.py

# Проверка конкретной директории
.\windows\lint_all.ps1 path\to\directory\
```

### Отдельные линтеры

```bash
# isort (сортировка импортов)
isort .

# pylint
pylint your_file.py

# flake8
flake8 your_file.py

# bandit (проверка безопасности)
bandit -r .

# mypy (проверка типов)
mypy your_file.py

# pyright (быстрая проверка типов)
pyright your_file.py
```

## Настройка IDE

### PyCharm

Проект включает конфигурации для PyCharm:
- **macOS/Linux**: `.run/Lint All.run.xml`
- **Windows Batch**: `.run/Lint All Windows.run.xml`
- **Windows PowerShell**: `.run/Lint All PowerShell.run.xml`

Выберите подходящую конфигурацию в зависимости от вашей ОС.

### VS Code

Для VS Code рекомендуется установить расширения:
- Python
- Pylint
- MyPy Type Checker
- Python Docstring Generator

**Настройка для Windows:**
```json
// settings.json
{
    "python.defaultInterpreterPath": ".venv\\Scripts\\python.exe",
    "python.terminal.activateEnvironment": true,
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "python.linting.flake8Enabled": true,
    "python.linting.banditEnabled": true,
    "python.linting.mypyEnabled": true
}
```

## Работа с несколькими версиями Python

### Установка для нескольких версий

После установки для нескольких версий Python у вас будет несколько виртуальных окружений:

```
.venv-3.11/          # Линтеры для Python 3.11
.venv-3.12/          # Линтеры для Python 3.12
.venv-3.10/          # Линтеры для Python 3.10
```

### Использование линтеров для конкретной версии

**macOS/Linux:**
```bash
# Активация окружения для Python 3.11
source .venv-3.11/bin/activate
pylint your_file.py
deactivate

# Активация окружения для Python 3.12
source .venv-3.12/bin/activate
pylint your_file.py
deactivate
```

**Windows:**
```cmd
# Активация окружения для Python 3.11
.venv-3.11\Scripts\activate.bat
pylint your_file.py
deactivate

# Активация окружения для Python 3.12
.venv-3.12\Scripts\activate.bat
pylint your_file.py
deactivate
```

**Windows PowerShell:**
```powershell
# Активация окружения для Python 3.11
& .venv-3.11\Scripts\Activate.ps1
pylint your_file.py
deactivate

# Активация окружения для Python 3.12
& .venv-3.12\Scripts\Activate.ps1
pylint your_file.py
deactivate
```

### Автоматическое переключение версий

Создайте скрипты для быстрого переключения:

**macOS/Linux:**
```bash
# Создать скрипт lint-311.sh
#!/bin/bash
source .venv-3.11/bin/activate
pylint "$@"
deactivate

# Создать скрипт lint-312.sh
#!/bin/bash
source .venv-3.12/bin/activate
pylint "$@"
deactivate
```

**Windows:**
```cmd
# Создать lint-311.bat
@echo off
call .venv-3.11\Scripts\activate.bat
pylint %*
deactivate

# Создать lint-312.bat
@echo off
call .venv-3.12\Scripts\activate.bat
pylint %*
deactivate
```

## Docker

Проект настроен для работы в Docker контейнерах. Все проверки должны выполняться в контейнерах для обеспечения консистентности окружения.

## Зависимости

Основные зависимости (из req.txt):
- **aiobotocore** (2.24.2) - асинхронный клиент AWS
- **aiohttp** (3.12.15) - асинхронный HTTP клиент
- **bandit** (1.8.6) - анализатор безопасности
- **flake8** (7.3.0) - линтер кода
- **flake8-bugbear** (24.12.12) - дополнительные правила для flake8
- **isort** (6.0.1) - сортировка импортов
- **mypy** (1.17.1) - проверка типов
- **pylint** (3.3.8) - статический анализатор
- **pyspark** (3.5.3) - Apache Spark для Python
- **pandas** (2.3.3) - работа с данными
- **numpy** (2.3.3) - численные вычисления


## Troubleshooting

### Проблемы с установкой

#### macOS/Linux
```bash
# Очистка виртуального окружения
rm -rf .venv
./macos/installall.sh
```

#### Windows
```cmd
# Очистка виртуального окружения
rmdir /s .venv
windows\installall.bat
```

```powershell
# Очистка виртуального окружения
Remove-Item -Recurse -Force .venv
.\windows\installall.ps1
```

### Проблемы с Docker

```bash
# Пересборка контейнера
docker-compose down
docker-compose build --no-cache
docker-compose up
```

### Проблемы с линтерами

#### macOS/Linux
```bash
# Проверка установки линтеров
which pylint flake8 bandit mypy pyright

# Обновление линтеров
uv pip install --upgrade pylint flake8 bandit mypy
```

#### Windows
```cmd
# Проверка установки линтеров
where pylint flake8 bandit mypy pyright

# Обновление линтеров
uv pip install --upgrade pylint flake8 bandit mypy
```

```powershell
# Проверка установки линтеров
Get-Command pylint, flake8, bandit, mypy, pyright

# Обновление линтеров
uv pip install --upgrade pylint flake8 bandit mypy
```

### Windows-специфичные проблемы

#### Проблемы с PowerShell Execution Policy
```powershell
# Если скрипты не запускаются
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Или для одного раза
PowerShell -ExecutionPolicy Bypass -File .\installall.ps1
```

#### Проблемы с путями
```cmd
# Убедитесь, что Python в PATH
python --version
pip --version

# Если не работает, добавьте в PATH:
# C:\Python311\Scripts\
# C:\Python311\
```

#### Проблемы с npm/pyright
```cmd
# Установка Node.js и npm
# Скачайте с https://nodejs.org/

# Проверка установки
node --version
npm --version

# Установка pyright
npm install -g pyright
```

### Проблемы с версиями Python

#### Неправильная версия Python
```bash
# macOS/Linux - принудительный выбор версии
PY_BIN=python3.11 ./macos/installall.sh

# Windows PowerShell - принудительный выбор версии
.\windows\installall.ps1 -PythonPath python3.11
```

#### Конфликт версий Python
```bash
# Проверка доступных версий
which python3.11 python3.12 python3.10 python3.9 python3

# Windows
where python3.11 python3.12 python3.10 python3.9 python3
```

#### Проблемы с виртуальным окружением
```bash
# Удаление старого окружения и пересоздание
rm -rf .venv
PY_BIN=python3.11 ./macos/installall.sh

# Windows
rmdir /s .venv
.\windows\installall.ps1 -PythonPath python3.11
```

#### Установка нужной версии Python

**macOS:**
```bash
# Через Homebrew
brew install python@3.11

# Через pyenv
pyenv install 3.11.0
pyenv global 3.11.0
```

**Windows:**
```cmd
# Скачать с python.org
# https://www.python.org/downloads/release/python-3110/
```

## Лицензия

Проект использует MIT лицензию.
