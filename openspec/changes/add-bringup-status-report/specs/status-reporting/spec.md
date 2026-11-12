## ADDED Requirements

### Requirement: Bring-up status report in the repo
The project SHALL keep a bring-up status report as Markdown at `docs/reports/resolute-kria-bringup-status.md`, written for a management audience and leading with the outcome.

#### Scenario: Reading the report
- **WHEN** a manager opens the report
- **THEN** the first section states, per board, whether Resolute boots, on which boot firmware, and with which kernel

### Requirement: Report content
The report SHALL cover the goal, the obstacles, the approach and boot flow for each board, the results including the peripherals tested, the other deliverables, the risks and open items, and the next steps with the decisions or support needed.

#### Scenario: Complete report
- **WHEN** the report is reviewed against this list
- **THEN** every item has its own section

### Requirement: Evidence-backed claims
Every result stated in the report SHALL link to evidence kept under `docs/reports/evidence/`, such as a boot log, `dumpimage -l` output or a config excerpt. Results without evidence SHALL be marked as reported by the developer.

#### Scenario: Checking a claim
- **WHEN** a reader follows the link for "CL1 boots Resolute"
- **THEN** it opens a serial console log showing the Resolute kernel version and a login prompt on the CL1

### Requirement: Traceability to specs
The report SHALL reference the baseline specs (`image-build`, `boot-chain`, `kernel-packaging`, `secure-boot`, `cl1-board-bringup`) that describe each result, and SHALL list proposed follow-up work as candidate OpenSpec changes.

#### Scenario: Follow-up work
- **WHEN** the next steps section is read
- **THEN** each item names a candidate change, such as `fix-flash-kernel-zboot-its`, `automate-cl1-fit-build`, `slim-server-image` or `re-enable-uefi-secure-boot`
