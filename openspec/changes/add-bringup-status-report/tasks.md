# Tasks

## 1. Existing evidence (copy, do not recapture)

- [x] 1.1 Copy the KV260 patched-image evidence already on this branch under `docs/evidence/image-build/` into `docs/reports/evidence/`, leaving the originals in place: `2026-11-12-kv260-patched-image-boot.log`, `2026-11-12-kv260-patched-image-result.md`, `2026-11-12-patched-image.fit.dumpimage-l.txt`, `2026-11-12-patched-fit-payload-check.txt`, `2026-11-12-patched-kria-server.img.sfdisk.txt`, `2026-11-12-patched-manifest-versions.txt`. These landed in `ef16947` on `resolute-image-build` (tip `56f1e32`). Verify: the boot log shows U-Boot 2026.01, `## Transferring control to EFI`, `Linux version 7.0.0-1003-amd-embedded` and `Ubuntu 26.04.1 LTS kria ttyPS1` / `kria login:`; `dumpimage -l` shows kernel-1 as `OS: EFI Firmware`, uncompressed; each copied file is linkable from the report. This is the recorded KV260 boot verification; do not recapture it.

- [x] 1.2 Copy `docs/evidence/image-build/2026-11-12-kv260-recovery-fdtput-result.md` (`8e16c6a`) into `docs/reports/evidence/`. Verify: the file records a PASS on the host-side `fdtput` checks (`os=efi`, `compression=none`, kernel hash unchanged) and states that the login prompt was observed by the developer with no serial log kept. Do not ask to recapture that boot.

- [x] 1.3 Save `dumpimage -l` of the CL1 classic FIT and the FIT source into `docs/reports/evidence/`. Write `cl1-image.ub.dumpimage-l.txt` from the 29 Oct bring-up FIT at `/home/prashant.dhumal@canonical.com/development/canonical_projects/CorticalLabs/kria_images/xlnx-image-definitions/out/cortical_labs_dtb/image.ub`, and note that the untracked work-tree `scripts/image.ub` (12 Nov, output of `build-cl1-fit.sh`) has the same payload hashes. Write `image-cortlab.its` from `git show script-cl1-fit-image-build:fit/image-cortlab.its` (commit `83713fb`). Do not add the FIT binaries to git. Verify: kernel-1 is `OS: Linux`, uncompressed, load/entry `0x00200000`, data size 72,941,568 bytes, sha1 `93dd62437a5c3beb300af5d7d9d0fa75a08fb58f`; ramdisk sha1 `f45f21710e268206b2032f1f605290534ddab9fc`; the `.its` has `os = "linux"` and `compression = "none"`.

- [x] 1.4 Copy the existing partial CL1 runtime evidence into `docs/reports/evidence/`, clearly labelled: `/home/prashant.dhumal@canonical.com/development/canonical_projects/CorticalLabs/resolute_logs.txt` (root shell, Ubuntu 26.04.1, kernel `7.0.0-1001-amd-embedded`, hostname `CL1-2507-30`, RAUC slot A, dmesg for eMMC, NVMe and USB); the developer note `/home/prashant.dhumal@canonical.com/development/canonical_projects/CorticalLabs/booting_resolute.logs`; and, labelled as a failed contrast, `/home/prashant.dhumal@canonical.com/development/canonical_projects/CorticalLabs/u-boot-xlnx-24.1/u-boot-xlnx/uboot-cortboard-reoslute-booting.log` (U-Boot 2024.01, `OS: EFI Firmware`, Synchronous Abort). Verify: none of these is a complete U-Boot-to-login success log. The work-tree file `resolute_boot_newfs.log` is identical to the KV260 patched-image boot log and must not be copied as CL1 evidence or committed.

