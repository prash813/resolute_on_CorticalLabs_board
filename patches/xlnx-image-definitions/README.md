# Patches for xlnx-image-definitions

Patches against <https://github.com/canonical/xlnx-image-definitions>, branch
`kria-resolute` (tracking `origin/kria-resolute-definition`), base commit
`2438593` ("kria: resolute: test with sinan-k/xlnx-flash-kernel PPA").

| Patch | Purpose |
|---|---|
| `0001-kria-resolute-mark-zboot-kernel-as-efi-in-FIT.patch` | In `classic/resolute/10-run-flash-kernel.sh`, before flash-kernel runs in the chroot, set the `kernel-1` node of `image-kria.its` to `os = "efi"` / `compression = "none"`, so the generated `image.fit` boots the EFI zboot PE kernel on KV260 (BSP 2026.1). |

## Apply

Run these from the root of the `xlnx-image-definitions` checkout. `PATCHES`
points at this directory:

```bash
PATCHES=/home/prashant.dhumal@canonical.com/development/canonical_projects/CorticalLabs/resolute_on_CorticalLabs_board/patches/xlnx-image-definitions
git checkout kria-resolute
git merge-base --is-ancestor 2438593 HEAD && echo "base OK"
git am --3way "$PATCHES"/0001-kria-resolute-mark-zboot-kernel-as-efi-in-FIT.patch
git log --oneline -1   # kria: resolute: mark the zboot kernel as EFI in the FIT
```

Then build the image and run the FIT hook as described in the `image-build`
spec:

```bash
sudo ubuntu-image classic --debug -w work -O out classic/resolute/ubuntu-server-kria.yaml
sudo bash hooks/kria/classic/10-flash-kernel-fitimage out
```

## Roll back

```bash
git revert --no-edit "$(git log --format=%H -1 --grep='mark the zboot kernel as EFI in the FIT')"
```

Images built after a rollback need the post-build `fdtput` relabel of
`image.fit` (see the `image-build` spec, "Post-build FIT relabel as recovery").

## Notes for the build guide owner

These are discrepancies in the guides under `kria_images/`. They are recorded
here because those files are outside this repo and are not edited from it.

- `KV260-ubuntu-26.04-build.md` step 3 runs
  `sudo bash hooks/kria/classic/10-flash-kernel-fitimage` with no argument. The
  hook takes the image directory from `$1`, so without it the hook prints
  `No image file found in` and exits 1. The command should be
  `sudo bash hooks/kria/classic/10-flash-kernel-fitimage out`.
- `README.md` ("disabling secure boot while development") clears PK at runtime
  with `setenv -e -nv -bs -rt -at -i ... PK` and a self-signed `noPK.auth`. On
  the KV260 U-Boot, which is built with `CONFIG_EFI_VARIABLES_PRESEED=y`,
  PK/KEK/db/dbx are write-protected, so the command fails with "invalid
  parameter" (build guide, Troubleshooting). Secure Boot has to be disabled
  at build time instead (meta-mok commit `2015820`, see the `secure-boot`
  spec).
- Once this patch is applied, step 4 of the build guide ("[TEMP] Fix the FIT
  kernel node") is only needed for images built without the patch.
