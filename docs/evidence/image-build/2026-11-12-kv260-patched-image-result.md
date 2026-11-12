# KV260 boot result: patched Resolute image (2026-11-12)

**Outcome: PASS**

The image built with the `.its` patch boots on the KV260 through U-Boot's EFI loader. It reaches a login prompt, and the root and boot partitions are mounted from the expected labels.

## What was tested

| Item | Value |
|---|---|
| Board | KV260 EVK: SOM `SMK-K26-XCL2G-ED` rev 1, carrier `SCK-KV-G` rev 1 |
| Boot firmware | AMD EDF BSP 2026.1: FSBL/PMU 2026.1, TF-A v2.14 `xlnx-rebase-v2.14_2026.1`, U-Boot 2026.01; Secure Boot off |
| Image definitions | `xlnx-image-definitions` `kria-resolute` at `2438593`, plus `patches/xlnx-image-definitions/0001-kria-resolute-mark-zboot-kernel-as-efi-in-FIT.patch` |
| Build | `sudo ubuntu-image classic --debug -w work -O out classic/resolute/ubuntu-server-kria.yaml`, then `sudo bash hooks/kria/classic/10-flash-kernel-fitimage out` |
| Card | whole `out/kria-server.img` written to a 64 GB microSD card (`mmcblk1`, SR64G) |
| Serial | `ttyPS1`, 115200 8N1, captured with minicom |

## Results against the `image-build` spec

| Check | Evidence | Result |
|---|---|---|
| Boot script picks the KV260 rev B configuration | boot log l.71 `Kria DT: #conf-smk-k26-revA-sck-kv-g-revB` | pass |
| FIT is the one from the patched build | boot log l.76 `114566792 bytes`; l.82 `Created: 2026-11-12 12:58:53 UTC` | pass |
| `kernel-1` is `os=efi`, `compression=none` | boot log l.84–92 `Compression: uncompressed`, `OS: EFI Firmware`, load/entry `0x00200000`, sha1 `543e28113c53…`; `2026-11-12-patched-image.fit.dumpimage-l.txt` | pass |
| No gzip error | no `Bad gzipped data` in the boot log | pass |
| Kernel started via the EFI loader | boot log l.131 `## Transferring control to EFI`; kernel `efi: EFI v2.11 by Das U-Boot` | pass |
| Kernel payload is the unmodified PE; ramdisk is unchanged | `2026-11-12-patched-fit-payload-check.txt` | pass |
| Kernel | boot log l.136 and `uname -r`: `7.0.0-1003-amd-embedded` | pass |
| Root filesystem is the image's `writable` partition | boot log l.587 `mounted filesystem fbd52f08-35fd-41c0-9117-d12c70fa2ee4`, l.664 remounted r/w; `findmnt` below | pass |
| Root filesystem contents match the build | `systemd 259 (259.9-0ubuntu0.1)` and `/lib/modules/7.0.0-1003-amd-embedded`, both as in `2026-11-12-patched-manifest-versions.txt`; boot log l.589 `Inserted module 'autofs4'` | pass |
| `/boot/firmware` from `LABEL=system-boot` | `findmnt` below | pass |
| Login prompt | boot log l.669–671 `Ubuntu 26.04.1 LTS kria ttyPS1`, `kria login:` | pass |
| Disk layout | `2026-11-12-patched-kria-server.img.sfdisk.txt` | pass |

## Commands run on the board (same boot)

These were run in a shell on the board. The session reported `bootid=3a7e48e7-5c02-497d-8735-190d3d820f40`, which matches the boot log.

```
$ uname -r
7.0.0-1003-amd-embedded
$ ls /lib/modules
7.0.0-1003-amd-embedded
$ systemctl --version | head -1
systemd 259 (259.9-0ubuntu0.1)
$ findmnt -no SOURCE,TARGET,FSTYPE,LABEL /; findmnt -no SOURCE,TARGET,FSTYPE,LABEL /boot/firmware
/dev/mmcblk1p2 / ext4 writable
/dev/mmcblk1p1 /boot/firmware vfat system-boot
```

## Notes

- **Forced password change at first login:** the first login requires a new password, because the image definition sets cloud-init `chpasswd: expire: true`. The first attempts failed with `Authentication token manipulation error`: the current password was rejected and the new passwords did not match (boot log l.674–709). This is expected first-boot behavior, not an image fault.
- **Non-blocking warnings:**
  - `KHO: Failed to reserve scratch area, disabling kexec handover`
  - `Cannot persist EFI variables without system partition` (U-Boot)
  - `ffe00000.r5f: mbox_request_channel_byname() could not locate channel named "tx"`
- **Known limitation:** the image enables `/etc/apt/sources.list.d/oem.list`, which points at `noble-limerick`. The `image-build` spec does not cover it.

## Files

- `2026-11-12-kv260-patched-image-boot.log`: full serial log, kept unedited (sha1 `52798f2b9909c767ec49d2e942a737f715acf4f3`)
- `2026-11-12-patched-image.fit.dumpimage-l.txt`: `dumpimage -l` of `image.fit` from partition 1
- `2026-11-12-patched-fit-payload-check.txt`: kernel and ramdisk payloads compared with the rootfs `/boot` files
- `2026-11-12-patched-kria-server.img.sfdisk.txt`: partition table
- `2026-11-12-patched-manifest-versions.txt`: key package versions from `kria-server.manifest`