- [x] 1.5 Save `docs/reports/evidence/secure-boot.txt` from sources already on disk: the KV260 boot log line `Secure Boot:    not authenticated, not encrypted`, and the excerpt in `/home/prashant.dhumal@canonical.com/development/canonical_projects/CorticalLabs/kria_images/KV260-ubuntu-26.04-build.md` for meta-mok commit `2015820` ("u-boot-xlnx: temporarily disable UEFI Secure Boot") and `# CONFIG_EFI_SECURE_BOOT is not set`. If the EDF build `.config` is on disk, include that line from it. Verify both the config line and the commit summary are present. This does not need sudo or a board.

## 2. Evidence still missing (board access)

- [ ] 2.1 [manual] Capture a complete CL1 serial console log from U-Boot 2024.01 through FIT load (kernel node `OS: Linux`, uncompressed raw Image), the Resolute kernel version, and a login prompt, into `docs/reports/evidence/cl1-boot.log`. If a log that already shows all of this exists, copy it instead of rebooting. Verify the log contains U-Boot 2024.01, the classic FIT load, a Resolute kernel version and a login prompt. Until this file exists, the report must mark "CL1 boots Resolute" as reported by the developer and link the partial evidence from 1.4.

- [ ] 2.2 [manual] On the CL1, record `lsusb -t`, `ip -br link`, `ethtool` on the 1G port and `lsblk` for NVMe into `docs/reports/evidence/cl1-peripherals.txt`. USB, NVMe and eMMC already appear in the 1.4 dmesg; ethernet is only in the developer note. Verify each of USB Type-A, Type-C, Ethernet and NVMe is either shown by these commands or, if a command cannot be taken, is explicitly marked as reported by the developer.

## 3. Report

- [x] 3.1 Write `docs/reports/resolute-kria-bringup-status.md`, opening with an outcome summary per board (firmware, kernel package version, boot result) and a one-paragraph image-build outcome (patched FIT, manifest versions). Verify the summary fits on one screen and distinguishes KV260's `7.0.0-1003-amd-embedded` (12 Nov patched image) from CL1's `7.0.0-1001-amd-embedded` (29 Oct classic FIT).

- [x] 3.2 Add sections for: the goal and obstacles; how the Resolute image is built (change `refine-image-build-spec`, the `.its`/zboot patch, build steps, PPAs, manifest); the KV260 approach and boot flow (`bootm` → `bootefi` on U-Boot xilinx-v2026.1) including the `fdtput` recovery path; the CL1 approach and boot flow (classic `bootm` on U-Boot 2024.01, raw Image FIT, RAUC slot, and `build-cl1-fit.sh` on `script-cl1-fit-image-build` at `83713fb`); a Mermaid diagram of the two boot flows; results and peripherals; other deliverables; risks and open items; next steps; acknowledgements. Verify each item from the `status-reporting` spec has a section and the Mermaid block renders on GitHub.

- [x] 3.3 Link each result to its evidence file and each section to the matching baseline spec and, where relevant, to `refine-image-build-spec` or `script-cl1-fit-image-build`. Verify every relative link resolves (`grep -o '](\.[^)]*)'` and check each path exists).

- [x] 3.4 List next steps as candidate OpenSpec changes with the support or decisions needed (for example `fix-flash-kernel-zboot-its`, `slim-server-image`, `re-enable-uefi-secure-boot`, and landing `script-cl1-fit-image-build` on main). Verify each has a one-line justification.

- [x] 3.5 Add an Acknowledgements section crediting Sinan (Launchpad `sinan-k`, PPA `sinan-k/xlnx-flash-kernel`) for the patched flash-kernel, and the RP team for the Ubuntu Noble CL1 delivery and its device tree. Verify both are named with what they contributed.

## 4. Review and export

- [ ] 4.1 Export a PDF with `pandoc docs/reports/resolute-kria-bringup-status.md -o docs/reports/resolute-kria-bringup-status.pdf`; verify the PDF opens and the diagram is legible (render Mermaid to an image first if needed).

- [ ] 4.2 [manual] Developer review for accuracy and tone, then commit with an explanatory message and Signed-off-by; verify `git log` shows the commit.

## Workflow follow-up

- Archive the change after the report has been shared and accepted.
