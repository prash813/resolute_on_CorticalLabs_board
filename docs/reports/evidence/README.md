# Evidence index for the Resolute Kria bring-up status report

Files in this directory support `../resolute-kria-bringup-status.md`.
Existing captures were copied or derived from paths already on disk;
nothing here was recaptured from a board for this report.

## Image build and KV260 (from `docs/evidence/image-build/` on this branch)

| File | What it is |
|---|---|
| `2026-11-12-kv260-patched-image-boot.log` | Full KV260 serial log: U-Boot 2026.01, EFI hand-off, Linux 7.0.0-1003-amd-embedded, Ubuntu 26.04.1 login prompt. Landed in commit `ef16947`. The log shows first-login password *prompts* only; no password values are present. |
| `2026-11-12-kv260-patched-image-result.md` | Result summary mapped to the `image-build` spec. |
| `2026-11-12-patched-image.fit.dumpimage-l.txt` | `dumpimage -l` of the patched FIT (`kernel-1` OS: EFI Firmware, uncompressed). |
| `2026-11-12-patched-fit-payload-check.txt` | Kernel and ramdisk payloads compared with the rootfs `/boot` files. |
| `2026-11-12-patched-kria-server.img.sfdisk.txt` | MBR partition table of `kria-server.img`. |
| `2026-11-12-patched-manifest-versions.txt` | Key package versions from `kria-server.manifest`. |
| `2026-11-12-kv260-recovery-fdtput-result.md` | Recovery path: `fdtput` relabel of an unpatched FIT. Host-side checks pass; login was observed by the developer, no serial log kept. Commit `8e16c6a`. |

The untracked work-tree file `resolute_boot_newfs.log` is byte-identical to
`2026-11-12-kv260-patched-image-boot.log` (sha1 `52798f2b9909c767ec49d2e942a737f715acf4f3`).
It is a KV260 log, not a CL1 log, and was not copied here.

## CL1

| File | What it is |
|---|---|
| `cl1-image.ub.dumpimage-l.txt` | `dumpimage -l` of the 29 Oct hand-built classic FIT (`kernel-1` OS: Linux, 72,941,568-byte raw Image). |
| `cl1-fit-note.txt` | Provenance of that FIT, and `dumpimage -l` of the 12 Nov `build-cl1-fit.sh` reproduction (same payload hashes). Binaries are not committed. |
| `image-cortlab.its` | FIT source from `git show script-cl1-fit-image-build:fit/image-cortlab.its` at commit `83713fb`. Kernel node is `os = "linux"`, `compression = "none"`. |
| `cl1-resolute_logs.txt` | Copy of `CorticalLabs/resolute_logs.txt` (29 Oct). A root shell on the running CL1: Ubuntu 26.04.1, kernel 7.0.0-1001-amd-embedded, hostname `CL1-2507-30`, RAUC slot A, dmesg for eMMC, NVMe and USB. This is not a U-Boot-to-login serial capture, and it has no ethernet, `lsusb`, `ethtool` or `lsblk` command output. |
| `cl1-developer-note-booting_resolute.logs` | Copy of `CorticalLabs/booting_resolute.logs` (29 Oct). The developer's note that the image booted and that eMMC, ethernet, NVMe, USB Type-A and USB Type-C enumerated. Developer-reported, not instrumented output. |
| `cl1-failed-efi-fit-boot.log` | Copy of `u-boot-xlnx-24.1/u-boot-xlnx/uboot-cortboard-reoslute-booting.log`. A *failed* 29 Oct attempt (U-Boot 2024.01, RAUC slot A) with an EFI-labelled PE FIT, ending in a Synchronous Abort. Contrast only; not success evidence. |

A complete CL1 U-Boot-to-login serial log, and formal `lsusb` / `ip` / `ethtool` / `lsblk` output, were not found and were not recaptured (tasks 2.1 and 2.2 left for the developer).

The host script that builds the CL1 FIT is on branch `script-cl1-fit-image-build` at `83713fb`. Inspect it with `git show script-cl1-fit-image-build:scripts/build-cl1-fit.sh`. That branch was not merged into this one.

## Secure Boot

| File | What it is |
|---|---|
| `secure-boot.txt` | `# CONFIG_EFI_SECURE_BOOT is not set` from the EDF 2026.1 U-Boot `.config`, the summary of meta-mok commit `2015820`, and the KV260 boot-log line `Secure Boot: not authenticated, not encrypted`. |

## Image-build change and patch (already in this repo)

- `openspec/changes/refine-image-build-spec/` on this branch (tip of `resolute-image-build` is `56f1e32`).
- `patches/xlnx-image-definitions/0001-kria-resolute-mark-zboot-kernel-as-efi-in-FIT.patch`
