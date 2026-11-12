# Tasks

## 1. FIT source

- [ ] 1.1 Add `fit/image-cortlab.its` copied from the ITS that produced the booting CL1 FIT (kernel `/incbin/("Image_resolute_kria")` with `os = "linux"`, `compression = "none"`, load and entry `0x00200000`; ramdisk `/incbin/("ramdisk_1")`; fdt `/incbin/("system.dtb")` at `0x44000000`; default `conf-corticallab-board`; sha1 hashes). Verify with a diff against that source ITS and by checking those nodes are present.

## 2. Build script

- [ ] 2.1 Add `scripts/build-cl1-fit.sh` with `--fit`, `--dtb`, and `--out`, a temporary work directory removed on exit, and a header comment that states the command. Verify `bash -n scripts/build-cl1-fit.sh` passes and `--help` prints those three options.
- [ ] 2.2 Extract the Resolute FIT images whose `dumpimage -l` descriptions are `Ubuntu kernel` and `Ubuntu ramdisk`, using `dumpimage -T flat_dt -p <index>`, and fail without writing `image.ub` when either image is missing. Verify with a FIT that has no ramdisk image: the script exits non-zero and `--out` contains no `image.ub`.
- [ ] 2.3 Decompress the kernel's EFI zboot payload: require `MZ` and `zimg`, read the little-endian payload offset at byte 8 and size at byte 12, require compression name `zstd` at byte 24, and decompress with `zstd`. Fail without writing `image.ub` for any other magic or compression. Verify by feeding a non-zboot file as the kernel image (or a FIT whose kernel is not zboot) and confirming a non-zero exit and no `image.ub`.
- [ ] 2.4 Stage `Image_resolute_kria`, `ramdisk_1`, and `system.dtb` next to the ITS, run `mkimage -A arm64 -O linux -f image-cortlab.its image.ub`, and move `image.ub` into `--out` only after `mkimage` succeeds. Verify the script does not open the input FIT or DTB for writing (their checksums are unchanged after a successful run).

## 3. Host check against the known CL1 inputs

- [ ] 3.1 Run the script on the Resolute FIT and Cortical Labs DTB in `kria_images/xlnx-image-definitions/out/cortical_labs_dtb/` (`image.fit` and `system.dtb`). Verify `dumpimage -l` on the output reports a Linux uncompressed kernel at load/entry `0x00200000`, an fdt at `0x44000000`, and default configuration `conf-corticallab-board`; verify the extracted kernel node is a Linux arm64 Image (`file`) of 72,941,568 bytes; verify the ramdisk size and sha1 match the input FIT ramdisk and the fdt size and sha1 match `system.dtb`.

## 4. Board boot

- [ ] 4.1 [manual] Install the script-built `image.ub` into the CL1 slot's `/boot/firmware` using the existing RAUC layout and BSP 2023.2 U-Boot 2024.01 (do not replace the boot firmware). Boot with the existing `boot.scr` (`load` of `image.ub` at `0x12000000`, then `bootm`) and record the serial log showing the Resolute kernel start and a login prompt.
