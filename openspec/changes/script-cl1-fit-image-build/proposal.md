# Proposal

## Why

The Cortical Labs CL1 board (BSP 2023.2, U-Boot 2024.01) cannot boot the Resolute EFI zboot kernel from a FIT, so its image is a classic FIT (`os = "linux"`) built by hand from a Resolute FIT, a decompressed arm64 `Image`, and the Cortical Labs device tree. That assembly lives as loose files and a one-line `mkimage` command, so it cannot be repeated when the Resolute kernel or initrd changes.

## What Changes

- Add a host-side script that builds the CL1 FIT (`image.ub`) from a Resolute FIT and the Cortical Labs DTB.
- Check in the CL1 FIT source (`.its`) the script fills in, matching the FIT that already boots this board: raw arm64 kernel, unchanged ramdisk, Cortical Labs DTB, `bootm` load addresses.
- Extract the raw arm64 `Image` from the Resolute kernel's EFI zboot PE (zstd payload) inside that script, without rebuilding the kernel.
- Leave the KV260 flash-kernel FIT path unchanged.

## Capabilities

### New Capabilities

- `cl1-fit-image`: Host-side assembly of the classic FIT that CL1 U-Boot boots with `bootm`.

### Modified Capabilities

- None. `kernel-packaging` already requires zboot extraction and an unchanged initrd, `boot-chain` already requires the classic FIT flow on CL1, and `cl1-board-bringup` already requires the Cortical Labs DTB and an untouched BSP 2023.2 / RAUC layout. This change adds the missing build step; it does not change those requirements. `image-build` stays the KV260 `ubuntu-image` / flash-kernel path.

## Impact

- Affects the CL1 board only. Assumes the existing BSP 2023.2 boot firmware (U-Boot 2024.01) and the classic `bootm` path (`os = "linux"`). No KV260 firmware or image change.
- New files in this repo: the build script and the CL1 `.its` template. Host tools used: `dumpimage`, `mkimage` (`u-boot-tools`), and a zstd decompressor. No new packages in the Ubuntu image.
- Inputs are supplied by the developer: the Resolute `image.fit` produced by the existing Kria image build, and the Cortical Labs `system.dtb` taken from the Noble FIT delivered by the earlier RP work. The script does not download images and does not need `sudo` when those files are already on disk.
- Out of scope: replacing or rebuilding CL1 U-Boot, changing the RAUC A/B layout, copying the FIT onto eMMC, regenerating `boot.scr`, FPGA bitstream handling, kernel rebuilds, and the KV260 PE FIT (`os = "efi"`) including its Secure Boot workaround.
