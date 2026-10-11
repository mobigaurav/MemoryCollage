# A film from stills, encoded on the phone

A Memory film is an ordered set of photos, a frame shape, a few seconds on each still, a filter, a transition, and a piece of music. The phone encodes it. There is no FFmpeg in the app. FFmpeg would inflate the binary for a job the platform already does.

## Why native, and why upright

Flutter prepares the list of image paths and the audio file. A method channel asks iOS or Android to write an H.264 file.

On iOS that writer is `AVAssetWriter`. On Android it is `MediaCodec` into a `MediaMuxer`. Transitions are frames the encoder receives, not an animation running in the widget tree while a screen recorder watches.

Portrait photos were the first real bug. `UIImage` loaded from a file ignores EXIF, so a tall photo became a wide frame. The encoder draws the bitmap upright before it fits the frame. A 9:16 film keeps a portrait photo tall. A 16:9 film is a wide frame and will crop that portrait. The studio says so, because the crop is a choice of aspect, not a surprise.

Android reads the same orientation tag and rotates before encode.

## Music is part of the file

The player can be silent even when the file has an audio track, if the iOS session is the wrong category. Playback switches the session to playback after the player is created, so the silent switch is the only thing that mutes it.

The mix loads the audio track asynchronously, then inserts a duration that is the shorter of the picture and the music. The encoder returns the mixed file. The studio plays that path. If the path is still the silent original, the screen says the film is ready and the music did not attach. It does not claim the score is there.

Bundled scores and a track from Files are the same input to that mix. The person picked the music. The film does not invent a soundtrack from the picture. That is a different product, and it belongs to the AI clip, which today comes back without sound.

## Reels are the shelf for finished films

Finished films and AI clips are copied into `reels/` and indexed in a small JSON file. The Reels tab is a 9:16 grid. Each tile shows a frame, and share and delete sit on the tile. Opening a tile plays the file with sound. Share uses the system sheet with a video file and a caption, which is how Instagram and Facebook appear when those apps are installed. There is no private Instagram API in the app.

Delete confirms, then removes the file and the index row.

## Diagram

```
  stills + music
        |
        v
  SlideshowExporter  (Flutter)
        |
        |  MethodChannel memory_book/video_encoder
        |  encodeSlideshow / mixAudio
        v
  +------------------+     +------------------+
  | iOS              |     | Android          |
  | AVAssetWriter    |     | MediaCodec       |
  | AVMutableComposition     | MediaMuxer     |
  | draw upright     |     | Exif rotate      |
  +--------+---------+     +--------+---------+
           \                        /
            +----------+-----------+
                       |
                  mixed .mp4
                       |
           +-----------+-----------+
           |                       |
      video_player            reels/id.mp4
      AVAudioSession          reels.json
      .playback                     |
                               9:16 grid
                               Share | Delete
                                    |
                              share_plus
                              video/mp4
```

## Libraries

| Library | Role |
| --- | --- |
| Apple AVFoundation | H.264 encode, audio mix, playback session. In `AppDelegate.swift` |
| Android MediaCodec, MediaMuxer, ExifInterface | Encode, mux, upright stills. In `MainActivity.kt` |
| [video_player](https://pub.dev/packages/video_player) | Preview and the reel stage |
| [file_picker](https://pub.dev/packages/file_picker) | A track from Files |
| [gal](https://pub.dev/packages/gal) | Save the mp4 |
| [share_plus](https://pub.dev/packages/share_plus) | Sheet that can offer Instagram and Facebook |

No FFmpeg.

## Source

`memory_book/lib/services/export_service.dart` is the channel.

```dart
static const _channel = MethodChannel('memory_book/video_encoder');

Future<String> mixAudio({
  required String videoPath,
  required String audioPath,
}) async {
  final result = await _channel.invokeMethod<String>('mixAudio', {
    'videoPath': videoPath,
    'audioPath': audioPath,
  });
  return result ?? videoPath;
}
```

The studio plays the path that comes back. `memory_book/lib/services/reel_library.dart` copies that file into `reels/` and writes `reels.json`. The grid is `memory_book/lib/features/reels/reels_screen.dart`.
