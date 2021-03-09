#!/bin/bash

#
# remuxes a media file with an extra audio stream
# new stream is a copy of the given audio track number reencoded in ac3
#

file=()
file[0]=( "$(printf "%q" "$1")" )
file[0]="$1"
main_stream=$2

if [ -z $main_stream ]
then
	main_stream=0
else
	main_stream=$(($2 - 1))
fi

num_audio=$(ffprobe -v error -show_entries stream=codec_type,index "${file[0]}" -print_format compact | grep audio -c)

if (( $num_audio < 1 ))
then
	echo "could not detect audio tracks from "${file[0]}""
	exit
fi

args=()
for (( i = 0; i < num_audio; i++ ))
do
	iplus=$(( i + 1 ))
	args+=("-map")
	args+=("0:a:$i")
	args+=("-c:a:$iplus")
	args+=("copy")
done

if ffmpeg -i "${file[0]}" -c copy -map 0 -map -0:a -map 0:a:$main_stream -c:a:0 ac3 -b:a:0 640k ${args[@]} out.mkv
then
	echo "success"
	file[1]=${file[0]}.original
	mv "${file[0]}" "${file[1]}"
	mv out.mkv "${file[0]}"
else
	echo "conversion did not exit successfully"
	exit
fi
