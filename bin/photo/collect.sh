#!/bin/zsh

fp_0=${0};

help() {
  echo "[Usage] ${fp_0}";
}

# ${*}
dp_destination_root=;
dp_source_root=;
quiet=0;
verbose=0;

while getopts ':d:qs:v' o; do
  case "${o}" in
    d) dp_destination_root=${OPTARG};;
    s) dp_source_root=${OPTARG};;
    q) quiet=1;;
    v) verbose=1;;
  esac;
done;
#

output() {
  if [ ${quiet} -ne 1 ]; then
    echo ${1};
  fi;
}

# ${errors}
errors=();

if [ "${dp_source_root}" = '' ]; then
  errors+=('Source directory not specified.');
elif [ ! -d ${dp_source_root} ]; then
  errors+=("Source directory \"${dp_source_root}\" not found.");
fi;

if [ "${dp_destination_root}" = '' ]; then
  errors+=('Destination directory not specified.');
elif [ ! -d ${dp_destination_root} ]; then
  errors+=("Destination directory \"${dp_destination_root}\" not found.");
fi;

if [ ${#errors[@]} -ne 0 ]; then

  if [ ${quiet} -ne 1 ]; then

    for error in "${errors[@]}"; do
      echo "[Error] ${error}";
    done;

    help;

  fi;

  exit;

fi;
#

#
for fp_source in $(/usr/bin/find ${dp_source_root} -type f | /usr/bin/grep -e '.\(jpe\?g\|png\)$' -i); do

  fx_destination=${(L)fp_source##*\.};

  ymdhis=($(exiftool -a -datetimeoriginal ${fp_source} | sed -e 's/^.*: //'));

  ymd=(${(s/:/)ymdhis[1]});
  his=(${(s/:/)ymdhis[2]});

  y=${ymd[1]};
  m=${ymd[2]};
  d=${ymd[3]};

  h=${his[1]};
  i=${his[2]};
  s=${his[3]};

  if [ "${y}" = '' ] || [ "${m}" = '' ] || [ "${d}" = '' ] || [ "${h}" = '' ] || [ "${i}" = '' ] || [ "${s}" = '' ]; then
    output "${fp_source} -> (Skipped)";
  else

    dp_destination="${dp_destination_root}/${y}/${m}/${d}";
    fn_destination="${y}${m}${d}${h}${i}${s}01.${fx_destination}";
    fp_destination="${dp_destination}/${fn_destination}";

    if [ -e ${fp_destination} ]; then
      output "${fp_source} -> ${fp_destination} (Skipped)";
    else

      if [ ! -d ${dp_destination} ]; then
        mkdir -p ${dp_destination};
      fi;

      cp ${fp_source} ${fp_destination};

      output "${fp_source} -> ${fp_destination} (Copied)";

    fi;
  fi;

done;
#

exit;
