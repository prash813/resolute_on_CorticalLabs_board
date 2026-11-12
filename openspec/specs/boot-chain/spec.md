# boot-chain Specification

## Purpose
How each supported board gets from boot firmware to the Resolute kernel, initrd and device tree.

## Requirements

### Requirement: KV260 boots the PE kernel from a FIT via bootm -> bootefi
On KV260 with AMD EDF BSP 2026.1 boot firmware (U-Boot xilinx-v2026.1), U-Boot SHALL load the FIT with `bootm`, which hands the EFI kernel image to the EFI loader together with the initrd and device tree.

#### Scenario: KV260 boot
- **WHEN** the KV260 boots with BSP 2026.1 boot.bin and the Resolute image
- **THEN** the Resolute kernel starts with the initrd and reaches a login prompt

### Requirement: Minimum firmware for the PE FIT flow
Booting the unmodified PE kernel from a FIT SHALL require U-Boot v2025.07 or newer (AMD EDF BSP 2026.1 or newer). Boards with older firmware SHALL use the raw kernel flow instead.

#### Scenario: Old firmware with a PE FIT
- **WHEN** a FIT with an `os = "efi"` kernel is booted with U-Boot 2024.01
- **THEN** the boot is not expected to work (the initrd is not passed and loading may crash), and the raw kernel flow must be used

### Requirement: CL1 boots a raw arm64 kernel via the classic FIT flow
On the Cortical Labs CL1 board with its BSP 2023.2-based U-Boot, the boot SHALL use a FIT containing the raw arm64 `Image` (`os = "linux"`), the Resolute initrd and the Cortical Labs device tree, booted with `bootm`.

#### Scenario: CL1 boot
- **WHEN** the CL1 boots its existing U-Boot with the Resolute FIT and the updated U-Boot environment from `/boot/firmware`
- **THEN** the Resolute kernel starts with the initrd and reaches a login prompt
