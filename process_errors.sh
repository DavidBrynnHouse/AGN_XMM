#!/bin/zsh
cd ..
# File containing the output to process
logfile="nohup.out"

# Loop through the lines of the file
awk '
/Processing folder:/ {
    if ($3 !~ /%+/) {  # Check if folder name is not just %%%%%%%%%%%%%%%%
        folder=$3;      # Capture the folder name
    }
}
/error/ {  # Only count lines containing the word "error"
    if (folder) {       # Ensure we have a valid folder name
        errors[folder]++;  # Increment error count for the folder
    }
}
END {
    print "Folders with errors:"
    for (f in errors) {
        print f
    }
}' $logfile

