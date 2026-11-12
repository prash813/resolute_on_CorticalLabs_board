#!/usr/bin/env bash
# Build the CL1 classic FIT (image.ub) for U-Boot 2024.01 bootm.
#
# scripts/build-cl1-fit.sh --fit <resolute-image.fit> --dtb <system.dtb> --out <dir>
#
# Writes <dir>/image.ub only. Does not modify the input FIT or DTB, and
# refuses to replace an existing image.ub.

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
its_src=${script_dir}/../fit/image-cortlab.its

fit=
dtb=
out=
workdir=
partial=

usage() {
	cat <<'EOF'
Usage: scripts/build-cl1-fit.sh --fit <resolute-image.fit> --dtb <system.dtb> --out <dir>

Options:
  --fit   Resolute FIT image containing the Ubuntu kernel and ramdisk
  --dtb   Cortical Labs device tree blob (system.dtb)
  --out   Directory in which to write image.ub
  --help  Show this help
EOF
}

die() {
	echo "build-cl1-fit: $*" >&2
	exit 1
}

cleanup() {
	if [[ -n ${partial} && -e ${partial} ]]; then
		rm -f "${partial}"
	fi
	if [[ -n ${workdir} && -d ${workdir} ]]; then
		rm -rf "${workdir}"
	fi
}
trap cleanup EXIT

while [[ $# -gt 0 ]]; do
	case $1 in
	--fit)
		[[ $# -ge 2 ]] || die "--fit needs a path"
		fit=$2
		shift 2
		;;
	--dtb)
		[[ $# -ge 2 ]] || die "--dtb needs a path"
		dtb=$2
		shift 2
		;;
	--out)
		[[ $# -ge 2 ]] || die "--out needs a directory"
		out=$2
		shift 2
		;;
	--help | -h)
		usage
		exit 0
		;;
	*)
		usage >&2
		die "unknown argument: $1"
		;;
	esac
done

[[ -n ${fit} && -n ${dtb} && -n ${out} ]] || {
	usage >&2
	die "--fit, --dtb, and --out are required"
}
[[ -f ${fit} ]] || die "FIT not found: ${fit}"
[[ -f ${dtb} ]] || die "DTB not found: ${dtb}"
[[ -f ${its_src} ]] || die "FIT source not found: ${its_src}"

if ! file -b "${dtb}" | grep -q "Device Tree Blob"; then
	die "not a device tree blob: ${dtb}"
fi

mkdir -p "${out}"
if [[ -e ${out}/image.ub ]]; then
	die "refusing to overwrite ${out}/image.ub"
fi

workdir=$(mktemp -d)
partial=${out}/image.ub.partial

indexes=$(dumpimage -l "${fit}" | python3 -c '
import re, sys
images = []
cur = None
for line in sys.stdin:
    match = re.match(r"\s*Image\s+(\d+)\s+\(", line)
    if match:
        cur = {"index": int(match.group(1)), "description": None}
        images.append(cur)
        continue
    if cur is not None and cur["description"] is None:
        desc = re.match(r"\s*Description:\s*(.*?)\s*$", line)
        if desc:
            cur["description"] = desc.group(1)

def find(name):
    for image in images:
        if image["description"] == name:
            return image["index"]
    return None

kernel = find("Ubuntu kernel")
ramdisk = find("Ubuntu ramdisk")
missing = []
if kernel is None:
    missing.append("Ubuntu kernel")
if ramdisk is None:
    missing.append("Ubuntu ramdisk")
if missing:
    print("FIT is missing: " + ", ".join(missing), file=sys.stderr)
    sys.exit(1)
print(kernel, ramdisk)
') || die "could not read kernel and ramdisk from ${fit}"

read -r kernel_index ramdisk_index <<<"${indexes}"

dumpimage -T flat_dt -p "${kernel_index}" -o "${workdir}/kernel.pe" "${fit}"
dumpimage -T flat_dt -p "${ramdisk_index}" -o "${workdir}/ramdisk_1" "${fit}"

python3 - "${workdir}/kernel.pe" "${workdir}/payload.zst" <<'PY'
import struct
import sys

src, dest = sys.argv[1], sys.argv[2]
data = open(src, "rb").read()
if len(data) < 28 or data[:2] != b"MZ" or data[4:8] != b"zimg":
    sys.exit("kernel is not an EFI zboot image (expected MZ and zimg)")
offset, size = struct.unpack_from("<II", data, 8)
compression = data[24:28]
if compression != b"zstd":
    sys.exit("zboot compression %r is not zstd" % (compression,))
end = offset + size
if offset > len(data) or end > len(data):
    sys.exit("zboot payload is outside the kernel file")
open(dest, "wb").write(data[offset:end])
PY

zstd -d -f -o "${workdir}/Image_resolute_kria" "${workdir}/payload.zst"
if ! file -b "${workdir}/Image_resolute_kria" | grep -q "Linux kernel ARM64 boot executable Image"; then
	die "decompressed payload is not an arm64 Image"
fi

cp "${dtb}" "${workdir}/system.dtb"
cp "${its_src}" "${workdir}/image-cortlab.its"

(
	cd "${workdir}"
	mkimage -A arm64 -O linux -f image-cortlab.its image.ub
)

mv "${workdir}/image.ub" "${partial}"
mv "${partial}" "${out}/image.ub"
partial=
echo "wrote ${out}/image.ub"
