# Spec Delta

## Purpose

Assemble, on the build host, the classic FIT image that Cortical Labs CL1 U-Boot (BSP 2023.2, 2024.01) boots with `bootm`.

## ADDED Requirements

### Requirement: Build a CL1 FIT from a Resolute FIT and a device tree
The build SHALL produce one FIT image from a Resolute FIT and a Cortical Labs device tree blob supplied by the developer. It SHALL use the kernel and ramdisk contained in that Resolute FIT and SHALL NOT rebuild the kernel from source. It SHALL leave both input files unchanged.

#### Scenario: Successful build
- **WHEN** the developer runs the build with a Resolute FIT that contains a kernel image and a ramdisk, and with the Cortical Labs `system.dtb`
- **THEN** the output is a FIT whose default configuration selects that kernel, that ramdisk, and that device tree

#### Scenario: Inputs stay intact
- **WHEN** the build finishes, successfully or not
- **THEN** the Resolute FIT and the device tree blob have the same contents as before the build

### Requirement: Kernel node is the raw arm64 Image
The FIT kernel node SHALL be the uncompressed arm64 `Image` extracted from the EFI zboot PE stored as the kernel in the Resolute FIT. The node SHALL describe OS Linux with no compression, load address `0x00200000`, and entry point `0x00200000`.

#### Scenario: Kernel node inspection
- **WHEN** the output FIT is listed with `dumpimage -l`
- **THEN** the kernel image is reported as Linux, uncompressed, with load address `0x00200000` and entry point `0x00200000`
- **AND** extracting that node and running `file` on it reports a Linux arm64 boot executable Image

#### Scenario: Zboot payload is not usable
- **WHEN** the kernel in the Resolute FIT is not an EFI zboot image whose header names a payload the host can decompress
- **THEN** the build fails and does not leave an output FIT

### Requirement: Ramdisk is copied unchanged
The FIT ramdisk SHALL be byte-identical to the ramdisk in the input Resolute FIT.

#### Scenario: Ramdisk identity
- **WHEN** the CL1 FIT has been built
- **THEN** the ramdisk node has the same size and the same hash as the ramdisk node in the input Resolute FIT

### Requirement: Device tree is the supplied Cortical Labs blob
The FIT fdt node SHALL be byte-identical to the device tree blob the developer passed in, and SHALL use load address `0x44000000`.

#### Scenario: Device tree identity
- **WHEN** the CL1 FIT has been built
- **THEN** the fdt node has the same size and the same hash as the supplied device tree blob, and its load address is `0x44000000`

### Requirement: Incomplete inputs fail the build
The build SHALL refuse to write an output FIT when the Resolute FIT does not contain both a kernel image and a ramdisk, or when the device tree blob is missing.

#### Scenario: Resolute FIT lacks a ramdisk
- **WHEN** the developer runs the build with a FIT that has no ramdisk image
- **THEN** the build fails and does not leave an output FIT
