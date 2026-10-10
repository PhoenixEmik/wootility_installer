# Wootility installer for Linux

A Bash installer for **Wootility 5.4.2** that sets up the AppImage, application
menu entry, icon, and Wooting keyboard permissions in one command.

The application is downloaded from [Wooting's download endpoint](https://wooting.io/_backend/public/wootility/download?os=linux&version=5.4.2).
This repository provides the installation scripts; it does not bundle Wootility.

## Install

Install the dependencies below, then clone this repository and run the installer:

```bash
git clone https://github.com/PhoenixEmik/wootility_installer.git
cd wootility_installer
./install.sh
```

Run the installer as your regular user. It asks for `sudo` access when writing
system files and applying device permissions. Downloading and preparing the icon
finish before any system files are changed.

Once installation completes, open **Wootility** from your application menu, or run:

```bash
/opt/wootility/wootility.sh
```

Launch Wootility as your regular user. If your keyboard is not detected,
disconnect and reconnect it.

## Requirements

Use a Linux system with udev and support for running the downloaded AppImage.
Internet access is required during installation.

| Dependency | Purpose |
| --- | --- |
| Bash | Runs the installer and launcher |
| curl | Downloads the AppImage over HTTPS |
| Python 3 | Reads the AppImage's embedded filesystem offset |
| squashfs-tools (`unsquashfs`) | Extracts the bundled icon |
| ImageMagick (`magick` or `convert`) | Converts the icon to JPEG |
| Core utilities (`install`, `mktemp`, `rm`) | Installs files and manages temporary data |
| udev (`udevadm`) | Applies keyboard access rules |
| sudo | Installs system files when running as a regular user |
| Git | Clones this repository |

The application may also require your distribution's FUSE runtime support.
If available, `update-desktop-database` refreshes the desktop entry cache;
it is optional.

## Installed files

| Path | Contents |
| --- | --- |
| `/opt/wootility/wootility.AppImage` | Wootility 5.4.2 executable |
| `/opt/wootility/wootility.sh` | Launcher wrapper |
| `/opt/wootility/wootility.jpg` | Icon converted from the AppImage's bundled icon |
| `/usr/local/share/applications/wootility.desktop` | Application menu entry and URL handlers |
| `/etc/udev/rules.d/70-wooting.rules` | Wooting keyboard access rules |

Temporary downloads and extracted files are removed when the installer exits.
Rerunning the installer replaces these installed files with the pinned version
and repository configuration. It does not automatically select the latest release.

The desktop entry advertises the `wootwoot` and `web+wootwoot` URL schemes,
and the wrapper forwards URL arguments to Wootility. It does not set a default
handler explicitly. The wrapper discards standard output and sends standard
error to the original standard output.

## Keyboard access

The included rules follow [Wooting's official udev instructions](https://help.wooting.io/article/147-configuring-device-access-for-wootility-under-linux-udev-rules).
They cover legacy Wooting One and Two devices, their update modes, and devices
using Wooting's `31e3` vendor ID.

The installer reloads and triggers udev rules. These rules grant access through
`uaccess` and the `input` group, so Wootility can communicate with the keyboard
without running as root.

## Troubleshooting

**A dependency is missing:** Install the package that provides the command named
in the error, then rerun `./install.sh`. Package names vary by distribution.

**The keyboard is not detected:** Reconnect it after installation. To reapply the
installed rules manually, run:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

**The application does not start:** Run the AppImage directly to see its output:

```bash
/opt/wootility/wootility.AppImage
```

If the error mentions FUSE, install your distribution's AppImage/FUSE runtime
support. Confirm that the downloaded application supports your system's architecture.

**The wrapper reports “Expected one AppImage”:** It requires exactly one file
matching `/opt/wootility/*AppImage`. Move any older AppImages out of that directory,
or rerun the installer if the application file is missing.

**The application menu entry is missing:** Refresh your desktop session or sign
out and back in. If `update-desktop-database` is installed, you can also run:

```bash
sudo update-desktop-database /usr/local/share/applications
```

## Uninstall

Remove the files installed by this repository and reload device rules:

```bash
sudo rm -f /opt/wootility/wootility.AppImage \
    /opt/wootility/wootility.sh \
    /opt/wootility/wootility.jpg \
    /usr/local/share/applications/wootility.desktop \
    /etc/udev/rules.d/70-wooting.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

If `/opt/wootility/` is now empty, remove it with `sudo rmdir /opt/wootility`.
If available, run `sudo update-desktop-database /usr/local/share/applications`
to refresh the desktop entry cache. These steps leave per-user application
settings untouched.

## License

The installer is licensed under the [MIT License](LICENSE). Wootility is
distributed by Wooting under its own terms.
