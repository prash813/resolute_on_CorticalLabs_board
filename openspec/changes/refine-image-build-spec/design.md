# Design

## Context

What we observed in the `xlnx-image-definitions` `kria-resolute` tree (HEAD `2438593`) and in the last build output (`out/`, 19 Oct 2026):

- `classic/resolute/ubuntu-server-kria.yaml` installs `linux-amd-embedded`, `flash-kernel` and the OEM metas from three `keep-enabled: false` PPAs. It then copies `10-run-flash-kernel.sh` into the chroot and runs it. That script sets `FK_MACHINE="ZynqMP *K26*"` and `FK_FORCE=yes`, runs `/usr/sbin/flash-kernel`, and deletes itself.
- flash-kernel 3.110ubuntu2.5 (sinan-k PPA) maps that machine to `Boot-ITS-File-Name: image-kria.its` and `Kernel-Flavors: ... amd-embedded`. It reads templates only from `${FK_CHECKOUT:-/usr/share/flash-kernel}/its`, substitutes `@@LINUX_IMAGE_FILE@@`, `@@INITRD_FILE@@` and `@@KERNEL_VERSION@@`, and runs `mkimage`. The shipped template's `kernel-1` has `os = "linux"` and `compression = "gzip"`.
- The resulting `image.fit` has `kernel-1` `gzip compressed` / `OS: Linux` with a 17519104-byte payload. `file` identifies that payload as a `PE32+ executable (EFI application) Aarch64`, which is the zboot PE and not gzip. The FIT has 6 DTBs and 6 configurations, and its default configuration is `conf-zynqmp-smk-k26-revA`.
- `hooks/kria/classic/10-flash-kernel-fitimage` needs the output directory as `$1`. KV260-ubuntu-26.04-build.md step 3 leaves it out. The hook moves the files and does not regenerate them.
- KV260 boot firmware is AMD EDF BSP 2026.1, U-Boot xilinx-v2026.1, built with `CONFIG_BOOTM_EFI`. When the FIT kernel is `os = "efi"`, `bootm` hands the image, the initrd and the selected FDT to the EFI loader (the `bootm` → `bootefi` path). Applying `fdtput` by hand to the same FIT, with the same load and entry addresses, has already booted KV260 to a login prompt.

## Goals / Non-Goals

**Goals:**
- `image.fit` is correct straight out of the build, with no manual post-build step.
- The image-build spec states what the build actually does and produces.

**Non-Goals:**
- Changing the flash-kernel package, the bootscript, the DTB set or the load addresses.
- Making on-device flash-kernel runs (kernel upgrades after first boot) produce a correct FIT. See Risks.

## Decisions

### D1. Patch the `.its` template in the chroot, in `10-run-flash-kernel.sh`

Just before calling `/usr/sbin/flash-kernel`, the script edits `/usr/share/flash-kernel/its/image-kria.its` with a `sed` limited to the range from `kernel-1 {` up to the first `};`. It replaces `os = "linux";` with `os = "efi";` and `compression = "gzip";` with `compression = "none";`. The first `};` after `kernel-1 {` closes `hash-1`, and `os` and `compression` both come before it, so `ramdisk-1` and the DTB nodes stay untouched. We ran this exact `sed` on the template from the build rootfs, and it changed only lines 17–18.

Guards:
- If `kernel-1` already has `os = "efi"` and `compression = "none"`, skip the edit. This keeps the script idempotent and safe with a fixed upstream flash-kernel.
- If the edited file does not then contain both new values in `kernel-1`, exit non-zero and name the file. The script already runs with `bash -e`, so this fails the build.

Alternatives considered:
- *Keep the post-build `fdtput` only.* It works, but it is a manual step that needs root, and every build ships a broken FIT until someone runs it. It stays only as the recovery procedure (spec: "Post-build FIT relabel as recovery").
- *Ship a full replacement `.its` and point `FK_CHECKOUT` at it.* `FK_CHECKOUT` moves the db, bootscript and `its` lookup all together, so we would have to copy all of them. That is more surface area for one two-line change.
- *Add a post-hook in the YAML that runs `fdtput` inside the chroot.* This fixes the output and leaves the template wrong. Neither the developer's request nor the project context asks for that: the project context says the change belongs in the FIT source.
- *Fix flash-kernel (sinan-k PPA, then upstream).* This is the real fix, but it is out of scope here (see the proposal). D1 is written so that it becomes a no-op once that fix lands.

### D2. Keep load and entry at `0x00200000`; change only `os` and `compression`

The `fdtput` relabel that was tested booted with these addresses. With `os = "efi"`, U-Boot's EFI loader relocates the PE itself, so the FIT load address only sets where `bootm` stages the image. Leaving the addresses alone keeps the change minimal and matches what is known to work.

### D3. Deliver the patch in this repo and apply it to the external tree

`xlnx-image-definitions` is outside this repo's edit root. The patch is a `git format-patch` file at `patches/xlnx-image-definitions/0001-kria-resolute-mark-zboot-kernel-as-efi-in-FIT.patch`, generated against `kria-resolute` at `2438593`. It has a `Signed-off-by` trailer and a message that explains the `Bad gzipped data` failure. The developer applies it with `git am`. No other file in that tree changes.

### D4. Spec the hook invocation as `... 10-flash-kernel-fitimage out`

The hook takes the image directory from `$1`. The spec states the argument explicitly and records the `No image file found` failure. The external guide is not edited, because it is outside this repo. The task list notes the discrepancy.

## Risks / Trade-offs

- [After first boot, a flash-kernel package upgrade from the PPA brings back the `gzip` template, and the next kernel or initramfs update rewrites `image.fit` as unbootable.] → Record this as a known limitation of the early-access image. The durable fix is flash-kernel emitting `efi`/`none` for zboot PE kernels. Until then, the recovery is the `fdtput` relabel.
- [Editing a package-owned file in `/usr/share` means `dpkg --verify flash-kernel` reports `image-kria.its` as modified.] → Accepted for an early-access image, and the guard makes it a no-op once upstream is fixed.
- [The `sed` range relies on the template layout (`kernel-1 {` ... first `};`).] → The post-edit check fails the build when the layout changes. It never silently ships a wrong FIT.
- [An `os = "efi"` FIT does not boot on U-Boot older than v2025.07 or BSP 2026.1, such as CL1's U-Boot 2024.01.] → This is expected and already covered by `boot-chain`. CL1 uses the classic FIT from `script-cl1-fit-image-build`, which reads only the kernel payload from this FIT, and that payload is unchanged.
- [Secure Boot: the unsigned kernel fails with `Image not authenticated` on the stock meta-mok U-Boot.] → Out of scope. The `secure-boot` spec covers it (meta-mok `2015820`).

## Migration Plan

1. Apply the patch to `xlnx-image-definitions` `kria-resolute`.
2. Rebuild the image, run the hook with `out`, and check the FIT with `dumpimage -l`.
3. Flash the image and boot KV260 on BSP 2026.1.
4. Rollback: `git revert` the patch commit in `xlnx-image-definitions`, then use the `fdtput` recovery on new images.
