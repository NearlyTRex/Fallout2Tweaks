#!/bin/bash

set -xeu -o pipefail

extra_dir="${extra_dir:-extra}"
extra_dir="$(realpath $extra_dir)"
bin_dir="$extra_dir/bin"
compile="$bin_dir/compile.exe"
dst="data/scripts"
mkdir -p "$dst"
dst="$(realpath $dst)"
headers_dir="../source/headers"
external_dir="../../external"
if ! $extra_dir/need-build.sh ; then
  echo "scripts haven't changed, skipping build"
  exit 0
fi

mkdir -p external
cd external
if [[ -d rp ]]; then
  cd rp
  git pull
  cd ..
else
  git clone https://github.com/BGforgeNet/Fallout2_Restoration_Project.git rp
fi
rm -f "$headers_dir/rp"
ln -sf "$external_dir/rp/scripts_src/HEADERS" "$headers_dir/rp"

if [[ -d party_orders ]]; then
  cd party_orders
  git pull
  cd ..
else
  git clone https://github.com/BGforgeNet/fallout2-party-orders.git party_orders
fi
rm -f  "$headers_dir/party_orders"
ln -sf "$external_dir/party_orders/source/headers/party_orders" "$headers_dir/party_orders"

if [[ -d sfall ]]; then
  cd sfall
  git pull
  cd ..
else
  git clone https://github.com/phobos2077/sfall.git sfall
fi
rm -f  "$headers_dir/sfall"
ln -sf "$external_dir/sfall/artifacts/scripting/headers" "$headers_dir/sfall"

cd ..

files=$(cat $extra_dir/build.list)
mkdir -p $dst
cd source
for f in $files; do
  int_name="$(echo $f | tr "[A-Z]" "[a-z]" | sed 's|\.ssl$|.int|')"
  wine $compile -l -O2 -p -s -q -n "$f" -o "$dst/$int_name"
done
