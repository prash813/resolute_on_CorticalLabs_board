# cl1-board-bringup Specification

## Purpose
How the Resolute image is installed and validated on the Cortical Labs CL1 board without replacing its boot firmware.

## Requirements

### Requirement: Keep the existing CL1 boot firmware
The CL1 bring-up SHALL keep the board's existing BSP 2023.2-based boot firmware and its RAUC A/B partitioning scheme.

#### Scenario: Firmware untouched
- **WHEN** Resolute is installed on the CL1
- **THEN** the QSPI boot firmware and the RAUC slot layout are unchanged

### Requirement: Device tree from the Noble delivery
The CL1 FIT SHALL use the Cortical Labs device tree from the Ubuntu Noble FIT image delivered by the earlier RP work on that board.

#### Scenario: DTB provenance
- **WHEN** the CL1 FIT is assembled
- **THEN** its fdt node is the Cortical Labs DTB from the Noble FIT image

### Requirement: Install into one RAUC root slot
The Resolute root filesystem SHALL be written to one of the two root partitions on eMMC, with the CL1 FIT image and the U-Boot environment file (with updated bootargs) copied to `/boot/firmware` on that partition.

#### Scenario: Booting the slot
- **WHEN** the board boots the slot holding Resolute
- **THEN** U-Boot loads the FIT and environment from that slot's `/boot/firmware` and Resolute boots

### Requirement: Peripheral validation
The CL1 bring-up SHALL check the board's main peripherals on Resolute.

#### Scenario: Peripherals verified so far
- **WHEN** Resolute is running on the CL1
- **THEN** USB Type-A, USB Type-C, 1G Ethernet and NVMe work
