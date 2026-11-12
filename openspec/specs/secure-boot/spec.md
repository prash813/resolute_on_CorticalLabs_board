# secure-boot Specification

## Purpose
The current state of UEFI Secure Boot in the Kria boot firmware used by this project.

## Requirements

### Requirement: Secure Boot temporarily disabled on KV260
The KV260 U-Boot built from AMD EDF 2026.1 SHALL be built with `CONFIG_EFI_SECURE_BOOT` disabled (meta-mok commit 2015820), because the distro kernel is not signed with keys enrolled in db.

#### Scenario: Verifying the build
- **WHEN** the U-Boot `.config` used for boot.bin is inspected
- **THEN** it contains `# CONFIG_EFI_SECURE_BOOT is not set`

### Requirement: Path back to Secure Boot
Re-enabling Secure Boot SHALL be done as a separate change that makes the kernel verifiable (signed or its hash in db) and then reverts commit 2015820.

#### Scenario: Re-enabling
- **WHEN** a change re-enables Secure Boot
- **THEN** the KV260 still boots the Resolute kernel with Secure Boot enforced
