# MyGrep - Custom Grep Command in Bash

A custom Bash script that mimics the basic functionality of the `grep` command, allowing you to search for patterns in files with options to show line numbers, invert matches, and handle multiple files.

## Features

- **Search for a pattern**: Search for a string (case-insensitive) in one or multiple text files.
- **Command-Line Options**:
  - `-n`: Show line numbers for each match.
  - `-v`: Invert the match (print lines that do not match).
  - `--help`: Display the help message with usage information.
- **Multiple files support**: You can search through multiple files and see the matching lines from each file.
- **Error Handling**: The script gracefully handles errors like missing files and missing patterns.

## Requirements

- **Bash version 4.0 or higher**  
  This script uses features like `${variable,,}` (lowercasing), which require Bash 4.0+.

## Installation

1. Clone the repository or download the script to your local machine.

2. Make sure the script is executable:

   ```bash
   chmod +x mygrep.sh
   ```

3. You can now run the script using:
   ```bash
   ./mygrep.sh [options] pattern filename
   ```

## Usage

### Basic Syntax

```bash
./mygrep.sh [options] pattern filename
```

`pattern`: The pattern or string to search for.

`filename`: The file or files in which to search for the pattern.

Options
`-n`: Display line numbers along with matching lines.

`-v`: Invert the match (show lines that do not match the pattern).

`--help`: Show help message with usage instructions.

### Examples

1- Search for a pattern in a file:

`./mygrep.sh "pattern" file.txt`

This will display the lines in `file.txt` that contain the pattern "pattern".

2- Search for a pattern with line numbers:

`./mygrep.sh -n "pattern" file.txt`

This will display matching lines along with their line numbers in `file.txt`.

3- Search for a pattern in multiple files:

`./mygrep.sh "pattern" file1.txt file2.txt`

This will display the matching lines from both file1.txt and file2.txt.

4- Invert the match (show non-matching lines):

`./mygrep.sh -v "pattern" file.txt`

This will show all lines in file.txt that do not contain the pattern "pattern".

5- Show non-matching lines with line numbers:

`./mygrep.sh -n -v "pattern" file.txt`

or

`./mygrep.sh -nv "pattern" file.txt`

or

`./mygrep.sh -vn "pattern" file.txt`

This will show non-matching lines along with their line numbers.

6- Display help:

`./mygrep.sh --help`

## Breakdown of How the Script Handles Arguments and Options

The script processes arguments and options using getopts, which is a built-in command in Bash for parsing short options (single character options). Here's a breakdown of how the script handles the input:

1- Help Flag (--help):

if the user runs the script with `--help`, the script will display the usage information and exit. It’s the first check in the `main` function:

```
if [[ "$1" == "--help" ]];
then
       help
fi
```

2- Option Parsing:

The script uses the getopts command to handle options. This allows for easy addition of flags like -n (show line numbers) and -v (invert match).

```
while getopts "nv" arg; do
    case "${arg}" in
        n) show_line_numbers=true ;;
        v) invert_match=true ;;
        *) echo "Invalid Flag: -$OPTARG"; help ;;
    esac
done
```

`getopts "nv"` tells the script to accept the flags `-n` and `-v`. If the user provides any other flag, it will trigger the `*` case and show an error.

3- Handling Pattern and File Arguments:

After processing the options, the script expects the first non-option argument to be the search pattern and the subsequent arguments to be the file names.

```
pattern=$1
if [[ -z $pattern || -f $pattern ]]; then
    echo "Error: Missing pattern."
    exit 1
fi
```

If no pattern is provided, or the pattern is actually a file (due to argument order), an error will be printed.

4- Multiple Files:

If more than one file is passed as arguments, the script will process each file one by one and output the results. If only one file is provided, it processes that file.

```
for file in "${@}"; do
    find_match "${pattern}" "${file}"
done
```

## A short paragraph: If you were to support regex or -i/-c/-l options, how would your structure change?

1.  Regex Support:
    I would use
    Bash's built-in regex matching with `[[ "$line" =~ $pattern ]] instead of simple string matching with `[["$line" == *"$pattern"*]]`
2.  Case-Insensitive Search (`-i`)

```
    case_insensitive=true #new variable
    #while [[ "$1" == -* ]];
    while getopts "nvi" arg; #add i option
    do
                #case "$1" in
                case "${arg}" in
                     n) show_line_numbers=true ;;
                     v) invert_match=true ;;
                    #-nv|-vn) show_line_numbers=true ; invert_match=true ;;
                     i) case_insensitive=true ;; #handle i option
                     *) echo "Invalid Flag: $1" ;;
                esac
                #shift
    done
```

in `find_match()` function, never converting line and pattern to lowercase unless
`case_insensitive` is true `"${line,,}"` and `*"${pattern,,}"*`

3. Count Matches (`-c`)
   add variable by default is `false`, handle it in `while getopts "nvic" arg;`

   in `find_match()`, check the value of the new variable and instead of printing each matching line, the script would count how many lines match the pattern and output the count after processing the file(s).

4. List Filenames Only (`-l`)
   the script would only output the names of the files that contain at least one matching line, without displaying the matched lines themselves.
   just `echo $file` instead, if matched

## What Part of the Script Was Hardest to Implement and Why?

Overall, the implementation process was moderately smooth. I did not feel that a specific part of the script was particularly hard to implement. Each feature — from option parsing to handling multiple files — had its own small challenges, but none of them stood out as exceptionally difficult.
