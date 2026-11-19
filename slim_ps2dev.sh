#!/bin/sh
# Slims the $PS2DEV tree in the "source" stage of Dockerfile and Dockerfile.v1.0.
# Only the slimmed tree is copied into the final image.
#
# Removed (nothing a build needs):
#   1. documentation: share/{man,info,doc} of the toolchains and ports;
#   2. PS2-side programs in ps2sdk/ports/bin (curl, bsdtar, djpeg, ... ~65 MB): MIPS ELFs
#      that cannot run on the host. *-config scripts (sdl-config, libpng16-config, ...)
#      and any host executables stay;
#   3. *-lto-dump (25 MB per toolchain, LTO bytecode viewer) and *-gdb (9 MB);
#   4. debug info (DWARF) of the static PS2 libraries: strip --strip-debug *.a.
#      Archives with LTO objects (.gnu.lto_*: gsKit, most of ps2sdk/ee/lib, libpthread)
#      are skipped: strip without the LTO plugin rebuilds the archive index without
#      their symbols and linking then fails with undefined references.
#      Code, symbols and relocations are untouched: stripped programs built with the
#      slimmed tree are byte-identical (checked on OPL, NHDDL, SMS, an IOP module).
#      Unstripped ELFs just lack DWARF for library code.
# Compilers (cc1, cc1plus, lto1), binutils, headers, IRX modules and crt*.o are kept.
set -e
cd "${PS2DEV:?}"
before=$(du -sk . | cut -f1)

rm -f ee/bin/*-lto-dump iop/bin/*-lto-dump dvp/bin/*-lto-dump \
	ee/bin/*-gdb ee/bin/*-gdb-add-index iop/bin/*-gdb iop/bin/*-gdb-add-index

find . -type d \( -path '*/share/man' -o -path '*/share/info' -o -path '*/share/doc' \
	-o -path ./ps2sdk/ports/man \) -prune -exec rm -rf {} +

# ELF with e_machine = 8 (EM_MIPS), little endian
is_mips_elf() {
	[ "$(head -c 4 "$1" | tr -d '\177')" = ELF ] &&
		[ "$(od -An -tx1 -j18 -N2 "$1" | tr -d ' \n')" = 0800 ]
}
if [ -d ps2sdk/ports/bin ]; then
	for f in ps2sdk/ports/bin/*; do
		[ -f "$f" ] && [ ! -L "$f" ] && is_mips_elf "$f" && rm -f "$f"
	done
	# links to removed programs (bunzip2 -> bzip2, ...)
	find ps2sdk/ports/bin -type l ! -exec test -e {} \; -exec rm -f {} +
fi

# binutils of EE (mips64r5900el-ps2-elf-*, ee-* in v1.0) and IOP
tool() { ls "$1"/bin/*-"$2" | head -n 1; }
n=0 lto=0 skip=0
for a in $(find . -type f -name '*.a'); do
	case "$a" in
	./iop/* | */iop/* | *ports_iop*) t=iop ;;
	*) t=ee ;;
	esac
	if "$(tool $t objdump)" -h "$a" 2>/dev/null | grep -q 'gnu\.lto_'; then
		lto=$((lto + 1))
		continue
	fi
	# a host archive is not recognized by the cross strip and stays as is
	if "$(tool $t strip)" --strip-debug "$a" 2>/dev/null; then n=$((n + 1)); else skip=$((skip + 1)); fi
done

after=$(du -sk . | cut -f1)
echo "slim_ps2dev: $((before / 1024)) MB -> $((after / 1024)) MB;" \
	"stripped $n archives, kept $lto LTO archives, $skip not recognized"
