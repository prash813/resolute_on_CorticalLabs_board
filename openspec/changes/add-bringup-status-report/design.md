# Design

## Context

Both boards boot Resolute. The supporting work now lives on three branches of this repo, with a few evidence files still outside it. The report has to pull these together without changing the builds, merging branches, or recapturing evidence that is already on disk.

**Image build** (`resolute-image-build`, tip `56f1e32`; change `refine-image-build-spec`, all tasks done). The image is a cross-build with `ubuntu-image classic` from `xlnx-image-definitions` branch `kria-resolute` at `2438593`. Packages come from `ubuntu-xilinx/default`, `kkaniewski/linux-amd-embedded` and `sinan-k/xlnx-flash-kernel` (`keep-enabled: false`). The only build-tree change is a Signed-off-by git patch, `patches/xlnx-image-definitions/0001-kria-resolute-mark-zboot-kernel-as-efi-in-FIT.patch`, which in the chroot just before flash-kernel runs relabels `image-kria.its` `kernel-1` from `os = "linux"` / `compression = "gzip"` to `os = "efi"` / `compression = "none"`. Known-good manifest versions, from `docs/evidence/image-build/2026-11-12-patched-manifest-versions.txt`: flash-kernel `3.110ubuntu2.5`, `linux-image-7.0.0-1003-amd-embedded` `7.0.0-1003.3`, `oem-limerick-kria-meta` `0.22`, `oem-limerick-meta` `0.18~xlnx01`. The post-build `fdtput` relabel is kept as the documented recovery for images built without the patch.

**KV260 boot** (AMD EDF BSP 2026.1, U-Boot xilinx-v2026.1 / 2026.01). U-Boot runs `bootm` on a FIT whose kernel node is `os = "efi"`, `compression = "none"`. `bootm` hands off to the EFI loader (the `bootm -> bootefi` path, upstream v2025.07+, `CONFIG_BOOTM_EFI`). It passes the initrd through EFI_LOAD_FILE2, and the zboot PE decompresses itself. Evidence already committed under `docs/evidence/image-build/`: the full serial log `2026-11-12-kv260-patched-image-boot.log` (U-Boot 2026.01, `## Transferring control to EFI`, `Linux version 7.0.0-1003-amd-embedded`, login prompt on `Ubuntu 26.04.1 LTS kria ttyPS1`), the result summary, `dumpimage -l`, payload check, `sfdisk` layout, manifest versions, and `2026-11-12-kv260-recovery-fdtput-result.md` (host-side relabel checks pass; login observed by the developer, no serial log kept).

The untracked work-tree file `resolute_boot_newfs.log` is byte-identical to `2026-11-12-kv260-patched-image-boot.log` (sha1 `52798f2b9909c767ec49d2e942a737f715acf4f3`). It is a KV260 log, not a CL1 log. It must not be committed and must not be cited as CL1 evidence.

**CL1 boot** (BSP 2023.2, U-Boot 2024.01, RAUC A/B on eMMC). U-Boot runs `bootm` on a FIT whose kernel node is `os = "linux"` and holds the raw arm64 `Image` extracted from the zboot PE, together with the unchanged Resolute initrd and the Cortical Labs DTB from the Noble FIT. Bootargs come from an environment file in `/boot/firmware` on the RAUC root slot. The host script that reproduces this FIT, and the `.its` it fills in, are on `script-cl1-fit-image-build` at `83713fb` (`scripts/build-cl1-fit.sh`, `fit/image-cortlab.its`). The `.its` kernel node is `os = "linux"`, `compression = "none"`, load and entry `0x00200000`. Cite those files with `git show script-cl1-fit-image-build:path`. Do not merge that branch.

A planning-only copy of change `script-cl1-fit-image-build` also exists on `main` (`0be50c7`) and therefore on this branch. Its wording differs slightly from the script-branch copy (the script branch adds "None of the existing files should get overwritten" and a rewritten Why/Purpose), and its tasks are unchecked, because the implementation files are not on this lineage.

CL1 FIT artifacts already on disk, not in this branch's git tree (do not commit the binaries):

- The 29 Oct hand-built FIT, `/home/prashant.dhumal@canonical.com/development/canonical_projects/CorticalLabs/kria_images/xlnx-image-definitions/out/cortical_labs_dtb/image.ub` (`Created: Thu Oct 29 17:15:28 2026`).
- The 12 Nov script output, untracked `scripts/image.ub` in this work tree (`Created: Thu Nov 12 13:44:36 2026`). The payload hashes match the Oct 29 FIT: kernel sha1 `93dd62437a5c3beb300af5d7d9d0fa75a08fb58f`, 72,941,568 bytes, `OS: Linux`, uncompressed, load/entry `0x00200000`; ramdisk sha1 `f45f21710e268206b2032f1f605290534ddab9fc`; fdt sha1 `4954f5ae74dfe42c0e3d27f37d27ed30f02fedef`. The work-directory `.its` is identical to `git show script-cl1-fit-image-build:fit/image-cortlab.its`.

CL1 runtime evidence, still outside the repo:

