# kernel-packaging Specification

## Purpose
How the default Resolute kernel is used without recompiling it from source.

## Requirements

### Requirement: Use the default distro kernel
The project SHALL use the default Resolute kernel package (linux-amd-embedded) as shipped, and SHALL NOT rebuild the kernel from source.

#### Scenario: Kernel provenance
- **WHEN** any board image is prepared
- **THEN** its kernel binary comes from the Ubuntu kernel package, either as-is or extracted from it

### Requirement: Raw Image extraction from the zboot PE
For firmware that cannot run EFI applications from a FIT, the raw arm64 `Image` SHALL be extracted from the zboot PE by reading the payload offset and size from the zboot header and decompressing the payload (zstd).

#### Scenario: Extracting the kernel
- **WHEN** the extraction script is run on the kernel taken from the Ubuntu FIT image
- **THEN** it produces a file that `file` identifies as a Linux arm64 boot executable Image

### Requirement: Initrd reused unchanged
The initrd SHALL be taken from the Ubuntu FIT image without any changes.

#### Scenario: Building the CL1 FIT
- **WHEN** the CL1 FIT is assembled
- **THEN** its ramdisk is byte-identical to the one in the Ubuntu FIT image
