# Design

## Context

Both boards boot Resolute. Most of the supporting facts live outside this repo: the build tree in `kria_images/xlnx-image-definitions`, the EDF 2026.1 tree with meta-mok commit 2015820, the CL1 FIT inputs in `out/cortical_labs_dtb/`, and the developer's notes. The report has to pull these together without changing any of them.

Boot flows to describe:
- KV260: U-Boot xilinx-v2026.1 runs `bootm` on a FIT whose kernel node is `os = "efi"`, `compression = "none"`. `bootm` hands off to the EFI loader (the `bootm -> bootefi` path, upstream v2025.07+). It passes the initrd through EFI_LOAD_FILE2, and the zboot PE decompresses itself.
- CL1: U-Boot 2024.01 runs `bootm` on a FIT whose kernel node is `os = "linux"` and holds the raw arm64 `Image` extracted from the zboot PE. It also carries the unchanged Resolute initrd and the Cortical Labs DTB from the Noble FIT. Bootargs come from an environment file in `/boot/firmware` on the RAUC root slot.

## Goals / Non-Goals

**Goals:**
- A short report a manager can read in about 5 minutes, outcome first, with all the detail behind links.
- Every claim either reproducible or backed by evidence.

**Non-Goals:**
- No changes to images, firmware or the kernel.
- No new engineering work, only reporting what has been done.

## Decisions

- **Markdown in the repo plus a PDF export.** It's reviewable in git and renders on GitHub; `pandoc` can produce a PDF to attach to an email. The alternatives were slides or a doc outside the repo, which drift away from the specs.
- **One Mermaid diagram comparing the two boot flows.** It shows the key engineering point, that the stock kernel is used on both boards through different firmware paths, more clearly than prose.
- **Evidence folder.** Raw logs and listings go in `docs/reports/evidence/` and the report links to them, so the report stays short.
- **Size figures come from the image analysis.** Rootfs about 3,332 MiB; about 1.08 GiB of low-risk savings found; up to about 1.9 GiB pending validation. They are labelled as analysis, not as changes already made.

## Risks / Trade-offs

- **The CL1 FIT in `out/cortical_labs_dtb/image-cortlab.its` may not be the one that booted.** That file has `os = "efi"`. Mitigation: record the `.its` and `dumpimage -l` output of the FIT that actually booted.
- **No boot logs are captured yet for the final working boots.** Mitigation: tasks capture them by hand. Until then, those claims are marked as reported by the developer.
- **Overselling.** Mitigation: state the open items plainly, namely Secure Boot disabled, the flash-kernel template fix not yet upstream and CL1 peripheral coverage only partial.

## Open Questions

None. Resolved with the developer:
- Format: Markdown in the repo plus a PDF export (the PDF is required, not optional).
- Acknowledgements: credit colleagues' contributions, including Sinan (sinan-k) for the patched flash-kernel PPA and the RP team for the Ubuntu Noble CL1 delivery whose device tree is reused.
