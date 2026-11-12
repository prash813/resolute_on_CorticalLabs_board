## ADDED Requirements

### Requirement: Bring-up status report in the repo
The project SHALL keep a bring-up status report as Markdown at `docs/reports/resolute-kria-bringup-status.md`, written for a management audience and leading with the outcome of the image build, the KV260 boot and the CL1 boot.

#### Scenario: Reading the report
- **WHEN** a manager opens the report
- **THEN** the first section states, per board, whether Resolute boots, on which boot firmware, and with which kernel, and states that a Resolute arm64 server image was produced for those boards

### Requirement: Report content
The report SHALL cover the goal, the obstacles, how the Resolute image is built (including the `.its` patch, package sources and the manifest), the approach and boot flow for each board, the KV260 recovery path, the CL1 classic FIT and the host script that builds it, the results including the peripherals tested, the other deliverables, the risks and open items, the next steps with the decisions or support needed, and acknowledgements of colleagues.

#### Scenario: Complete report
- **WHEN** the report is reviewed against this list
- **THEN** every item has its own section

### Requirement: Evidence-backed claims
Every result stated in the report SHALL link to evidence kept under `docs/reports/evidence/`, such as a boot log, `dumpimage -l` output, a manifest excerpt, a patch, or a config excerpt. Evidence already recorded under `docs/evidence/` or on a cited branch SHALL be reused (copied or linked) rather than recaptured. Results without complete evidence SHALL be marked as reported by the developer and, where partial evidence exists, SHALL still link to it.

#### Scenario: Checking a claim that has a complete log
- **WHEN** a reader follows the link for "KV260 boots Resolute"
- **THEN** it opens a serial console log showing U-Boot 2026.01, the EFI hand-off, the Resolute kernel version and a login prompt on the KV260

#### Scenario: Checking a claim whose complete log is still missing
- **WHEN** a reader follows the link for "CL1 boots Resolute" and `docs/reports/evidence/cl1-boot.log` is not yet present
- **THEN** the report marks the claim as reported by the developer and links to the partial runtime evidence (os-release, kernel command line and dmesg excerpts)

### Requirement: Traceability to specs
The report SHALL reference the baseline specs (`image-build`, `boot-chain`, `kernel-packaging`, `secure-boot`, `cl1-board-bringup`) that describe each result, SHALL reference the OpenSpec changes `refine-image-build-spec` (on `resolute-image-build`) and `script-cl1-fit-image-build` (on `script-cl1-fit-image-build` at commit `83713fb`) where those changes produced the result, and SHALL list proposed follow-up work as candidate OpenSpec changes.

#### Scenario: Follow-up work
- **WHEN** the next steps section is read
- **THEN** each item names a candidate change, such as `fix-flash-kernel-zboot-its`, `slim-server-image`, `re-enable-uefi-secure-boot`, or landing `script-cl1-fit-image-build` on main

### Requirement: Acknowledgements
The report SHALL include an Acknowledgements section that credits Sinan (Launchpad `sinan-k`, PPA `sinan-k/xlnx-flash-kernel`) for the patched flash-kernel used in the image, and the RP team for the Ubuntu Noble CL1 delivery whose device tree is reused on the CL1 FIT.

#### Scenario: Reading acknowledgements
- **WHEN** a reader opens the Acknowledgements section
- **THEN** both Sinan and the RP team are named, each with what they contributed
