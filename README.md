# omx-wrapper

A legacy `omxplayer` wrapper for Raspberry Pi OS **trixie**.

## Why this exists

`omxplayer` was deprecated and removed from Raspberry Pi OS repositories
starting with bullseye, because it depends on the legacy OpenMAX graphics
stack, which is no longer maintained. It does not support 64-bit systems
and will not work with the modern KMS driver, but it still runs fine on
32-bit systems using the legacy/FKMS graphics stack (`vc4-fkms-v3d`).

This wrapper bundles a working `omxplayer.bin` binary together with the
exact shared libraries it needs (`libavformat`, `libavcodec`, `libpango`,
`libglib`, etc.), isolated in `/home/pi/omx/libs`. The wrapper script sets
`LD\_LIBRARY\_PATH` so these bundled libraries take priority over the
system ones, avoiding conflicts with newer/incompatible versions of the
same libraries that may be installed on trixie.
## Requirements
- Raspberry Pi OS **trixie**, 32-bit, with the legacy graphics stack
&#x20; (`dtoverlay=vc4-fkms-v3d` in `config.txt`).
- The bundled libraries are linked against trixie's glibc. **This will
&#x20; not work on older releases** (wheezy, jessie, stretch, buster,
&#x20; bullseye, bookworm) - you will get errors like
&#x20; `GLIBC\_x.xx not found`. Upgrade the system to trixie first.

## Installation

```bash
cd /tmp
wget https://github.com/ijuliusz/omx-wrapper/archive/refs/heads/main.tar.gz -O omx-wrapper.tar.gz
tar -xzvf omx-wrapper.tar.gz
cd omx-wrapper-main
sudo bash install.sh
```

The installer will:
1\. Check that the target system is trixie (aborts otherwise).
2\. Back up any existing `/home/pi/omx` and `/usr/bin/omxplayer`
&#x20;  (timestamped, nothing is deleted).
3\. Copy the bundled `omx/` directory to `/home/pi/omx`.
4\. Set executable permissions on the wrapper and the binary.
5\. Install the wrapper as `/usr/bin/omxplayer`, so it works both when
&#x20;  called directly (`/home/pi/omx/omxplayer`) and via a bare `omxplayer`
&#x20;  command (e.g. from another application).
6\. Run `omxplayer -v` to verify the installation succeeded.

## Restoring a previous installation

If something goes wrong, the previous files are kept as timestamped
backups:

```bash
ls -la /home/pi/omx.bak.\*
ls -la /usr/bin/omxplayer.bak.\*
```

Restore manually if needed:

```bash
sudo rm -rf /home/pi/omx
sudo mv /home/pi/omx.bak.<timestamp> /home/pi/omx
sudo cp /usr/bin/omxplayer.bak.<timestamp> /usr/bin/omxplayer
hash -r
```

## Known limitations

- 32-bit only, legacy/FKMS graphics stack only.
- Video files with a bitrate significantly above \~8000 kbps may stall
&#x20; the hardware decoder. Transcode source files to a lower bitrate
&#x20; before deploying them if you experience playback freezes.
- Not compatible with anything older than trixie (see Requirements).



