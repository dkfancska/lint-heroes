# Быстрый старт для Windows

## Предварительные требования

1. **Python 3.11+** - скачайте с [python.org](https://www.python.org/downloads/)
2. **Node.js** (для pyright) - скачайте с [nodejs.org](https://nodejs.org/)
3. **Git** (опционально) - скачайте с [git-scm.com](https://git-scm.com/)

## Установка

### Вариант 1: PowerShell (рекомендуется)

```powershell
# 1. Откройте PowerShell от имени администратора
# 2. Перейдите в папку проекта
cd C:\path\to\lint_heroes

# 3. Запустите установку
.\installall.ps1

# 3. Если возникли проблемы с Execution Policy:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Вариант 2: Batch файл

```cmd
# 1. Откройте командную строку
# 2. Перейдите в папку проекта
cd C:\path\to\lint_heroes

# 3. Запустите установку
installall.bat
```

### Вариант 3: Ручная установка

```cmd
# Создание виртуального окружения
python -m venv .venv

# Активация окружения
.venv\Scripts\activate.bat

# Установка зависимостей
pip install -r req.txt

# Установка pyright
npm install -g pyright
```

## Использование

### PowerShell
```powershell
# Проверка всего проекта
.\lint_all.ps1

# Проверка конкретного файла
.\lint_all.ps1 src\main.py

# Проверка папки
.\lint_all.ps1 src\
```

### Batch файл
```cmd
# Проверка всего проекта
lint_all.bat

# Проверка конкретного файла
lint_all.bat src\main.py

# Проверка папки
lint_all.bat src\
```

## Настройка IDE

### PyCharm

1. Откройте проект в PyCharm
2. Перейдите в `Run` → `Edit Configurations`
3. Выберите `Lint All PowerShell` или `Lint All Windows`
4. Нажмите `Run`

### VS Code

1. Установите расширения:
   - Python
   - Pylint
   - MyPy Type Checker

2. Настройте `settings.json`:
```json
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

## Решение проблем

### PowerShell не запускается
```powershell
# Временно разрешить выполнение
PowerShell -ExecutionPolicy Bypass -File .\installall.ps1
```

### Python не найден
```cmd
# Проверьте PATH
echo %PATH%

# Добавьте Python в PATH:
# C:\Python311\
# C:\Python311\Scripts\
```

### npm не найден
1. Установите Node.js с [nodejs.org](https://nodejs.org/)
2. Перезапустите командную строку
3. Проверьте: `npm --version`

### Виртуальное окружение не активируется
```cmd
# Убедитесь, что файл существует
dir .venv\Scripts\activate.bat

# Если нет, пересоздайте:
rmdir /s .venv
python -m venv .venv
```

## Полезные команды

```cmd
# Проверка установки всех инструментов
where python pip pylint flake8 bandit mypy pyright

# Активация виртуального окружения
.venv\Scripts\activate.bat

# Деактивация
deactivate

# Обновление всех пакетов
pip install --upgrade -r req.txt
```

## Структура после установки

```
lint_heroes/
├── .venv/                  # Виртуальное окружение
├── .run/                  # Конфигурации PyCharm
├── pyproject.toml         # Конфигурация линтеров
├── bandit.yaml           # Конфигурация безопасности
├── pyrightconfig.json    # Конфигурация pyright
├── .pylintrc             # Конфигурация pylint (создается автоматически)
├── .flake8               # Конфигурация flake8 (создается автоматически)
└── req.txt               # Зависимости
```
