#! /bin/sh

FILESYSTEM_ROOT=$1
ASSETS_PREFIX="../assets/" # TODO: Make configurable

if [ -z "$FILESYSTEM_ROOT" ]; then
  echo "Usage: $0 filesystem_root < in_file > out_file" 1>&2
  exit
fi

# Ensure path has a single trailing slash
FILESYSTEM_ROOT_NOSLASH=$(echo $FILESYSTEM_ROOT | sed -e 's/\/*$//')
FILESYSTEM_ROOT=${FILESYSTEM_ROOT_NOSLASH}/

if [ ! -d "$FILESYSTEM_ROOT" ]; then
  echo "Filesystem root must be a directory `$FILESYSTEM_ROOT`" 1>&2
  exit
fi

nl='${NL}'
indent='${INDENT}'
indent1='${INDENT1}'

# Collect info on embedded assets

DECLARE_FILES=""
REGISTER_FILES="const libInitializer:CLibInit = new CLibInit();${nl}"

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

# Escape replacement data for sed

FILESYSTEM_ROOT=$(echo $FILESYSTEM_ROOT | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
DECLARE_FILES=$(echo $DECLARE_FILES | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
REGISTER_FILES=$(echo $REGISTER_FILES | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')

# TODO: Escape $FILESYSTEM_ROOT?
sed \
 -e "s/\\\${FILESYSTEM_ROOT}/\"file\\:\\/\\/$FILESYSTEM_ROOT\"/g" \
 -e "s/\\\${DECLARE_FILES}/$DECLARE_FILES/g" \
 -e "s/\\\${REGISTER_FILES}/$REGISTER_FILES/g" | \
 awk '{gsub("\\${NL}", "\n");gsub("\\${INDENT}", "    ");gsub("\\${INDENT1}", "      ");print}'
