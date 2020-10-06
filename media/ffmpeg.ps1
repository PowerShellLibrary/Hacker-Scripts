# https://ffmpeg.org/ffmpeg.html
# Take two files (audio, video) and combine them together into mp4 file.
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