#!/bin/bash

main() {

    if [[ "$1" == "--help" ]];
    then
            help
    fi        

    show_line_numbers=false
    invert_match=false
    multiple_files=false


    #while [[ "$1" == -* ]];
    while getopts "nv" arg; 
    do
                #case "$1" in 
                case "${arg}" in
                     n) show_line_numbers=true ;;
                     v) invert_match=true ;;
                    #-nv|-vn) show_line_numbers=true ; invert_match=true ;;
                    *) echo "Invalid Flag: $1" ;;
                esac
                #shift
    done
    shift $((OPTIND - 1))
    
    pattern=$1

    if [[ -z $pattern || -f $pattern ]]; 
    then
        echo "Error: Missing pattern."
        echo "Use --help for usage information."
        exit 1
    fi
    shift 

    if [[ $# -lt 1 ]];
    then 
        echo "Error: Missing filename."
        echo "Use --help for usage information."
        exit 1
    fi

    if [[ $# -gt 1 ]];
    then
        multiple_files=true
    fi

    for file in "${@}"
    do
        find_match "${pattern}" "${file}"
    done

}


find_match() {

    pattern=$1
    file=$2

    if [[ ! -f "$file" ]]; 
    then
        echo "Error: File '$file' not found."
        return 
    fi  


    number=0
    while IFS= read -r line;
    do
            (( number+=1 ))
            
            if [[ "${line,,}" == *"${pattern,,}"* ]];
            then
                    matches=true
            else
                    matches=false
            fi             


            if $invert_match;
            then
                    matches=$(! $matches && echo true || echo false) 
            fi   
            
            if $matches; 
            then
                if $multiple_files; 
                then
                   if $show_line_numbers;
                   then
                        echo "$file:$number:$line"
                   else
                        echo "$file:$line"
                   fi
                else
                   if $show_line_numbers; then
                        echo "$number:$line"
                   else
                        echo "$line"
                   fi
                fi
            fi

                     
    done < $file

}

help(){
    echo "Usage: ./mygrep [options] pattern filename"
    echo
    echo "Options:"
    echo "  -n    Show line numbers"
    echo "  -v    Invert match (show non-matching lines)"
    echo "  --help Show this help message"
    exit 1
}

main "$@"
