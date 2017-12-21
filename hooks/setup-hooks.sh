#!/bin/bash
if [[ ! -d "${1}" ]] ; then
    echo "Directory ${1} doesn't exist!"
    exit 1
fi

GITHOOKDIR="${1}/.git/hooks"
PRECOMMIT="${GITHOOKDIR}/pre-commit"
MAKERHOOKDIR="$(dirname $(readlink -f ${0}))"

if [[ ! -f "${PRECOMMIT}" ]] ; then
    touch ${PRECOMMIT}
    chmod +x ${PRECOMMIT}
fi

for h in ${MAKERHOOKDIR}/pre-commit*; do
    grep "${h}" "${PRECOMMIT}" || echo "${h} || exit 1" >> "${PRECOMMIT}"
done
