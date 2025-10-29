#!/bin/bash

dup_dir=dup_data
no_dup_dir=no_dup_data

mkdir -p "$dup_dir"
mkdir -p "$dup_dir"/nested
rm "$dup_dir"/*

dd if=/dev/zero of="$dup_dir"/AAA_001  bs=1052  count=1
dd if=/dev/zero of="$dup_dir"/AAA_002  bs=1052  count=1
dd if=/dev/zero of="$dup_dir"/AAA_003  bs=1052  count=1

dd if=/dev/zero of="$dup_dir"/BBB_001  bs=2052  count=1
dd if=/dev/zero of="$dup_dir"/BBB_002  bs=2052  count=1
dd if=/dev/zero of="$dup_dir"/BBB_003  bs=2052  count=1

echo "aaaa" > "$dup_dir"/CCC
echo "bbbb" > "$dup_dir"/DDD
echo "cccc" > "$dup_dir"/EEE

echo "ala ma kota" > "$dup_dir"/FFF


dd if=/dev/zero of="$dup_dir"/nested/AAA_004  bs=1052  count=1
dd if=/dev/zero of="$dup_dir"/nested/AAA_005  bs=1052  count=1
dd if=/dev/zero of="$dup_dir"/nested/AAA_006  bs=1052  count=1

dd if=/dev/zero of="$dup_dir"/nested/GGG_001  bs=1000  count=1
dd if=/dev/zero of="$dup_dir"/nested/GGG_002  bs=1000  count=1
dd if=/dev/zero of="$dup_dir"/nested/GGG_003  bs=1000  count=1

mkdir -p "$no_dup_dir"
mkdir -p "$no_dup_dir"/nested

echo "abc" > "$no_dup_dir"/abc
echo "def" > "$no_dup_dir"/nested/def
echo "ghi" > "$no_dup_dir"/nested/ghi

