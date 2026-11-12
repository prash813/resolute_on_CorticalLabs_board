# Tasks

## 1. Build-time `.its` patch (xlnx-image-definitions)

- [x] 1.1 On a scratch branch of `xlnx-image-definitions` (based on `kria-resolute` at `2438593`), edit `classic/resolute/10-run-flash-kernel.sh`. Before the `/usr/sbin/flash-kernel` call, add a step that patches `/usr/share/flash-kernel/its/image-kria.its` as in design D1:
      - limit the edit to the range from `kernel-1 {` to the first `};`
      - replace `os = "linux";` with `os = "efi";` and `compression = "gzip";` with `compression = "none";`
      - skip the edit if `kernel-1` already has `efi`/`none`
      - exit non-zero and name the file if, after the edit, the `kernel-1` values are not `efi`/`none`

      Verify: run `bash -n` on the script. Then point the patch step at copies of the template, using a path variable that defaults to the real path, and check three inputs:
      - the template from `out/kria-server-rootfs.tar.gz`: `diff` shows only lines 17–18 changed
      - an already-patched copy: unchanged, exit 0
      - a copy with `kernel-1` values removed: exit non-zero
- [x] 1.2 Commit with a message that covers the zboot PE kernel, the `Bad gzipped data` failure and the fix, plus `Signed-off-by`. Export it with `git format-patch -1` to `patches/xlnx-image-definitions/0001-kria-resolute-mark-zboot-kernel-as-efi-in-FIT.patch` in this repo. Verify: `git am --3way` applies the patch cleanly to a fresh `kria-resolute` checkout, and `git log -1 --format=%B` shows the `Signed-off-by` trailer.
- [x] 1.3 Add `patches/xlnx-image-definitions/README.md` stating the base commit (`2438593`), how to apply (`git am`), and how to roll back (`git revert`). Verify that the commands in it run as written against a scratch clone.

## 2. Image-build spec text

- [x] 2.1 Check every value in `specs/image-build/spec.md` of this change against the source tree and against `out/` from the last build:
      - PPA names and fingerprints against `ubuntu-server-kria.yaml`
      - package versions against `kria-server.manifest`
      - partition table against `sfdisk -d out/kria-server.img`
      - DTB and configuration names against `dumpimage -l out/image.fit`
      - the `kv-g-revB` selection against `bootscr.zynqmp.kria`

      Verify: each scenario value matches, and `openspec validate refine-image-build-spec --strict` passes.
- [x] 2.2 Record the discrepancies found in the external guide, to pass on to its owner (no edits outside this repo), as a short note in `patches/xlnx-image-definitions/README.md`:
      - step 3 omits the hook's `out` argument
      - README.md's runtime PK clearing cannot work with `CONFIG_EFI_VARIABLES_PRESEED=y`

      Verify: the note is present.

## 3. Rebuild and inspect the image

- [x] 3.1 [manual] Apply the patch to the `xlnx-image-definitions` `kria-resolute` checkout, then run `sudo ubuntu-image classic --debug -w work -O out classic/resolute/ubuntu-server-kria.yaml` from its root. Verify: `out/kria-server.img`, `out/kria-server-rootfs.tar.gz` and `out/kria-server.manifest` exist, and the manifest versions match the spec or are newer.
- [ ] 3.2 [manual] Run `sudo bash hooks/kria/classic/10-flash-kernel-fitimage out`. Verify: partition 1 holds `image.fit` and `boot.scr.uimg`, and `work/` is gone.
- [x] 3.3 [manual] Loop-mount partition 1 read-only and run `dumpimage -l` on `image.fit`. Verify:
      - `kernel-1` shows `Compression: uncompressed`, `OS: EFI Firmware` and load/entry `0x00200000`
      - `ramdisk-1` is unchanged
      - all 6 DTBs and 6 configurations are present

      Save the listing as evidence (task 4.2).
- [x] 3.4 Extract `kernel-1` with `dumpimage -T flat_dt -p 0 -o kernel image.fit`. Verify: `file kernel` reports `PE32+ executable (EFI application) Aarch64`.

## 4. Boot verification on KV260

- [x] 4.1 [manual] Write `out/kria-server.img` to a microSD card with `dd ... conv=fsync`. Boot a KV260 (`SCK-KV-G` rev B) running BSP 2026.1 `boot.bin` (U-Boot xilinx-v2026.1, Secure Boot disabled as in the `secure-boot` spec), and capture serial on `ttyPS1` at 115200. Verify:
      - the log shows `Kria DT: #conf-smk-k26-revA-sck-kv-g-revB`
      - there is no `Bad gzipped data`
      - the kernel starts through the EFI loader
      - the system reaches a login prompt
      - `/` is mounted from `LABEL=writable` and `/boot/firmware` from `LABEL=system-boot`
- [x] 4.2 Record the result under `docs/evidence/image-build/`: the serial boot log, the `dumpimage -l` listing, `sfdisk -d` output, the manifest versions and the date and outcome (pass or fail). Verify: the files are committed with a `Signed-off-by` trailer.
- [x] 4.3 [manual] Recovery check: take an image built without the patch, apply the `fdtput` relabel from the spec to partition 1, and boot it on KV260. Verify: `fdtget` reports `efi`/`none`, the board reaches a login prompt, and the result is added to `docs/evidence/image-build/`.

## Workflow follow-up

- Archive the change once the KV260 boot result is recorded and reviewed, so that `openspec/specs/image-build/spec.md` is updated.
