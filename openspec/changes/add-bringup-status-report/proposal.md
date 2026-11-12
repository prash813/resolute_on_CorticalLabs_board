# Proposal

## Why

Ubuntu 26.04 (Resolute) now boots on both the KV260 EVK and the Cortical Labs CL1 board. There is no official Resolute server image for Kria SOM, so this is the first working early-access image. The work, its results and the next steps are spread across chat, build logs and local trees. Management needs one clear, evidence-backed status report to judge the outcome and decide on follow-up work.

## What Changes

- Add a manager-facing bring-up status report to the repo, at `docs/reports/resolute-kria-bringup-status.md`, with a PDF export.
- The report covers:
  - the goal and why it matters
  - the approach for each board
  - the KV260 and CL1 boot flows
  - the results and the peripherals tested
  - the other deliverables (build guide, image size analysis, OpenSpec setup)
  - risks, open items, next steps and acknowledgements of colleagues
- Every claim in the report links to evidence kept in the repo: boot logs, FIT image listings and build configuration excerpts, under `docs/reports/evidence/`.
- Out of scope: any change to the image build, the boot firmware or the kernel. Out of scope: publishing outside the repo; the developer shares the report.

## Capabilities

### New Capabilities
- `status-reporting`: how project status reports are produced and kept, tied to the specs and backed by recorded evidence.

### Modified Capabilities
<!-- none -->

## Impact

- Boards: KV260 EVK (AMD EDF BSP 2026.1 firmware, U-Boot xilinx-v2026.1) and Cortical Labs CL1 (BSP 2023.2-based firmware, U-Boot 2024.01). Both are reported on; neither is changed.
- New files under `docs/reports/` only. There are no code or build changes.
- Collecting evidence needs serial console captures from both boards, which the developer does by hand.
