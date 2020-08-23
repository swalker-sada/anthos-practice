title_no_wait () {
    echo "${bold}# ${@}${normal}"
}

title_and_wait () {
    export CYAN='\033[1;36m'
    export YELLOW="\e[38;5;226m"
    export NC='\e[0m'
    echo "${bold}# ${@}"
    echo -e "${YELLOW}--> Press ENTER to continue...${NC}"
    read -p ''
}

print_and_execute () {

    SPEED=210
    GREEN='\e[1;32m' # green
    NC='\e[0m'

    printf "${GREEN}\$ ${@}${NC}" | pv -qL $SPEED;
    printf "\n"
    eval "$@" ;
}

nopv_and_execute () {

    SPEED=210
    GREEN='\e[1;32m' # green
    NC='\e[0m'

    printf "${GREEN}\$ ${@}${NC}";
    printf "\n"
    eval "$@" ;
}

error_no_wait () {
    RED='\e[1;91m' # red
    NC='\e[0m'
    printf "${RED}# ${@}${NC}"
    printf "\n"
}

export -f print_and_execute
export -f title_no_wait
export -f title_and_wait
export -f nopv_and_execute
export -f error_no_wait
