#!/bin/bash
#############
#
# archbuilder
#
#############

# verbose mode - default: quiet
VERBOSE="/dev/null"

INTERACTIVE="false"
# colors
WHITE="$(tput bold ; tput setaf 7)"
GREEN="$(tput setaf 2)"
RED="$(tput bold; tput setaf 1)"
YELLOW="$(tput bold ; tput setaf 3)"
NC="$(tput sgr0)" # No Color

FAILURE="1"
SUCCESS="0"


info() {
    msg=${1}
    shift
    printf "%s${msg}%s\n" "${YELLOW}" "$@" "${NC}"

    return "${SUCCESS}"
}

# print warning
warn()
{
    msg=${1}
    shift
    printf "%s[!] WARNING: ${msg}%s\n" "${RED}" "${@}" "${NC}"

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
	-I - Install custom distribution to disk
	-B - Build custom distribution
	-U - Update existing installation

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
    while getopts :IBUVhisoc:l flags
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
                exit "${SUCCESS}"
                ;;
            *)
	        usage
                exit "${FAILURE}"
                ;;
        esac
    done
}

validate_opts()
{
    if ! [ -z $OPERATION ]; then
	case "${OPERATION}" in
	    "install")
		[ -z $CONF ] && INTERACTIVE="true"
		;;
	    "build")
		;;
	    "update")
		;;
	esac
    else
        INTERACTIVE="true"
    fi
    return "${SUCCESS}"
}

check_env()
{
    #Make sure build-dev is installed?
    return "${SUCCESS}"
}

load_conf()
{
    if [ ! -z $CONF ]; then
	if [ -f $CONF ]; then
	    source $CONF
	else
	    crit "Error loading configuration"
	fi
    fi
    return "${SUCCESS}"
}

set_keymaps()
{
    printf "%s" "${WHITE}"
    info "[+] Setting keymap..."
    locale-gen &> /dev/null

    if [ ${INTERACTIVE} == "true" -o -z $KEYMAP ]; then
	[ "${KEYMAP}" == "" ] && KEYMAP="us" 
	while true; do
            printf "    1. Set keymaps.\n"
            printf "    2. See available keymaps.\n"
            printf "Select: "; read keymaps_opt
            [ "${keymaps_opt}" == "1" ] && break
            if [ "${keymaps_opt}" == "2" ]; then
		printf "%s" "${NC}"
		localectl list-keymaps
		clear
		printf "%s" "${WHITE}"
            fi
	done

	printf " -> Set keymaps [$KEYMAP]: "
	read keymaps
	
	[ "${keymaps}" != "" ] && KEYMAP="${keymaps}"
    fi

    localectl set-keymap --no-convert "${KEYMAP}"
    loadkeys "${KEYMAP}"

    printf "%s" "${NC}"

    return "${SUCCESS}"
}

ask_for_luks()
{
#Check if luks modules are available
return "${SUCCESS}"
}

setup_filesystem()
{
return "${SUCCESS}"
}

format_partitions()
{
return "${SUCCESS}"
}
setup_disks()
{
info "[+] Hard drive configuration..."
ask_for_luks
setup_filesystem
format_partitions
return "${SUCCESS}"
}

mount_disks()
{
info "[+] Mounting filesystem..."
return "${SUCCESS}"
}

main()	
{	
	get_opts ${*}
	validate_opts
	check_env
	load_conf
	case "${OPERATION}" in
	    "install")
		set_keymaps
		setup_disks
		mount_disks
		;;
	    "build")
		;;
	    "update")
		;;
	esac
	
}
main ${*}
