#! /bin/bash

# update.sh: ad-hoc gitless lua-nucleo copy updater
# This file is a part of lua-nucleo library
# Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

# TODO: Add error handling. Especially check for path existence.

# TODO: Config handling looks silly.

source "$(dirname $0)"/config.sh

if [ -z "${LUA_NUCLEO_ROOT}" ]; then
  echo "LUA_NUCLEO_ROOT missing" 1>&2
fi

if [ -z "${LUA_NUCLEO_LUA}" ]; then
  echo "LUA_NUCLEO_LUA missing" 1>&2
fi

if [ -z "${DEST_ROOT}" ]; then
  echo "DEST_ROOT missing" 1>&2
fi

if [ -z "${DEST}" ]; then
  echo "DEST missing" 1>&2
fi

if [ -z "${DEST_VERSION_PATH}" ]; then
  echo "DEST_VERSION_PATH missing" 1>&2
fi

GIT="git --git-dir=${LUA_NUCLEO_ROOT}/.git --work-tree=${LUA_NUCLEO_ROOT}"

LUA_NUCLEO_NEW_VERSION="lua-nucleo $(${GIT} describe --always)"
${GIT} update-index -q --refresh
${GIT} diff-index --exit-code --quiet HEAD ||
  LUA_NUCLEO_NEW_VERSION="${LUA_NUCLEO_NEW_VERSION}-dirty"

LUA_NUCLEO_OLD_VERSION=$(cat "${DEST_VERSION_PATH}" || echo "(unknown)")

echo "Updating from ${LUA_NUCLEO_OLD_VERSION} to ${LUA_NUCLEO_NEW_VERSION}"

CMD="rsync -auv --delete ${LUA_NUCLEO_LUA}/ ${DEST}/"

echo "About to run"
echo "    ${CMD}"
read -p "Are you sure? [y/N] "
if [ "${REPLY}" != "y" ]; then
  echo "Cancelled"
  exit 1
fi

# TODO: Add error-handling!

${CMD}

echo "Updating VERSION file"
echo ${LUA_NUCLEO_NEW_VERSION} >${DEST_VERSION_PATH}
