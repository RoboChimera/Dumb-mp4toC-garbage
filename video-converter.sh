#!/bin/sh
frame=0
filename=$(echo $1 | sed -e 's/.tar.gz//g')

if [ "$1" = "" ]; then
	echo Specify a tar.gz name, dummy...
	exit 0
fi

mkdir -v $(pwd)/.frames_in
ffmpeg -i $(pwd)/video_in/video.mp4 -vf "select=not(mod(n\,1))" -vsync vfr $(pwd)/.frames_in/frame_%01d.jpg
clear

mkdir -pv $(pwd)/.video/frames/
mkdir -v $(pwd)/.$filename

if [ -d $(pwd)/audio_in/ ]; then
	cp -rf $(pwd)/audio_in/audio.mp3 $(pwd)/.$filename/audio
fi

echo '#include <stdio.h>' > $(pwd)/.video/frames/preframe
echo '#include <stdlib.h>' >> $(pwd)/.video/frames/preframe
echo '#include <time.h>' >> $(pwd)/.video/frames/preframe
echo ' ' >> $(pwd)/.video/frames/preframe
echo 'int main() {' >> $(pwd)/.video/frames/preframe
echo 'struct timespec tim, tim2;' >> $(pwd)/.video/frames/preframe
echo 'tim.tv_sec = 0;' >> $(pwd)/.video/frames/preframe
echo 'tim.tv_nsec = 33333333L;' >> $(pwd)/.video/frames/preframe
echo 'system("clear");' >> $(pwd)/.video/frames/preframe
cat $(pwd)/.video/frames/preframe > $(pwd)/.video/frames/frames.c

while(true); do
	frame=$(expr $frame + 1)
	if [ -f $(pwd)/.frames_in/frame_$frame.jpg ]; then
		$(pwd)/bin/ascii-image-converter $2 $(pwd)/.frames_in/frame_$frame.jpg > $(pwd)/.video/frames/.frame-p0
		cat $(pwd)/.video/frames/.frame-p0
		if [ "$2" = "-c" ]; then
			cat $(pwd)/.video/frames/.frame-p0 | sed 's/\\/\\\\/g' > $(pwd)/.video/frames/.frame-p1
			cat $(pwd)/.video/frames/.frame-p1 | sed "s/'/\\'/g" > $(pwd)/.video/frames/.frame-p2
			cat $(pwd)/.video/frames/.frame-p2 | sed 's/"/\\"/g' > $(pwd)/.video/frames/.frame-p0
			rm -rf $(pwd)/.video/frames/frame-p1
			rm -rf $(pwd)/.video/frames/frame-p2
		fi
		if [ "$2" = "-f" ]; then
			cat $(pwd)/.video/frames/.frame-p0 | sed 's/\\/\\\\/g' > $(pwd)/.video/frames/.frame-p1
			cat $(pwd)/.video/frames/.frame-p1 | sed "s/'/\\'/g" > $(pwd)/.video/frames/.frame-p2
			cat $(pwd)/.video/frames/.frame-p2 | sed 's/"/\\"/g' > $(pwd)/.video/frames/.frame-p0
			rm -rf $(pwd)/.video/frames/frame-p1
			rm -rf $(pwd)/.video/frames/frame-p2
		fi
		cat $(pwd)/.video/frames/.frame-p0 | sed 's/$/placeholder/' > $(pwd)/.video/frames/.frame-p1
		echo 'printf("' > $(pwd)/.video/frames/.frame-p2
		cat $(pwd)/.video/frames/.frame-p1 | sed ':a; N; $!ba; s/\n//g' >> $(pwd)/.video/frames/.frame-p2
		echo '");' >> $(pwd)/.video/frames/.frame-p2
		cat $(pwd)/.video/frames/.frame-p2 | sed ':a; N; $!ba; s/\n//g' >> $(pwd)/.video/frames/.frame-p3
		cat $(pwd)/.video/frames/.frame-p3 | sed 's/%/%%/g' > $(pwd)/.video/frames/.frame-p4
		cat $(pwd)/.video/frames/.frame-p4 | sed 's/placeholder/\\n/g' >> $(pwd)/.video/frames/frame_$frame
		rm $(pwd)/.video/frames/.frame-p*
		echo 'nanosleep(&tim, &tim2);' >> $(pwd)/.video/frames/frame_$frame
		echo 'system("clear");' >> $(pwd)/.video/frames/frame_$frame
		cat $(pwd)/.video/frames/frame_$frame >> $(pwd)/.video/frames/frames.c
		rm -rf $(pwd)/.frames_in/frame_$frame.jpg
		rm -rf $(pwd)/.video/frames/frame_$frame
	else
		echo '}' >> $(pwd)/.video/frames/frames.c
		cp $(pwd)/.video/frames/frames.c $(pwd)/$filename.c
		tar -czvf "$filename-C.tar.gz" $filename.c
		gcc $(pwd)/.video/frames/frames.c -o $(pwd)/.$filename/video
		tar -czvf $filename.tar.gz .$filename/
		rm -rf $(pwd)/.video
		rm -rf $(pwd)/.$filename
		rm -rf $(pwd)/.frames_in
		rm $(pwd)/$filename.c
		exit 0
	fi
done
