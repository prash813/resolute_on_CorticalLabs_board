# Tasks

## 1. Evidence collection

- [ ] 1.1 [manual] Boot the KV260 with the BSP 2026.1 boot.bin and capture the serial console from U-Boot to login into `docs/reports/evidence/kv260-boot.log`; verify the log shows the Resolute kernel version and a login prompt
- [ ] 1.2 [manual] Boot the CL1 Resolute slot and capture the serial console into `docs/reports/evidence/cl1-boot.log`; verify the log shows U-Boot 2024.01, the FIT load, the Resolute kernel version and a login prompt
- [ ] 1.3 [manual] On the CL1, record `lsusb -t`, `ip -br link`, `ethtool` on the 1G port and `lsblk` for NVMe into `docs/reports/evidence/cl1-peripherals.txt`; verify USB Type-A, Type-C, Ethernet and NVMe each appear
- [ ] 1.4 Save `dumpimage -l` for the KV260 FIT and for the CL1 FIT that booted, plus the CL1 `.its`, into `docs/reports/evidence/`; verify the kernel nodes show `efi`/`none` for KV260 and `linux` for CL1
- [ ] 1.5 Save the excerpt of the KV260 U-Boot `.config` showing `# CONFIG_EFI_SECURE_BOOT is not set` and the meta-mok commit 2015820 summary into `docs/reports/evidence/secure-boot.txt`; verify both are present

## 2. Report

- [ ] 2.1 Write `docs/reports/resolute-kria-bringup-status.md`, opening with an outcome summary per board (firmware, kernel, boot result); verify the summary fits on one screen
- [ ] 2.2 Add sections for the goal and obstacles, the approach for each board, a Mermaid boot-flow diagram, results, other deliverables, risks and open items, and next steps; verify each item from the `status-reporting` spec has a section and the Mermaid block renders on GitHub
- [ ] 2.3 Link each result to its evidence file and each section to the matching baseline spec; verify every relative link resolves (`grep -o '](\.[^)]*)'` and check each path exists)
- [ ] 2.4 List next steps as candidate OpenSpec changes with the support or decisions needed; verify each has a one-line justification

- [ ] 2.5 Add an Acknowledgements section crediting Sinan (sinan-k) for the patched flash-kernel PPA and the RP team for the Noble CL1 delivery and its device tree; verify both are named with what they contributed

## 3. Review and export

- [ ] 3.1 Export a PDF with `pandoc docs/reports/resolute-kria-bringup-status.md -o docs/reports/resolute-kria-bringup-status.pdf`; verify the PDF opens and the diagram is legible (render Mermaid to an image first if needed)
- [ ] 3.2 [manual] Developer review for accuracy and tone, then commit with an explanatory message and Signed-off-by; verify `git log` shows the commit

## Workflow follow-up

- Archive the change after the report has been shared and accepted.
