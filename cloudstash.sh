#!/bin/bash
# Show colored output if running interactively
if [ -t 1 ] ; then
    export ANSIBLE_FORCE_COLOR=true
fi
# Log everything from this script into _cloudstash.log
echo "$0 $@" > _cloudstash.log
exec &> >(tee -i -a _cloudstash.log )

# With LANG set to everything else than C completely undercipherable errors
# like "file not found" and decoding errors will start to appear during scripts
# or even ansible modules
LANG=C

: ${OPT_INSTALL:=""}
: ${OPT_BACKUP:=""}
: ${OPT_RESCUE:""}
: ${OPT_TAGS:=""}
: ${OPT_SKIP_TAGS:=""}
: ${OPT_LIST_TASKS_ONLY=""}

print_logo () {

if [ `TERM=${TERM:-vt100} tput cols` -lt 105 ]; then

cat <<EOBANNER
-----------------------------------------------------------
|    ________                _______ __             __    |
|   / ____/ /___  __  ______/ / ___// /_____ ______/ /_   |
|  / /   / / __ \/ / / / __  /\__ \/ __/ __ `/ ___/ __ \  |
| / /___/ / /_/ / /_/ / /_/ /___/ / /_/ /_/ (__  ) / / /  |
| \____/_/\____/\__,_/\__,_//____/\__/\__,_/____/_/ /_/   |
|                                                         |
-----------------------------------------------------------


EOBANNER

else

cat <<EOBANNER
-----------------------------------------------------------------------------------
|     ______    __                      __   _____   __                     __    |
|    / ____/   / /  ____   __  __  ____/ /  / ___/  / /_  ____ _   _____   / /_   |
|   / /       / /  / __ \ / / / / / __  /   \__ \  / __/ / __ `/  / ___/  / __ \  |
|  / /___    / /  / /_/ // /_/ / / /_/ /   ___/ / / /_  / /_/ /  (__  )  / / / /  |
|  \____/   /_/   \____/ \__,_/  \__,_/   /____/  \__/  \__,_/  /____/  /_/ /_/   |
|                                                                                 |
-----------------------------------------------------------------------------------


EOBANNER

fi
}

# Install all required packages on configured nodes.
install () {

}

# Perform initial backup on listed inventory
backup () {

}

# Create a rescue image which can be used to restore server
rescue () {

}

# Deploy configured storage option.
configure_storage () {


}


usage () {
    echo "Usage: $0 --install"
    echo "                      install cloudstash packages dependencies and exit"
    echo ""
    echo "Basic options:"
    echo "  -b, --backup        execute the backup operation on nodes which are provided on the"
    echo "                      command line which -N flag or configured in the inventory file."
    echo ""
    echo "  -r, --rescue        execute a system backup and create a rescue image."
    echo ""
    echo "  -N, --nodes <fqdn>"
    echo "                      specify the hostname or IP of nodes that should configured."
    echo ""
    echo "  -e, --extra-vars <key>=<value>"
    echo "                      additional ansible variables, can be used multiple times"
    echo ""
    echo "Advanced options:"
    echo "  -v, --ansible-debug"
    echo "                      invoke ansible-playbook with -vvvv"
    echo "  -y, --dry-run"
    echo "                      dry run of playbook, invoke ansible with --list-tasks"
    echo "  -t, --tags <tag1>[,<tag2>,...]"
    echo "                      only run plays and tasks tagged with these values,"
    echo "                      specify 'all' to run everything"
    echo "                      (default=$OPT_TAGS)"
    echo "  -S, --skip-tags <tag1>[,<tag2>,...]"
    echo "                      only run plays and tasks whose tags do"
    echo "                      not match these values"
    echo "  -l, --print-logo    print the TripleO logo and exit"
    echo "  -h, --help          print this help and exit"

}

OPT_VARS=()
OPT_ENVIRONMENT=()

while [ "x$1" != "x" ]; do
    case "$1" in
        --install|-i)
            OPT_INSTALL=1
            ;;

        --backup|-b)
            OPT_SYSTEM_PACKAGES=1
            ;;

        --ansible-debug|-v)
            OPT_DEBUG_ANSIBLE=1
            ;;

        --tags|-t)
            OPT_TAGS=$2
            shift
            ;;

        --skip-tags|-S)
            OPT_SKIP_TAGS=$2
            shift
            ;;

        --nodes|-N)
            OPT_NODES=$2
            shift
            ;;

        --playbook|-p)
            OPT_PLAYBOOK=$2
            shift
            ;;

        --extra-vars|-e)
            OPT_VARS+=("-e")
            OPT_VARS+=("$2")
            shift
            ;;

        --help|-h)
            usage
            exit
            ;;

        # developer options
        --dry-run|-y)
            OPT_LIST_TASKS_ONLY=" --list-tasks"
            ;;

        --print-logo|-l)
            PRINT_LOGO=1
            ;;

        --) shift
            break
            ;;

        -*) echo "ERROR: unknown option: $1" >&2
            usage >&2
            exit 2
            ;;

        *)    break
            ;;
    esac

    shift
done


if [ "$PRINT_LOGO" = 1 ]; then
    print_logo
    echo "..."
    echo "Nothing more to do"
    exit
fi


if [ "$OPT_INSTALL" = 1 ]; then
    echo "NOTICE: installing packages" >&2
    install
    exit $?
fi



print_logo

set -ex

if [ "$OPT_DEBUG_ANSIBLE" = 1 ]; then
    VERBOSITY=vvvv
else
    VERBOSITY=vv
fi

ansible-playbook -$VERBOSITY $OPT_PLAYBOOK \
    -e @$OPT_NODES \
    ${OPT_LIST_TASKS_ONLY} \
    ${OPT_TAGS:+-t $OPT_TAGS} \
    ${OPT_SKIP_TAGS:+--skip-tags $OPT_SKIP_TAGS}