# Proposal

## Why

Ubuntu 26.04 (Resolute) now boots on both the KV260 EVK and the Cortical Labs CL1 board. There is no official Resolute server image for Kria SOM, so this is the first working early-access image.

The work is on three branches, and the first draft of this change only planned a bring-up report. The report should also present:

- how the Resolute image is built (the refined `image-build` spec, the `.its` patch that marks the zboot kernel as EFI, the build steps and the manifest)
- how that image boots on the KV260, including the post-build `fdtput` recovery path
- how the same distro kernel boots on the CL1, through a classic raw-`Image` FIT, and the host script that builds that FIT

The work, its results and the next steps would otherwise stay spread across those branches, build logs and local trees. Management needs one clear, evidence-backed status report covering all three workstreams, so the outcome can be judged and follow-up work decided.

## What Changes

- Add a manager-facing bring-up status report to the repo, at `docs/reports/resolute-kria-bringup-status.md`, with a PDF export.
- The report covers all three workstreams, using work already recorded on these branches. This change is refined on `resolute_on_kria_som_cl1_work_report`, forked from `resolute-image-build`. Branch `script-cl1-fit-image-build` is cited, not merged:
  - **Image build.** Change `refine-image-build-spec` on `resolute-image-build` (tip `56f1e32`): exact build steps, package sources and PPAs, the build-time `.its` patch (`patches/xlnx-image-definitions/0001-kria-resolute-mark-zboot-kernel-as-efi-in-FIT.patch`), expected outputs, and the known-good manifest versions.
  - **KV260 boot.** The patched-image boot (serial log through a login prompt) and the `fdtput` recovery path for images built without the patch. Evidence is already committed under `docs/evidence/image-build/`.
  - **CL1 boot.** A classic FIT (`os = "linux"`) that holds the raw arm64 `Image` extracted from the zboot PE, the unchanged Resolute initrd, and the Noble CL1 device tree from the RP team's delivery; plus the host script `scripts/build-cl1-fit.sh` and `fit/image-cortlab.its` on `script-cl1-fit-image-build` (`83713fb`). Cite those files with `git show script-cl1-fit-image-build:path`.
- The report also covers: the goal and why it matters; the approach and boot flow for each board; the results and the peripherals tested; the other deliverables (build guide, image-size analysis, OpenSpec setup); risks, open items and next steps; and acknowledgements of colleagues.
- Every claim in the report links to evidence kept under `docs/reports/evidence/` (copied there from existing paths, not recaptured). Results that still lack a complete log are marked as reported by the developer and, where partial evidence exists, still linked.
- Out of scope: any change to the image build, the boot firmware or the kernel; merging `script-cl1-fit-image-build` into this branch; publishing outside the repo (the developer shares the report).

## Capabilities

### New Capabilities
- `status-reporting`: how project status reports are produced and kept, tied to the specs and backed by recorded evidence.

### Modified Capabilities
<!-- none -->

## Impact

- Boards: KV260 EVK (AMD EDF BSP 2026.1 firmware, U-Boot xilinx-v2026.1) and Cortical Labs CL1 (BSP 2023.2-based firmware, U-Boot 2024.01). Both are reported on; neither is changed.
- New files under `docs/reports/` only. There are no code or build changes. The CL1 script and `.its` stay on `script-cl1-fit-image-build` and are referenced, not copied, by this change.
- Most KV260 and image-build evidence is already in the repo. A complete CL1 U-Boot-to-login serial log, and formal peripheral command output that is not already in the existing dmesg snippets, still need board access, which the developer does by hand.

## Acknowledgements

The report will credit Sinan (Launchpad `sinan-k`, PPA `sinan-k/xlnx-flash-kernel`) for the patched flash-kernel used in the image, and the RP team for the Ubuntu Noble CL1 delivery whose device tree is reused on the CL1 FIT.
