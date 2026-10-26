#!/bin/sh
# Builds the web copy of Mirage into landing/mirage.wasm from Joshua Tree's own sources: the same user/mirage.c and
# user/mirage_core.h the OS runs, and libjt's text drawing. Needs Homebrew LLVM (clang with the wasm32 target, wasm-ld).
set -e
JT=${JT:-../joshuatree}
CC=${CC:-/opt/homebrew/opt/llvm/bin/clang}
"$CC" --target=wasm32 -O2 -ffreestanding -fno-builtin -nostdlib -I"$JT/user" -Wall -Wextra -Werror \
  -Wl,--no-entry -Wl,--strip-all -o landing/mirage.wasm "$JT/user/mirage.c" "$JT/user/libjt/text.c"
echo "landing/mirage.wasm: $(wc -c < landing/mirage.wasm | tr -d ' ') bytes from $JT ($(cat "$JT/VERSION"))"
cp brand/tokens.css landing/tokens.css
cp icon.svg landing/icon.svg
