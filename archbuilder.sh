#!/bin/bash
#############
#
# archbuilder
#
#############

# verbose mode - default: quiet
VERBOSE="/dev/null"

# colors
WHITE="$(tput bold ; tput setaf 7)"
GREEN="$(tput setaf 2)"
RED="$(tput bold; tput setaf 1)"
YELLOW="$(tput bold ; tput setaf 3)"
NC="$(tput sgr0)" # No Color

FAILURE="1"
SUCCESS="0"


wprintf() {
    msg=${1}
    shift
    printf "%s${msg}%s\n" "${WHITE}" "$@" "${NC}"

    return "${SUCCESS}"
}

# print warning
warn()
{
    msg=${1}
    shift
    printf "%s[!] WARNING: ${msg}%s\n" "${YELLOW}" "${@}" "${NC}"

    return "${SUCCESS}"
}

# print error and exit
err()
{
    msg=${1}
    shift
    printf "%s[-] ERROR: ${msg}%s\n" "${RED}" "${@}" "${NC}"

    return "${FAILURE}"
}

# print error and exit
crit()
{
    msg=${1}
    shift
    printf "%s[-] CRITICAL: ${msg}%s\n" "${RED}" "${@}" "${NC}"

    exit "${FAILURE}"
}

# usage and help
usage()
{
cat <<EOF
Usage: archbuilder <operation> [options]

Operations:
	-i - Install custom distribution to disk
	-b - Build custom distribution
	-u - Update existing installation

Options
	-v - Verbose Output
        -V - Display version information
	-h - Display this message
	-I - Interactive mode
	-s - Build from source
	-o - Offline mode (Requires source/bin packages)
	-c <file> - Use config file

Install Specific Options
	-l 	   Install a copy of the local environment

Build Options
	
Update Options
       
EOF
    return "${SUCCESS}"
}

# parse command line options
get_opts()
{
    while getopts :IBUVhiso:cl flags
    do
        case "${flags}" in
	    I)
		[ ! -z $OPERATION ] && crit "Muliple operations selected"
		OPERATION="install"
		;;
	    B)
		[ ! -z $OPERATION ] && crit "Muliple operations selected"
		OPERATION="build"
		;;
	    U)
		[ ! -z $OPERATION ] && crit "Muliple operations selected"
		OPERATION="update"
		;;
            c)
		CONF=$OPTARG
		;;
	    i)
		INTERACTIVE="true"
		;;
	    s)
		SOURCE="true"
		;;
	    o)
		OFFLINE="true"
		;;
	    l)
		LOCAL="true"
		;;
            V)
                printf "%s\n" "${VERSION}"
                exit "${SUCCESS}"
                ;;
            h)
                usage
                ;;
            *)
	        usage
                ;;
        esac
    done
}

validate_opts()
{
    if ! [ -z $OPERATION ]; then
	case "${OPERATION}" in
	    "install")
		[ ! -z $CONF ] && INTERACTIVE="true"
		;;
	    "build")
		;;
	    "update")
		;;
	esac
    else
        usage
	exit "${FAILURE}"
    fi
    return "${SUCCESS}"
}

check_env()
{
    #Make sure build-dev is installed?
    #
}
main()	
{	
	get_opts ${*}
	validate_opts
	check_env
}
main ${*}
