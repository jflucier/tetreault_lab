#!/bin/bash

set -eEx

help_message () {
	echo ""
	echo "Usage: assembly.metawrap.sh [-tmp /path/tmp] [-t threads] [-m memory] [--metaspades] [--megahit] -s sample_name -o /path/to/out -fq1 /path/to/fastq1 -fq2 /path/to/fastq2 "
	echo "Options:"

	echo ""
	echo "	-i STR	input path"
    echo "	-o STR	path to output dir"
    echo ""
    echo "  -h --help	Display help"

	echo "";
}

in_path=""
out_path=""

SHORT_OPTS="ht:i:o:"
LONG_OPTS='help,input,output'

OPTS=$(getopt -o $SHORT_OPTS --long $LONG_OPTS -- "$@")
# make sure the params are entered correctly
if [ $? -ne 0 ];
then
    help_message;
    exit 1;
fi

# loop through input params
while true; do
    # echo $1
	case "$1" in
		-h | --help) help_message; exit 1; shift 1;;
    -i | --input) in_path=$2; shift 2;;
    -o | --output) out_path=$2; shift 2;;
    --) help_message; exit 1; shift; break ;;
		*) break;;
	esac
done

if [ "$in_path" = "" ]; then
    echo "Please provide an input path with images to analyse."
    help_message; exit 1
else
    echo "## Input path: $in_path"
fi

if [ "$out_path" = "" ]; then
    echo "Please provide an output path"
    help_message; exit 1
else
    mkdir -p ${out_path}
    echo "## Output path: ${out_path}"
fi

for f in ${in_path}/*.tiff
do
  b=$(basename $f)
  name=${b%.tiff}
  new=$(perl -e '
  my $n="'$name'";
  my @t = split(/\./,$n);
  my $new = $t[0] . "_" . $t[1];
  print $new;
  ')
  slice_id=$(perl -e '
  my $n="'$name'";
  my @t = split(/\./,$n);
  my $new = $t[0];
  print $new;
  ')

  slice_lbl=$(printf "%03d" $slice_id)
  echo "converting ${f} to png3/DAPI_CNPase/${new}_s${slice_lbl}.png"
  convert $f ${out_path}/${new}_s${slice_lbl}.png
#  COUNTER=$((COUNTER+1))
done

python /home/def-pascalt-ab/programs/tetreault_lab/launch_deepslice.py \
-s rat --ensemble 1 --section 1 \
-i ${out_path}/ \
-o ensembleT_validsectionT.rat

python /home/def-pascalt-ab/programs/tetreault_lab/launch_deepslice.py \
-s rat --ensemble 1 --section 0 \
-i ${out_path}/ \
-o ensembleT_validsectionF.rat

python /home/def-pascalt-ab/programs/tetreault_lab/launch_deepslice.py \
-s rat --ensemble 0 --section 1 \
-i ${out_path}/ \
-o ensembleF_validsectionT.rat

python /home/def-pascalt-ab/programs/tetreault_lab/launch_deepslice.py \
-s rat --ensemble 0 --section 0 \
-i ${out_path}/ \
-o ensembleF_validsectionF.rat
