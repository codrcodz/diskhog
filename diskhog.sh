#!/usr/bin/env bash

##########

subcommand=${1};
min_file_size=${2};
declare -a search_dirs_array;

##########

usage() {
  echo "  Diskhog finds large files and/or directories on a server."
  echo ""
  echo "  Usage: diskhog -fff|ff|f|s|h megabytes"
  echo ""
  echo "    -fff|--fastest  Only show directories likely to contain large files."
  echo "     -ff|--faster   Show search results for commonly large file types."
  echo "      -f|--fast     Show 50 largest files in \"/\" directory."
  echo "      -s|--slow     Show 100 largest directories in \"/\" directory."
  echo "      -h|--help     Display is usage message."
  echo ""
  echo "      megabytes     Whole number of megabytes of minimum file/dir size to find."
  echo ""
}

fastest() {
  update_locatedb;
  printf "MB\tDirectories Most Likey to Contain Large and/or Numerous Files\n";
  prefilter_with_locate;
  filter_by_dir_size;
  printf "End of List\n";
}

faster() {
  update_locatedb;
  prefilter_with_locate;
  for _dir in ${search_dirs_array[@]}; do
    printf "Total regular files in ${_dir} (not recursive)\n";
    count_files_in_dir ${_dir};
    printf "MB\tSelect Large Files in ${_dir} (>=${min_file_size}MB)\n";
    filter_by_file_size ${_dir};
  done
  printf "End of List\n";
}

fast() {
  printf "MB\t50 Largest Files in "/" (>=${min_file_size}MB)\n";
  filter_by_file_size "/" \
  | head -n 50;
  printf "End of List\n";
}

slow() {
  printf "MB\t100 Largest Directories in "/" (>=${min_file_size}MB)\n"
  for _dir in $(find / -mindepth 1 -type d); do 
    du -smx ${_dir}
  done \
  | sort -nr \
  | while read _size _path; do
      if [[ "$_size" -gt "$min_file_size" ]]; then
        printf "$_size\t$_path";
      fi
    done \
    | sort -nr \
    | head -n 100;
  printf "End of List\n";
}

##########

update_locatedb() {
  if [[ -f "/var/lib/mlocate/mlocate.db" ]]; then
    db_old=$(find /var/lib/mlocate/mlocate.db -mmin +30)
  else
    printf "no locatedb found; exiting.\n"
    exit 1
  fi
  if [[ ${db_old} == "1" ]]; then
    nice -n -20 updatedb;
  fi
}

prefilter_with_locate() {
  locate -bi0 --regex '(sql$|bak$|zip$|log$|tar$|csv$|tgz$|mp4$|png$)' \
  | xargs -0 -I % dirname % \
  | sort \
  | uniq \
  | while read -r _dir; do 
      if [[ -d "${_dir}" ]]; then
        search_dirs_array+=( '${_dir}' )
      fi
    done;
 }

filter_by_file_size() {
  unset depth
  if [[ "$subcommand" == "faster" ]]; then
    depth="--maxdepth 1"
  fi
  nice -n -20 \
    find ${1} \
      ${depth} \
      -type f \
      -size +${min_file_size}M \
      -exec du -mx '{}' \; 2>&1 \
  | sort -nr;
  unset depth
}

filter_by_dir_size() {
  for _dir in ${search_dirs_array[@]}; do
    du -smx ${_dir};
  done \
  | sort -nr
}
count_files_in_dir() {
  nice -n -20 \
  find ${1} -maxdepth 1 -type f \
  | wc -l
}

##########

if [[ "$#" != "2" ]];
  usage
  exit 1
fi

case $subcommand in
  --fastest|-fff)
    fastest
    ;;
  --faster|-ff)
    faster
    ;;
  --fast|-f)
    fast
    ;;
  --slow|-s)
    slow
    ;;
  --help|-h)
    usage
    exit 0
    ;;
  *)
    usage
    exit 1
    ;;
esac
