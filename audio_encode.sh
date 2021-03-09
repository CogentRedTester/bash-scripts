#!/bin/bash

#
# remuxes a media file with an extra audio stream
# new stream is a copy of the given audio track number reencoded in ac3
#

file=$( printf "%q" "$1" )
file="$1"
main_stream=$2

if [ -z $main_stream ]
then
	main_stream=0
else
	main_stream=$(($2 - 1))
fi

num_audio=$(ffprobe -v error -show_entries stream=codec_type,index "$file" -print_format compact | grep audio -c)

if (( $num_audio < 1 ))
then
	return
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

if ffmpeg -i "$file" -c copy -map 0 -map -0:a -map 0:a:$main_stream -c:a:0 ac3 -b:a:0 640k ${args[@]} out.mkv
then
	echo "success"
	mv $file $( printf "%q" "${1}.original" )
	mv out.mkv $file
else
	echo "conversion did not exit successfully"
	exit
fi

mv $file $( printf "%q" "${1}.original" )
mv out.mkv $file
