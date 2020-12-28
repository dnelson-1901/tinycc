#! /bin/sh

TCC="$1"

rv="OK"

# test commandline argument parsing
check() {
  result=$($TCC -Wunsupported $1 2>&1 | head -n 1)
  if [ "$2" != "$result" ] ; then
    printf "Test mismatch on %s\n-%s\n+%s\n" "$1" "$2" "$result"
    rv="FAIL"
  fi
}

# we take advantage of unsupported options to force tcc to print out the
# string that it just parsed so we can compare it

check "-Wl,-O" "tcc: error: argument to '-O' is missing"
check "-Wl,--fini" "tcc: error: argument to '--fini' is missing"
check "-Wl,-O2" "tcc: warning: unsupported linker option '-O2'"
check "-Wl,-O,2" "tcc: warning: unsupported linker option '-O,2'"
check "-Wl,--fini=2" "tcc: warning: unsupported linker option '--fini=2'"
check "-Wl,--fini,2" "tcc: warning: unsupported linker option '--fini,2'"

echo "$rv"
if [ "$rv" != "OK" ] ; then
  return 1
fi
