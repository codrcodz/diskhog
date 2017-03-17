# diskhog
A script for finding the files/directories on the server that are hogging disk space.

## Usage

    diskhog -fff|ff|f|s|h megabytes
    
    -fff|--fastest  Only show directories likely to contain large files.
     -ff|--faster   Show search results for commonly large file types.
      -f|--fast     Show 50 largest files in "/" directory.
      -s|--slow     Show 100 largest directories in "/" directory.
      -h|--help     Display is usage message.
        
      megabytes     Whole number of megabytes of minimum file/dir size to find.
