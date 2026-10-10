#!/bin/bash
set -euo pipefail

VERSION=5.4.2
DOWNLOAD_URL="https://wooting.io/_backend/public/wootility/download?os=linux&version=${VERSION}"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

for command in curl python3 unsquashfs install udevadm; do
    command -v "$command" >/dev/null || { echo "Missing dependency: $command" >&2; exit 1; }
done
if command -v magick >/dev/null; then
    IMAGE_CONVERT=magick
elif command -v convert >/dev/null; then
    IMAGE_CONVERT=convert
else
    echo 'Install ImageMagick (magick or convert) to create the launcher icon.' >&2
    exit 1
fi

ROOT=()
if (( EUID != 0 )); then
    command -v sudo >/dev/null || { echo 'Install sudo or run this script as root.' >&2; exit 1; }
    ROOT=(sudo)
fi

WORK_DIR=$(mktemp -d)
trap 'rm -rf -- "$WORK_DIR"' EXIT
APPIMAGE="$WORK_DIR/wootility-${VERSION}.AppImage"
echo "Downloading Wootility ${VERSION}..."
curl --fail --location --retry 3 --connect-timeout 30 \
    --proto '=https' --proto-redir '=https' --output "$APPIMAGE" "$DOWNLOAD_URL"

# Read the type-2 AppImage's SquashFS offset without executing the download.
OFFSET=$(python3 - "$APPIMAGE" <<'PY'
import mmap
import struct
import sys

with open(sys.argv[1], "rb") as file:
    with mmap.mmap(file.fileno(), 0, access=mmap.ACCESS_READ) as data:
        if data[:4] != b"\x7fELF" or data[8:11] != b"AI\x02":
            sys.exit("Download is not a type-2 AppImage")
        offset = data.find(b"hsqs", 4096)
        while offset != -1:
            if offset + 96 <= len(data):
                major, minor = struct.unpack_from("<HH", data, offset + 28)
                size = struct.unpack_from("<Q", data, offset + 40)[0]
                if (major, minor) == (4, 0) and 96 <= size <= len(data) - offset:
                    print(offset)
                    break
            offset = data.find(b"hsqs", offset + 1)
        else:
            sys.exit("No SquashFS filesystem found in the AppImage")
PY
)
unsquashfs -no-progress -no-xattrs -o "$OFFSET" -d "$WORK_DIR/extracted" "$APPIMAGE" >/dev/null
ICON="$WORK_DIR/extracted/.DirIcon"
if [[ ! -f "$ICON" ]]; then
    echo 'The AppImage does not contain a usable .DirIcon.' >&2
    exit 1
fi
"$IMAGE_CONVERT" "$ICON" -background white -alpha remove -alpha off "$WORK_DIR/wootility.jpg"

echo 'Installing application, desktop entry, and device access rules...'
"${ROOT[@]}" install -d -m 0755 /opt/wootility /usr/local/share/applications /etc/udev/rules.d
"${ROOT[@]}" install -m 0755 "$APPIMAGE" /opt/wootility/wootility.AppImage
"${ROOT[@]}" install -m 0755 "$SCRIPT_DIR/wootility.sh" /opt/wootility/wootility.sh
"${ROOT[@]}" install -m 0644 "$WORK_DIR/wootility.jpg" /opt/wootility/wootility.jpg
"${ROOT[@]}" install -m 0644 "$SCRIPT_DIR/wootility.desktop" /usr/local/share/applications/wootility.desktop
"${ROOT[@]}" install -m 0644 "$SCRIPT_DIR/70-wooting.rules" /etc/udev/rules.d/70-wooting.rules
"${ROOT[@]}" udevadm control --reload-rules
"${ROOT[@]}" udevadm trigger
if command -v update-desktop-database >/dev/null; then
    "${ROOT[@]}" update-desktop-database /usr/local/share/applications
fi
echo 'Wootility installed. Launch it from your application menu; reconnect your keyboard if needed.'
