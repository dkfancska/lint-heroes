# 🐍 Lint Heroes

[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-blue)](https://github.com/dkfancska/lint-heroes)
[![Python](https://img.shields.io/badge/python-3.9%2B-green)](https://python.org)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

Cross-platform Python linting setup with interactive version selection. Supports macOS, Linux, and Windows with multiple Python versions.

## ✨ Features

- 🚀 **Cross-platform** - Works on macOS, Linux, and Windows
- 🐍 **Interactive Python selection** - Choose from available Python versions
- 🔄 **Multiple Python support** - Install for different Python versions
- ⚡ **Automatic aliases** - Use `lint-heroes` from anywhere
- 🛠️ **Comprehensive tools** - pylint, flake8, bandit, mypy, pyright
- 🐳 **Docker support** - Run in containers for consistency

## 🚀 Quick Start

### macOS/Linux
```bash
git clone https://github.com/dkfancska/lint-heroes.git
cd lint-heroes
./macos/installall.sh
lint-heroes your_file.py
```

### Windows
```powershell
git clone https://github.com/dkfancska/lint-heroes.git
cd lint-heroes
.\windows\installall.ps1
lint-heroes your_file.py
```

### No Node.js Required
```bash
# Pyright installed via Homebrew (macOS) or pip (Windows)
# No Node.js dependency needed!
```

## 📋 Commands

Available on all platforms (macOS, Linux, Windows):

| Command | Description |
|---------|-------------|
| `lint-heroes` | Run all linters |
| `lint-install` | Install for current Python |
| `lint-multi` | Install for multiple Python versions |
| `lint` | Short alias for lint-heroes |

### Platform-Specific Details

- **macOS/Linux**: Shell aliases in `~/.zshrc` or `~/.bashrc`
- **Windows**: Batch files in `%USERPROFILE%\bin\` + PowerShell functions

## 📚 Documentation

- **[Installation Guide](docs/installation/README.md)** - Detailed installation instructions
- **[Usage Guide](docs/usage/README.md)** - How to use linting tools
- **[Configuration](docs/configuration/README.md)** - Tool configurations
- **[Troubleshooting](docs/troubleshooting/README.md)** - Common issues and solutions
- **[Windows Setup](windows/WINDOWS_SETUP.md)** - Windows-specific guide
- **[macOS/Linux Guide](macos/README.md)** - Unix-specific guide

## 🛠️ Tools Included

- **pylint** - Static code analysis
- **flake8** - Style guide enforcement with bugbear
- **bandit** - Security linter
- **mypy** - Static type checking
- **pyright** - Fast type checking
- **isort** - Import sorting

## 📖 Examples

```bash
# Lint current directory
lint-heroes

# Lint specific file
lint-heroes src/main.py

# Lint specific directory
lint-heroes src/

# Install for multiple Python versions
lint-multi
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Thanks to all the Python linting tool maintainers
- Inspired by the need for consistent linting across different Python versions