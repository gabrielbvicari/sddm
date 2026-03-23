<div align="center">

  <h1>Chima SDDM Theme</h1>
  <h5>A customized SDDM theme for the Chima Linux distribution, designed to match the Quickshell lock screen.</h5>

[![SDDM 0.21+](https://img.shields.io/badge/SDDM%200.21+-green.svg?style=for-the-badge&logo=kde)](https://github.com/sddm/sddm)
[![Qt 6.5+](https://img.shields.io/badge/Qt%206.5+-blue.svg?style=for-the-badge&logo=qt)](https://www.qt.io/)
[![GPL-3.0](https://img.shields.io/badge/License-GPL%203.0-blue.svg?style=for-the-badge)](LICENSE)
![Work In Progress](https://img.shields.io/badge/Work%20In%20Progress-orange?style=for-the-badge)

</div>

## About

Based on [SilentSDDM](https://github.com/uiriansan/SilentSDDM) by uiriansan, this theme has been stripped down and customized for the [Chima](https://github.com/gabrielbvicari/chima) desktop environment:

- Blurred background on both lock and login screens;
- Clock with seconds, non-bold weight;
- No "Press any key" message on the lock screen;
- No caps lock warning;
- Password input and login button sized to match Quickshell lock screen (160x35);
- Session selector top-left, power menu top-right;
- Avatar placeholder icon when no user image is set;
- Unused presets, backgrounds, docs, and assets removed.

## Requirements

- **SDDM >= 0.21.0**
- **Qt >= 6.5**
- `qt6-svg`
- `qt6-virtualkeyboard`

## Installation

```bash
# Clone the repository:
git clone https://github.com/gabrielbvicari/sddm.git ~/Projects/sddm

# Create symlink to SDDM themes directory:
sudo ln -s ~/Projects/sddm /usr/share/sddm/themes/chima

# Copy SDDM configuration:
sudo cp ~/Projects/sddm/configs/sddm.conf /etc/sddm.conf

# Or just clone directly in the configuration folder and copy the configuration file:
git clone https://github.com/gabrielbvicari/sddm.git /usr/share/sddm/themes/chima
sudo cp ~//usr/share/sddm/themes/chima/configs/sddm.conf /etc/sddm.conf
```

## Testing

You can preview the theme without logging out:

```bash
./test.sh
```

Use `./test.sh --debug` for verbose output.

## Customization

All visual properties are configured in [`configs/default.conf`](configs/default.conf). See the [SilentSDDM wiki](https://github.com/uiriansan/SilentSDDM/wiki/Customizing) for a full list of available options.

## Acknowledgements

- [SilentSDDM](https://github.com/uiriansan/SilentSDDM) by uiriansan
- [Qt Virtual Keyboard](https://github.com/qt/qtvirtualkeyboard) style adapted from Qt Company (GPL-3.0)
