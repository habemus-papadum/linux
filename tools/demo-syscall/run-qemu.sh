#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd)"
KDIR="${KDIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
BUILD_DIR="${BUILD_DIR:-$SCRIPT_DIR/build}"
KERNEL_IMAGE="${KERNEL_IMAGE:-$KDIR/arch/x86/boot/bzImage}"
INITRAMFS="${INITRAMFS:-$BUILD_DIR/initramfs.cpio.gz}"
MEMORY="${MEMORY:-1024}"
SMP="${SMP:-4}"

if [[ ! -f "$KERNEL_IMAGE" ]]; then
	echo "Kernel image not found at $KERNEL_IMAGE" >&2
	exit 1
fi

if [[ ! -f "$INITRAMFS" ]]; then
	echo "Initramfs not found at $INITRAMFS (build it with make -C tools/demo-syscall)" >&2
	exit 1
fi

QEMU_FLAGS=(
	-kernel "$KERNEL_IMAGE"
	-initrd "$INITRAMFS"
	-append "console=ttyS0 rdinit=/init nokaslr"
	-nographic
	-serial mon:stdio
	-no-reboot
	-nodefaults
	-net none
	-m "$MEMORY"
	-smp "$SMP"
)

if [[ "${KVM:-0}" != 0 ]]; then
	QEMU_FLAGS+=(-enable-kvm -cpu host)
fi

if [[ "${GDB:-0}" != 0 ]]; then
	QEMU_FLAGS+=(-gdb tcp::1234)
	if [[ "${PAUSE:-1}" != 0 ]]; then
		QEMU_FLAGS+=(-S)
	fi
fi

exec qemu-system-x86_64 "${QEMU_FLAGS[@]}" ${EXTRA_QEMU_FLAGS:-}
