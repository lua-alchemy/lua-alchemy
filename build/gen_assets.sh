#! /bin/bash

# TODO: Bake in precompiled byte-code instead of sources!
#       (But do that in the build script, not here)

FILESYSTEM_ROOT=$1
ASSETS_CLASS_NAME=$2
ASSETS_PREFIX=$3
PACKAGE_NAME=$4

if [ -z "$FILESYSTEM_ROOT" -o -z "$ASSETS_CLASS_NAME" -o -z "$ASSETS_PREFIX" ]; then
  echo "Usage: $0 filesystem_root assets_class_name assets_prefix [package_name] < in_file > out_file" 1>&2
  exit 1
fi

# NOTE: Package name may be empty

# Ensure paths have a single trailing slash
FILESYSTEM_ROOT_NOSLASH=$(echo $FILESYSTEM_ROOT | sed -e 's/\/*$//')
FILESYSTEM_ROOT=${FILESYSTEM_ROOT_NOSLASH}/
ASSETS_PREFIX=$(echo $ASSETS_PREFIX | sed -e 's/\/*$//')/

if [ ! -d "$FILESYSTEM_ROOT" ]; then
  echo "Filesystem root must be a directory `$FILESYSTEM_ROOT`" 1>&2
  exit 1
fi

nl='${NL}'
indent='${INDENT}'
indent1='${INDENT1}'

# Collect info on embedded assets

DECLARE_FILES=""
REGISTER_FILES=""

i=0
for filename in $(find $FILESYSTEM_ROOT_NOSLASH -print); do
  if [ -f $filename ]; then
    short_filename=${filename#${FILESYSTEM_ROOT}}

    DECLARE_FILES="${DECLARE_FILES}${nl}\
${indent}[Embed(source=\"${ASSETS_PREFIX}${short_filename}\", mimeType=\"application/octet-stream\")]${nl}\
${indent}private static var _asset${i}:Class;${nl}"

    REGISTER_FILES="${REGISTER_FILES}${nl}\
${indent1}libInitializer.supplyFile(\"builtin://${short_filename}\", new _asset${i}() as ByteArray);"

    i=$(expr $i + 1)
  fi
done

FILESYSTEM_ROOT="\"file\\:\\/\\/${FILESYSTEM_ROOT}\""

# Escape replacement data for sed

FILESYSTEM_ROOT=$(echo $FILESYSTEM_ROOT | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
PACKAGE_NAME=$(echo $PACKAGE_NAME | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
ASSETS_CLASS_NAME=$(echo $ASSETS_CLASS_NAME | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
DECLARE_FILES=$(echo $DECLARE_FILES | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
REGISTER_FILES=$(echo $REGISTER_FILES | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')

# TODO: Escape $FILESYSTEM_ROOT?
sed \
 -e "s/\\\${FILESYSTEM_ROOT}/$FILESYSTEM_ROOT/g" \
 -e "s/\\\${PACKAGE_NAME}/$PACKAGE_NAME/g" \
 -e "s/\\\${ASSETS_CLASS_NAME}/$ASSETS_CLASS_NAME/g" \
 -e "s/\\\${DECLARE_FILES}/$DECLARE_FILES/g" \
 -e "s/\\\${REGISTER_FILES}/$REGISTER_FILES/g" | \
 awk '{gsub("\\${NL}", "\n");gsub("\\${INDENT}", "    ");gsub("\\${INDENT1}", "      ");print}'
