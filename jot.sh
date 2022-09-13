#! /bin/bash

function usage() {
    cat <<USAGE

    Usage: $0 [--params param file]

    Options:
        -p, --params:         parameter to passing to Jot service
USAGE
    exit 1
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

PARAMS=
SCRIPT_PARAMS=()

while [ "$1" != "" ]; do
    case $1 in
    -p | --params)
        shift
        PARAMS=$1
        ;;
    -h | --help)
        usage
        ;;
    *)
        SCRIPT_PARAMS+=($1)
        shift
        SCRIPT_PARAMS+=($1)
        ;;
    esac
    shift
done

if [[ $PARAMS == "" ]]; then
    echo "You must provide a jolie parameter file";
    exit 1;
fi

SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

/usr/bin/env -S jolie --params $PARAMS $DIR/jot.ol ${SCRIPT_PARAMS[@]}