# Wootility installer

Install Wootility 5.4.2 on Linux:

```sh
./install.sh
```

Requirements: Bash, curl, Python 3, squashfs-tools (`unsquashfs`), ImageMagick
(`magick` or `convert`), udev, and sudo when running as a regular user.
The AppImage also needs your distribution's AppImage/FUSE runtime support.

The installer downloads from
<https://wooting.io/_backend/public/wootility/download?os=linux&version=5.4.2>,
then installs the AppImage and wrapper in `/opt/wootility/`. It converts the
AppImage's bundled icon to `/opt/wootility/wootility.jpg`, installs the desktop
entry in `/usr/local/share/applications/`, and installs
`/etc/udev/rules.d/70-wooting.rules`. Downloads and icon preparation finish
before any system files are changed. Rerunning replaces the installed version.

The launcher forwards URL arguments for the desktop entry's `wootwoot` and
`web+wootwoot` scheme handlers. As in the requested wrapper, stdout is discarded
and stderr goes to the original stdout.

Device permissions follow the [official Wooting udev instructions](https://help.wooting.io/article/147-configuring-device-access-for-wootility-under-linux-udev-rules).
The installer reloads and triggers udev rules. Reconnect the keyboard if it is
not detected, then launch Wootility from your application menu as your normal user.
