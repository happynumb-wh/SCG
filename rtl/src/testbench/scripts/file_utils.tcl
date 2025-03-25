## This procedure checks whether or not a file exists and is readable.
# \param fileName Path and name of file to be checked.
# \return 0 if either the file does not exist or is not readable, 1 otherwise
proc CheckExistsReadable {fileName} {
    set thisScript [info script]
    set returnValue 0

    if {![file exists $fileName]} {
        puts "$thisScript.CheckExistsReadable: ERROR: $fileName does not exist"
    } elseif {![file readable $fileName]} {
        puts "$thisScript.CheckExistsReadable: ERROR: $fileName is not readable"
    } else {
        set returnValue 1
    }
    return $returnValue 
}

## This procedure checks for the existence of a directory. If it doesn't,
# then it will be created.
# \param dir The path of the directory to be checked
proc CheckDirExistsIfNotCreate {dir} {
    if {![file exists $dir]} {
        puts "[info script].CheckDirExistsIfNotCreate: creating $dir"
        file mkdir $dir
    }
}

## This procedure checks that a file exists and copies it to a target directory.
# \param fileName File to be copied, after it is verified it exists and is readable
# \param targetDir direcotry to copy the file to. It is assumed this directory exists.
proc CopyFile {fileName targetDir} {
    if {[CheckExistsReadable $fileName]} {
        puts "[info script].CopyFile: copying $fileName to $targetDir"
        file copy -force $fileName $targetDir
    }
}

## This procedure opens a file, puts its contents in a list and then closes the file. Note
# that each element of the list is a line in the file.
# \param fileName File to be opened.
# \return contents A list where each element is a line form the file.
proc GetLines {fileName} {
    CheckExistsReadable $fileName
    if {[file isfile $fileName]} {
        set fileId [open $fileName r]
        set contents [split [read $fileId] \n]
        close $fileId
    } else {
        puts "[info script].GetLines: ERROR: $fileName is not a file"
    }
    return $contents
}

## This procedure searches for an element in a list, then replaces it with one or more elements.
# \param inputList The list to be searched and modified
# \param wheresWaldo The lsit element we wish to replace
# \param newElements List of one or more elements we wish to substitute for wheresWaldo
# \param replaceOccurranceNb This parameter tells us whether to replace the first occurance, second, etc. Optional. First occurance is default.
# \return modifiedList
proc ReplaceLine {inputList wheresWaldo newElements {replaceOccuranceNb -1} {verbose 0}} {
    set printWarning 0
    if {$replaceOccuranceNb < 0} {
        set printWarning 1
        set replaceOccuranceNb 1
    }
    set newStuff [join $newElements \n]
    set index [lsearch -all -glob $inputList $wheresWaldo]
    set modifiedList $inputList
    if {[llength $index] > 1} {
        if {$printWarning > 0} {
            puts "[info script].ReplaceLine: WARNING: $wheresWaldo found more than once at row numbers $index. Replacing the first occurance."
        }
        if {$replaceOccuranceNb > [llength $index]} {
            puts "[info script].ReplaceLine: ERROR: cannot replace occurrance nb $replaceOccuranceNb since we have [llength $index] occurance(s)"
        } else {
            # The first element into a list has index 0
            set index [lindex $index [expr $replaceOccuranceNb - 1]]
        }
    } elseif {$index < 0} {
        puts "[info script].ReplaceLine: ERROR: could not find $wheresWaldo"
    } else {
        if {$verbose} {
            puts "[info script].ReplaceLine: Found:\n$wheresWaldo \n at element number $index"
            puts "replacing \n$wheresWaldo\n by \n$newStuff"
        }
    }
    set modifiedList [lreplace $inputList $index $index $newStuff]
    return $modifiedList
}

## This procedure opens a file for writing, writes a list to the file and then clsoes the file.
# \param fileName Name of the file to write to.
# \param stuffToWrite List of elements to write to fileName. Each element of stuffToWrite will
#        correspond to one line of fileName.
proc WriteListToFile {fileName stuffToWrite} {
    set fileId [open $fileName w]
    foreach line $stuffToWrite {
        puts $fileId $line
    }
    close $fileId
}

