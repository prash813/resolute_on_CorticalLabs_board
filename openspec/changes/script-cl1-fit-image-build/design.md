# Design

## Context

See proposal.md for why this is scripted. The FIT that already boots the CL1 was assembled by hand in a work directory: `dumpimage` pulled `kernel-1` and `ramdisk-1` out of the Resolute `image.fit`, the kernel (an EFI zboot PE, mislabelled `os = "linux"` / `compression = "gzip"` by flash-kernel) was decompressed to a raw arm64 `Image`, and `mkimage -A arm64 -O linux -f image-cortlab.its image.ub` packed that `Image`, the untouched ramdisk, and the Cortical Labs `system.dtb`.

CL1 boot firmware is BSP 2023.2, U-Boot 2024.01. Its existing `boot.scr` loads `image.ub` at `0x12000000` and runs `bootm` (classic Linux FIT path, not `bootm` → `bootefi`). U-Boot then uses the FIT kernel load/entry `0x00200000` and the fdt load `0x44000000`.

The known-good kernel in that work directory is a PE whose zboot header is `MZ`, two pad bytes, `zimg`, a little-endian payload offset at byte 8, a little-endian payload size at byte 12, and the compression name `zstd` at byte 24. Decompressing that slice with `zstd` reproduces the raw `Image` byte for byte (72,941,568 bytes). The ramdisk sha1 in the hand-built `image.ub` matches the ramdisk sha1 in the input FIT (`f45f21710e268206b2032f1f605290534ddab9fc`).

## Goals / Non-Goals

**Goals:**

- One host command reproduces `image.ub` from a Resolute FIT and a DTB file.
- The checked-in `.its` is the source for that FIT, with the same nodes, load addresses, and default configuration as the FIT that boots CL1 today.
- A failed run does not leave an output FIT behind.

**Non-Goals:**

- Folding this into `ubuntu-image` or flash-kernel. The KV260 image still uses `os = "efi"`.
- Fetching the Resolute FIT or the Noble DTB. Both stay developer-supplied inputs.
- Vendoring `image.fit`, the kernel, the ramdisk, `system.dtb`, or `image.ub` in git.

## Decisions

### Script and template live in this repo

Add `scripts/build-cl1-fit.sh` and `fit/image-cortlab.its`. The work directory that holds the current binaries is an old checkout of this same repository dropped under an image-build `out/` tree, so the script does not belong there.

Alternative: keep running `mkimage` by hand in that directory. Rejected because the kernel and initrd change with each Resolute build and the steps are not recorded as a command that can be re-run.

### Inputs and output

```
scripts/build-cl1-fit.sh --fit <resolute-image.fit> --dtb <system.dtb> --out <dir>
```

The script writes `<dir>/image.ub` only after `mkimage` succeeds. It stages files in a temporary directory and removes that directory on exit. It does not mount the disk image, so it does not need `sudo`.

Alternative: accept the `kria-server.img` disk image and loop-mount the boot partition. Rejected because that needs root and the FIT is already a file once the image exists.

### Stage the known-good ITS next to fixed filenames

`fit/image-cortlab.its` is the current `image-cortlab.its`: kernel `/incbin/("Image_resolute_kria")` with `os = "linux"`, `compression = "none"`, load and entry `0x00200000`; ramdisk `/incbin/("ramdisk_1")`; fdt `/incbin/("system.dtb")` at `0x44000000`; default configuration `conf-corticallab-board`; sha1 hashes. The script copies that template into the temp directory, places the three binaries under those names, and runs:

```
mkimage -A arm64 -O linux -f image-cortlab.its image.ub
```

`/incbin/` paths are resolved from the ITS location, so the template stays free of absolute paths.

Alternative: sed placeholders into the ITS. Rejected as extra machinery around a template that already boots.

### Select FIT images by role, then extract

`dumpimage -l` on the Resolute FIT identifies the kernel image (description `Ubuntu kernel`) and the ramdisk (description `Ubuntu ramdisk`). The script extracts those image indexes with `dumpimage -T flat_dt -p <index>`. It does not assume index 0 and 1 stay stable if flash-kernel adds nodes.

### Zboot extraction follows the header in the current kernel

After extraction, require the `MZ` / `zimg` magic. Read the payload offset and size as little-endian 32-bit fields at bytes 8 and 12. Read the four-byte compression name at byte 24. For `zstd`, decompress with the `zstd` CLI. Any other magic or compression name is an error. Confirm the result with `file` before `mkimage`.

This layout was checked against the PE taken from the current Resolute FIT: offset `0x1b2f8`, size `17397564`, name `zstd`, and the decompressed bytes match the `Image` already used in the booting FIT.

Alternative: hard-code the offset. Rejected because the offset moves when the zboot header or PE sections change. Alternative: depend on a Python zstd package. Rejected because `zstd` and `python3` (stdlib only, for the header slice) are already on the Ubuntu build host.

### Failure deletes a partial output

The script writes `image.ub` inside the temp directory and moves it to `--out` only after `mkimage` returns success. On any earlier error it removes a partial `<dir>/image.ub` from this run if it created one. It never opens the input FIT or DTB for writing.

## Risks / Trade-offs

- [A newer `linux-amd-embedded` changes the zboot header] → Fail on magic or compression mismatch instead of emitting a FIT. Re-check the header fields when the kernel package version changes.
- [`dumpimage -l` text format drifts] → Match on the stable description lines (`Ubuntu kernel`, `Ubuntu ramdisk`) and fail if either image is missing.
- [The supplied DTB is not the Cortical Labs one] → The script checks that the file is a device tree blob and then embeds it unchanged. Provenance (Noble FIT from the earlier RP work) stays the developer's responsibility, as in `cl1-board-bringup`.
- [sha1 FIT hashes are weaker than sha256] → Kept so the ITS matches the FIT U-Boot 2024.01 already boots. Hash algorithm is not a boot blocker on this firmware.

## Migration Plan

Developers stop using the hand-run `mkimage` line and call `scripts/build-cl1-fit.sh` with the new Resolute FIT and the same Cortical Labs `system.dtb`. The previous `image.ub` remains the rollback image until a board boot confirms the script output. No firmware or partition change.

## Open Questions

None. The Noble DTB stays an input path; this repo does not need a copy of it for the script to be complete.
