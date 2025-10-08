# Windows скрипты

Эта папка содержит скрипты для установки и запуска линтеров на Windows.

## Файлы

- `installall.bat` - Скрипт установки (Batch)
- `installall.ps1` - Скрипт установки (PowerShell)
- `lint_all.bat` - Скрипт запуска линтеров (Batch)
- `lint_all.ps1` - Скрипт запуска линтеров (PowerShell)
- `WINDOWS_SETUP.md` - Подробное руководство для Windows

## Использование

### Установка

**Batch файл (простой):**
```cmd
# Из корневой папки проекта
windows\installall.bat
```

**PowerShell (рекомендуется):**
```powershell
# Из корневой папки проекта
.\windows\installall.ps1
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

- Python 3.11+
- pip
- Node.js и npm (для pyright)
- PowerShell 5.0+ (для PowerShell скриптов)

## Что устанавливается

- pylint
- flake8 + flake8-bugbear
- bandit
- mypy
- pyright (через npm)
- isort

## Конфигурация

Скрипты автоматически создают конфигурационные файлы:
- `.pylintrc`
- `.flake8`
- `pyproject.toml` (если не существует)

## Подробное руководство

См. `WINDOWS_SETUP.md` для детальных инструкций по установке и решению проблем.
