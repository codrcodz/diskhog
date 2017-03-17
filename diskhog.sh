#!/usr/bin/env bash

subcommand=${1}
min_file_size=250;
min_file_size=${2};
declare -a search_dirs_array;

##########

fastest() {
  update_locatedb;
  printf "MB\tDirectories Most Likey to Contain Large and/or Numerous Files\n";
  prefilter_with_locate;
  filter_by_dir_size;
  printf "--- End of List ---\n";
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
  printf "--- End of List ---\n";
}

fast() {
  printf "MB\t50 Largest Files in "/" (>=${min_file_size}MB)\n";
  filter_by_file_size / \
  | head -n 50
  printf "--- End of List ---\n";
}

slow() {
  printf "MB\t100 Largest Directories in "/" (>=${min_file_size}MB)\n"
  for _dir in $(find / -mindepth 1 -type d); do 
    du -smx ${_dir}
  done \
  | sort -nr \
  while read _size _path; do
    if [[ "$_size" >= "$min_file_size" ]]; then
      printf "$_size\t$_path";
    fi
  done \
  | sort -nr \
  | head -n 100;
  printf "--- End of List ---\n";
}

##########

update_locatedb() {
  if [[ -f "/var/lib/mlocate/mlocate.db" ]]; then
    db_old=$(find /var/lib/mlocate/mlocate.db -mmin +30)
  fi
  if [[ ${db_old} == "1" ]]; then
    nice -n -20 updatedb;
  fi
}

prefilter_with_locate() {
  locate -bi0 --regex '(sql$|bak$|zip$|log$|tar$|csv$|tgz$|mp4$|png$)'; \
  | xargs -0 -I % dirname %; \
  | sort; \
  | uniq; \
  | while read -r _dir; do 
      if [[ -d "${_dir}" ]]; then
        search_dirs_array+=( '${_dir}' )
      fi
    done;
 }

filter_by_file_size() {
  nice -n -20 \
    find ${1} \
      -maxdepth 1 \
      -type f \
      -size +${min_file_size}M \
      -exec du -mx '{}' \; 2>&1 \
  | sort -nr;
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

case subcommand in
  fastest)
    fastest
    ;;
  faster)
    faster
    ;;
  fast)
    fast
    ;;
  slow)
    slow
    ;;
  *)
    exit 1
    ;;
esac
