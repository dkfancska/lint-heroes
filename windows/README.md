# Windows скрипты

Эта папка содержит скрипты для установки и запуска линтеров на Windows.

## Файлы

### Установщик
- `install_universal.bat` - ✅ Универсальный установщик для любой Windows машины

### Скрипты линтинга
- `lint_all.bat` - ✅ Скрипт запуска линтеров (Batch)
- `lint_all.ps1` - ✅ Скрипт запуска линтеров (PowerShell)

### Конфигурация
- `bandit.yaml` - ✅ Конфигурация bandit
- `pyproject.toml` - ✅ Конфигурация проекта
- `pyrightconfig.json` - ✅ Конфигурация pyright

## Использование

### Установка

**Универсальный установщик:**
```cmd
# Из корневой папки проекта
windows\install_universal.bat
```

### Запуск линтеров

**Прямой вызов:**

Batch файл:
```cmd
# Проверка текущей директории
windows\lint_all.bat

# Проверка конкретного файла
windows\lint_all.bat path\to\file.py

# Проверка конкретной директории
windows\lint_all.bat path\to\directory\
```

PowerShell:
```powershell
# Проверка текущей директории
.\windows\lint_all.ps1

# Проверка конкретного файла
.\windows\lint_all.ps1 path\to\file.py

# Проверка конкретной директории
.\windows\lint_all.ps1 path\to\directory\
```

**Через алиасы (после установки):**

Batch файлы:
```cmd
# Алиасы автоматически создаются при установке
lint-heroes                    # Проверка текущей директории
lint-heroes src\main.py        # Проверка конкретного файла
lint src\                      # Проверка директории (короткий алиас)
lint-install                   # Переустановка линтеров
```

PowerShell функции:
```powershell
# Функции автоматически создаются при установке
lint-heroes                    # Проверка текущей директории
lint-heroes src\main.py        # Проверка конкретного файла
lint src\                      # Проверка директории (короткий алиас)
lint-install                   # Переустановка линтеров
```

### Активация алиасов

**Batch файлы:**
```cmd
# Добавить в PATH:
setx PATH "%PATH%;%USERPROFILE%\bin"
# или перезапустить терминал
```

**PowerShell:**
```powershell
# Перезагрузить профиль:
Import-Module $PROFILE
# или перезапустить PowerShell
```

## Требования

- Python 3.9+ (рекомендуется 3.11+)
- pip
- PowerShell 5.0+ (для PowerShell скриптов)
- Node.js и npm (опционально, для pyright)

## Что устанавливается

- pylint
- flake8 + flake8-bugbear
- bandit
- mypy
- pyright (через npm)
- isort

## Конфигурация

Скрипты автоматически создают конфигурационные файлы:
- `.pylintrc` - конфигурация pylint
- `.flake8` - конфигурация flake8
- `bandit.yaml` - конфигурация bandit
- `pyrightconfig.json` - конфигурация pyright
- `pyproject.toml` - общая конфигурация проекта

## Подробное руководство

См. основной `README.md` в корне проекта для детальных инструкций по установке и решению проблем.
