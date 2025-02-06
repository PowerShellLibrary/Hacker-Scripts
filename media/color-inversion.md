# Color inversion with ffmpeg

```powershell
ffmpeg -i input.mp4 -vf "negate,hue=h=180,eq=contrast=1.2:saturation=1.1" output.mp4
```
## Demo
#### Before

<video width="820"  controls>
  <source src="https://github.com/user-attachments/assets/a6969533-a1f9-4a8f-9203-dd151f4c6aa7" type="video/mp4">
</video>

<!-- to display video on GitHub Markdown -->
https://github.com/user-attachments/assets/a6969533-a1f9-4a8f-9203-dd151f4c6aa7

#### After

<video width="820"  controls>
  <source src="https://github.com/user-attachments/assets/16785da7-4ed3-48c5-ad3e-b1223987c49e" type="video/mp4">
</video>

<!-- to display video on GitHub Markdown -->
https://github.com/user-attachments/assets/16785da7-4ed3-48c5-ad3e-b1223987c49e


## Explanation
The `-i input.mp4` part specifies the input file.

The `-vf` flag stands for "video filter," and it is followed by a series of filters applied to the video.

The filters are:

- `negate`: This filter inverts the colors of the video, creating a negative effect.
- `hue=h=180`: This filter adjusts the hue of the video by 180 degrees, effectively rotating the color wheel to change the overall color tone.
- `eq=contrast=1.2:saturation=1.1`: This filter adjusts the contrast and saturation of the video. The contrast=1.2 increases the contrast by 20%, making the darks darker and the lights lighter. The saturation=1.1 increases the saturation by 10%, making the colors more vivid.



Combining these filters results in a video with inverted colors, a shifted hue, and enhanced contrast and saturation. The processed video is then saved as output.mp4.


*[source:
Rubber Duck Thursdays!](https://www.youtube.com/watch?v=o7b6t6uZJPA)*