- `/home/prashant.dhumal@canonical.com/development/canonical_projects/CorticalLabs/resolute_logs.txt` (29 Oct 2026): a root shell on the running board, `PRETTY_NAME="Ubuntu 26.04.1 LTS"`, a kernel command line with `systemd.hostname=CL1-2507-30`, `rauc.slot=A` and `console=ttyPS0,115200`, and `dmesg` excerpts for eMMC (`mmcblk0` 14.8 GiB, p1–p3), NVMe (`nvme0n1`) and USB (two xHCI controllers; a SanDisk device on `usb 1-1`). The kernel is `7.0.0-1001-amd-embedded` — the earlier image, not the 12 Nov `1003` patched KV260 image. This is not a U-Boot-to-login serial capture, and it has no ethernet, `lsusb`, `ethtool` or `lsblk` command output.
- `/home/prashant.dhumal@canonical.com/development/canonical_projects/CorticalLabs/booting_resolute.logs`: the developer's 29 Oct note that the image booted and that eMMC, ethernet, NVMe, USB Type-A and USB Type-C enumerated. This is developer-reported, not instrumented output.
- `/home/prashant.dhumal@canonical.com/development/canonical_projects/CorticalLabs/u-boot-xlnx-24.1/u-boot-xlnx/uboot-cortboard-reoslute-booting.log`: a *failed* 29 Oct attempt on the CL1 (U-Boot 2024.01, RAUC slot A) with a FIT whose kernel was `OS: EFI Firmware` (17,519,104-byte PE, sha1 `bf027085163b594938bf078f4ab5af675743abf7`), ending in a Synchronous Abort. Useful as contrast for why the raw-`Image` FIT is required; it is not success evidence. This also matches the `boot-chain` requirement that an `os = "efi"` FIT is not expected to work on U-Boot 2024.01.

## Goals / Non-Goals

**Goals:**
- A short report a manager can read in about 5 minutes, outcome first, covering image build, KV260 and CL1, with all the detail behind links.
- Every claim either reproducible or backed by evidence already on disk, or clearly marked as reported by the developer.

**Non-Goals:**
- No changes to images, firmware or the kernel.
- No merge of `script-cl1-fit-image-build` onto this branch.
- No new engineering work, only reporting what has been done. The report itself is written in the apply phase, not in this refinement.

## Decisions

- **Markdown in the repo plus a PDF export.** It's reviewable in git and renders on GitHub; `pandoc` can produce a PDF to attach to an email. The alternatives were slides or a doc outside the repo, which drift away from the specs.
- **One Mermaid diagram comparing the two boot flows.** It shows the key engineering point, that the stock kernel is used on both boards through different firmware paths, more clearly than prose.
- **Evidence folder.** Raw logs and listings go in `docs/reports/evidence/` (copied from `docs/evidence/image-build/` and from the external CL1 files named above) and the report links to them, so the report stays short. Existing paths are preferred over recapturing.
- **Cite the CL1 script by branch and commit.** The report may show file content via `git show script-cl1-fit-image-build:scripts/build-cl1-fit.sh` and `git show script-cl1-fit-image-build:fit/image-cortlab.its` at `83713fb`. Bringing those files onto this branch is not part of this change.
- **Size figures come from the image analysis.** Rootfs about 3,332 MiB; about 1.08 GiB of low-risk savings found; up to about 1.9 GiB pending validation. They are labelled as analysis, not as changes already made.
- **Be precise about kernel versions.** KV260 patched-image evidence is `7.0.0-1003-amd-embedded` (12 Nov). CL1 runtime evidence is `7.0.0-1001-amd-embedded` (29 Oct, classic FIT from the earlier image). The report must not imply that the 12 Nov patched image was also booted on the CL1.

## Risks / Trade-offs

- **The work-directory `.its` was earlier thought to have `os = "efi"`. It does not.** Both `out/cortical_labs_dtb/image-cortlab.its` and `fit/image-cortlab.its` on `script-cl1-fit-image-build` have `os = "linux"` and `compression = "none"`, and they are identical. The FIT that failed on the CL1 was a different, EFI-labelled PE FIT (the failed log above). Mitigation: the report cites `dumpimage -l` of the 29 Oct / 12 Nov classic FITs and the checked-in `.its`.
- **No complete CL1 U-Boot-to-login serial log has been found.** The KV260 log is captured. For the CL1 there is a running-system dmesg and os-release snippet, plus a developer note. Mitigation: a `[manual]` task captures the full boot log; until then, "CL1 boots Resolute" is marked as reported by the developer and linked to the partial evidence.
- **The KV260 recovery login has no serial log.** Already stated in `2026-11-12-kv260-recovery-fdtput-result.md`. The FIT checks were verified on the host. The report will say so.
- **Overselling.** Mitigation: state the open items plainly, namely Secure Boot disabled, the flash-kernel template fix not yet upstream, CL1 peripheral coverage only partial (no formal `lsusb` / `ethtool` / `lsblk`; no ethernet dmesg), and the two boards demonstrated with different kernel package versions.
- **`resolute_boot_newfs.log` looks like a leftover boot capture.** It is identical to the committed KV260 log. Leave it untracked.

## Open Questions

None. Resolved with the developer:
- Format: Markdown in the repo plus a PDF export (the PDF is required, not optional).
- Acknowledgements: credit colleagues' contributions, including Sinan (Launchpad `sinan-k`, PPA `sinan-k/xlnx-flash-kernel`) for the patched flash-kernel and the RP team for the Ubuntu Noble CL1 delivery whose device tree is reused.
