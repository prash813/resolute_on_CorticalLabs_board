# Proposal

## Why

The current `image-build` spec is a rough sketch, and parts of it no longer match what the KV260 build really does:

- It says the OEM packages come from the limerick-team PPAs. They actually come from `ubuntu-xilinx/default`.
- It leaves out the kernel PPA.
- It says the FIT hook "regenerates" the FIT. The hook only moves it.
- It requires `os = "efi"` and does not say how that value gets into the FIT.

The working procedure is only written down in `kria_images/KV260-ubuntu-26.04-build.md` and `kria_images/README.md`, outside this repo. In that procedure the kernel-node fix is a manual `fdtput` run on the finished image. This change turns the build into a precise, checkable spec. The spec covers exact steps, package sources, the `.its` change, and expected outputs, so the image can be rebuilt and checked without that external guide.

## What Changes

- Specify the build host prerequisites and the exact command sequence:
  - check out `kria-resolute-definition`
  - run `ubuntu-image classic`
  - run the FIT hook **with its output-directory argument** (`out`). The guide leaves this argument out, and the hook exits without it.
- Correct the package sources to the PPAs the image definition really uses: `ubuntu-xilinx/default`, `kkaniewski/linux-amd-embedded` and `sinan-k/xlnx-flash-kernel`, each with `keep-enabled: false`. The private `limerick-team/limerick-proposed` and `limerick-updates` PPAs are listed as CI-only and not needed for a local build.
- Pin the package versions this image is known to boot with (from `kria-server.manifest`).
- Specify the `.its` change. At build time, in the chroot and before flash-kernel runs, `10-run-flash-kernel.sh` changes the `kernel-1` node of `/usr/share/flash-kernel/its/image-kria.its` from `os = "linux"` / `compression = "gzip"` to `os = "efi"` / `compression = "none"`. flash-kernel then writes a correct `image.fit` directly. The change is delivered as a git patch against `xlnx-image-definitions` (branch `kria-resolute`), with a Signed-off-by trailer.
- Keep the post-build `fdtput` relabel of `image.fit` as a documented recovery procedure for images built without the `.its` patch.
- Specify the expected outputs:
  - artifact names
  - MBR partition layout and labels
  - files on the boot partition
  - FIT image, DTB and configuration nodes
  - the `dumpimage -l` result for the kernel node
- Correct the FIT hook requirement: the hook moves `image.fit` and `boot.scr.uimg` from the rootfs `/boot/firmware` to partition 1 and deletes `work/`. It does not regenerate the FIT.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `image-build`: the requirements for cross-built image, package sources, FIT generation and kernel node are rewritten with exact steps and versions. New requirements cover build host prerequisites, the build-time `.its` patch, the post-build relabel fallback and expected outputs.

## Impact

- **Boards:** KV260 EVK only, with AMD EDF BSP 2026.1 boot firmware (U-Boot xilinx-v2026.1), which boots the PE kernel through `bootm` → EFI loader (`CONFIG_BOOTM_EFI`). CL1 (BSP 2023.2, U-Boot 2024.01) is not affected. It keeps the classic `os = "linux"` FIT that the in-flight `script-cl1-fit-image-build` change produces, using the image this build creates as its input.
- **Code:** one patch to `xlnx-image-definitions` `classic/resolute/10-run-flash-kernel.sh`, kept in this repo under `patches/xlnx-image-definitions/`. The developer applies it to the external tree with `git am`. The image definition YAML, gadget, hooks and the flash-kernel package do not change.
- **Specs:** only `openspec/specs/image-build/spec.md`. The `boot-chain`, `secure-boot` and `kernel-packaging` specs stay as they are.
- **Out of scope:**
  - the UEFI Secure Boot workaround (guide step 5, meta-mok commit `2015820`), which the `secure-boot` spec already owns
  - the README's runtime PK-clearing method, which the build guide shows does not work with `CONFIG_EFI_VARIABLES_PRESEED=y`
  - QSPI programming of `boot.bin`
  - fixing flash-kernel itself, upstream or in the sinan-k PPA
  - the desktop and Versal image definitions
  - CI `images.yaml` and the private PPA tokens
  - any CL1 change
