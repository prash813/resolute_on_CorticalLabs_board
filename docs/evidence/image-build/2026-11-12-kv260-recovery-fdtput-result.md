# KV260 recovery path: post-build `fdtput` relabel (2026-11-12)

**Outcome: PASS.** The FIT checks below were verified from files on the host. The login prompt was observed by the developer; no serial log was kept.

This covers the `image-build` requirement "Post-build FIT relabel as recovery": an image built **without** the `.its` patch boots on KV260 once `image.fit` has been relabelled with `fdtput`.

## Input

| Item | Value |
|---|---|
| Unpatched FIT | `image.fit` from the build of `xlnx-image-definitions` `kria-resolute` `2438593` without the patch. Created `Mon Oct 19 19:59:03 2026`, sha1 `2de63ea26872b7f883f5a8dbfdffac73422b6692`. `kernel-1` is `os = "linux"`, `compression = "gzip"`. |
| Relabel | `fdtput -t s image.fit /images/kernel-1 os efi`; `fdtput -t s image.fit /images/kernel-1 compression none` |
| Relabelled FIT that was booted | `image_working_19thoct.fit`, 114421628 bytes, sha1 `ea32cabaa63ba867cfdd1be0efe2bd9bede52272` |
| Board and firmware | the same KV260 and BSP 2026.1 / U-Boot 2026.01 as in `2026-11-12-kv260-patched-image-result.md` |

## Results

| Check | Evidence | Result |
|---|---|---|
| `fdtget … /images/kernel-1 os` gives `efi` | run by the developer on `image_working_19thoct.fit` and re-run during this review | pass |
| `fdtget … /images/kernel-1 compression` gives `none` | as above | pass |
| Relabelled FIT is exactly what the spec procedure produces | applying both `fdtput` edits to the unpatched FIT gives a file byte-identical to `image_working_19thoct.fit` (`cmp`) | pass |
| Kernel hash in the FIT still verifies | the extracted `kernel-1` has sha1 `bf027085163b594938bf078f4ab5af675743abf7`, equal to the FIT hash node. `fdtput` changes only properties, not image data. | pass |
| `dumpimage -l` | `kernel-1`: `Compression: uncompressed`, `OS: EFI Firmware`, 17519104 bytes, load/entry `0x00200000` | pass |
| Board boots and reaches a login prompt | **reported by the developer, no serial log kept** | pass (developer-observed) |

## Notes

- **Earlier partial capture:** an earlier serial capture of this FIT on the same board ended at kernel time 0.097 s. Before it stopped, it showed:
  - U-Boot reading 114421628 bytes
  - `kernel-1` at `OS: EFI Firmware` / `uncompressed`, hash `bf027085…`, `sha1+ OK`
  - `## Transferring control to EFI`
  - `Linux version 7.0.0-1001-amd-embedded`

  That file was later removed and is not kept here.
- **What the recovery fixes:** the relabel only changes how U-Boot loads the kernel. A root filesystem from an unpatched build still has the stock `image-kria.its`, so a later flash-kernel run on the board writes a `gzip`/`linux` FIT again (see design.md, Risks).
