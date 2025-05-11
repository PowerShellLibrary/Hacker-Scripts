# https://ffmpeg.org/ffmpeg.html

# Takes two files (audio, video) and combine them together into mp4 file.
# As audio is shorter add offset to the video so it can sync with audio
#
# -y (global)       - overwrite output files without asking.
# -itsoffset 0.2    - delay video by 0.2 seconds
# -i v.webm         - first input - video
# -i a.mp4          - second input - audio
# -map 0:0          - map stream 0 to output from input1
# -map 1:0          - map stream 1 to output from input2
# -c                - for -c[:stream_specifier] codec. copy (output only) to indicate that the stream is not to be re-encoded
ffmpeg -y -itsoffset 0.2 -i v.webm -i a.mp4 -map 0:0 -map 1:0 -c copy oFilename.mp4


# Converts wav to mp3
#
# -i path             input - mp3
# -vn                 disable video
# -ar rate            set audio sampling rate (in Hz)
# -ac channels        set number of audio channels
# -ab bitrate         audio bitrate (please use -b:a)
ffmpeg -i "$($_.FullName)" -vn -ar 44100 -ac 2 -b:a 192k "$($_.FullName.Replace('.wav','.mp3'))"


# Takes two files (audio, image) and combine them together into mp4 file.
# -loop 1           - loop the input image infinitely (1 - loop, 0 - no loop)
# -i img.jpg        - specifies an input file (image)
# -i audio.mp3      - second input file (MP3 audio)
# -c:v libx264      - specifies the video codec
# -c:a aac          - specifies the audio codec. aac is a standard codec for MP4 files, offering good quality at lower bitrates.
# -b:a 320k         - sets the audio bitrate
# -shortest         - this option ensures that the output video will be as long as the shortest input.
#  output.mp4       - name of the output video file
ffmpeg -loop 1 -i img.jpg -i audio.mp3 -c:v libx264 -c:a aac -b:a 320k -shortest output.mp4

# Crop video from the top
# This command crops the video by removing 440 pixels from the top, effectively shifting the video down by that amount.
# -i input.mp4                  - specifies the input video file
# -vf "crop=iw:ih-440:0:440"    - applies a video filter (vf) to crop the video.
#   - iw        Input width (keeps the full width of the video).
#   - ih-440    Input height minus 440 pixels
#   - 0         X offset (starts cropping from the left edge).
#   - 440       Y offset (starts cropping from 440 pixels down from the top).
# -c:a copy                     - copies the audio stream without re-encoding it
# output.mp4                    - name of the output video file
ffmpeg -i .\input.mp4 -vf "crop=iw:ih-440:0:440" -c:a copy output.mp4