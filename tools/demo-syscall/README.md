# Demo syscall + QEMU workflow

Steps below use the new `demo_strlen` syscall as an example and assume the tree root is `<kernel>`.

1) Build the kernel with half the CPUs (on this box that is `-j96`):
   - `cd <kernel>`
   - `make -j$(($(nproc)/2)) bzImage`

2) Build headers, the static init binary, and an initramfs with the new syscall number:
   - `make -C tools/demo-syscall`
   - Artifacts land in `tools/demo-syscall/build/` (headers, `init`, `initramfs.cpio.gz`).
   - Set `KBUILD_OUTPUT=<out>` if you build the kernel out-of-tree.

3) Run the kernel under QEMU (serial console only):
   - `tools/demo-syscall/run-qemu.sh`
   - Optional env vars: `GDB=1` to open a GDB stub on tcp::1234, `PAUSE=1` to start paused, `KVM=1` to enable KVM if available, `SMP=<n>` to change vCPUs.

4) Hit the syscall from GDB:
   - In another terminal: `gdb -x tools/demo-syscall/demo.gdb`
   - The init process loops once per second calling `demo_strlen`, so the breakpoint prints a line per hit and continues.

Debug info (for repeatable GDB setup)
- This tree’s `.config` was not modified; no debug info was enabled by default.
- To build with DWARF symbols in a fresh checkout: run `./scripts/config --enable CONFIG_DEBUG_INFO` (optionally also `CONFIG_DEBUG_INFO_DWARF4`/`CONFIG_DEBUG_INFO_DWARF5` and `CONFIG_GDB_SCRIPTS`), then rebuild with `make -j$(($(nproc)/2)) bzImage`.
