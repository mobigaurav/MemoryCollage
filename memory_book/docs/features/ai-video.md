# One photo, one clip

AI in Memory Book is a motion pass on a picture the person already chose. It is not a prompt box on the home screen. The book, the collage, and the film studio come first. The clip is a credit spent on a single photo, with an explicit warning that the picture will leave the device.

## The phone never holds the vendor key

The app posts the image to our API with the Cognito bearer token. The Lambda checks the token, then calls Runway. The vendor key is a stack parameter, masked, and omitted from later deploys so it is not replaced by an empty default.

A photo uses Runway Gen-4 Turbo, image-to-video, portrait ratio, five or ten seconds. Words that accompany the photo describe motion only. They are not a new scene. A request with words and no photo uses Gen-4.5, because Turbo will not start without an image. The API returns a job id immediately. The phone polls until the clip URL is ready, downloads the file, and files it on the Reels shelf.

The app spends one Memory Book credit for that call. Runway spends its own credits, about twenty-five for five seconds of Turbo. The confirm sheet says both numbers. People who watch a vendor dashboard and see 25 have not been charged 25 of ours.

## Sound is an open product question

Gen-4 Turbo’s image-to-video request has no audio field. The clip comes back silent. A score copied from the phone and mixed underneath is not music made from the picture, and it should not be described that way. A film still uses the track the person picked, because that pipeline is ours. A clip that should carry sound matched to the scene needs a model that accepts an audio flag, or a second job that generates sound from the prompt and is mixed on the device. Both cost more than Turbo. Until that choice is made, the feature is the moving photo.

## Failure

If the vendor is not configured, the API tells the phone to fall back. The phone can then build a Memory film from the same stills. The credit taken for a call that never left the building is returned on the device. The person sees a sentence, not a spinner that ends on a blank screen.

Save writes the file to the photo library and says so in the dialog and in a snackbar. Share uses the same system sheet as a film.

## What is still thin

The server ledger is in memory. A cold start forgets jobs and credit grants. The honest next step is a database, then a RevenueCat webhook that only grants after it checks a signature. The client contract does not change when that happens. The phone still sends one photo, still polls one job, and still refuses to call Runway itself.

## Diagram

```
  Book or Reels                Phone                      API (Lambda)              Runway
  "this photo"                   |                            |                       |
        |                        |                            |                       |
        | confirm: picture leaves|                            |                       |
        +----------------------->|                            |                       |
                                 | POST /v1/ai/video          |                       |
                                 | Bearer Cognito id token    |                       |
                                 | image base64, prompt       |                       |
                                 |--------------------------->| verify token          |
                                 |                            | image? gen4_turbo     |
                                 |                            | words only? gen4.5    |
                                 |                            |---------------------->|
                                 |        job id              |                       |
                                 |<---------------------------|                       |
                                 | GET /v1/ai/jobs/{id}       | poll task             |
                                 |--------------------------->|---------------------->|
                                 |        video url           |                       |
                                 |<---------------------------|                       |
                                 | download mp4               |                       |
                                 v                            |                       |
                            reels/  +  save or share

  App credit spent: 1
  Runway meter for 5s Turbo: about 25 of theirs
  Audio field on Turbo: none
```

## Libraries

| Library | Role |
| --- | --- |
| [http](https://pub.dev/packages/http) | Post the photo, poll the job, download the mp4 |
| [FastAPI](https://fastapi.tiangolo.com/) + [Mangum](https://mangum.fastapiexpress.com/) | API on Lambda |
| [httpx](https://www.python-httpx.org/) | Server call to Runway |
| AWS API Gateway, Lambda, Cognito | Edge, runtime, identity |
| [Runway](https://docs.dev.runwayml.com/) image-to-video | Gen-4 Turbo. Text-only uses Gen-4.5 |
| [gal](https://pub.dev/packages/gal), [share_plus](https://pub.dev/packages/share_plus) | Save and share the finished file |

The Runway key stays in the stack parameter `VideoVendorApiKey`. It is not in the phone.

## Source

`services/api/mb_api/runway_video.py` chooses the model from whether a photo was sent.

```python
if image_base64:
    path = "/image_to_video"
    body = {
        "model": "gen4_turbo",
        "promptImage": _data_uri(image_base64),
        "promptText": text,
        "ratio": "720:1280",
        "duration": duration,
    }
else:
    path = "/text_to_video"
    body = {"model": "gen4.5", "promptText": text, ...}
```

The phone client is `AiVideoClient` in `memory_book/lib/services/auth_ai.dart`. The confirm-and-save UI is `memory_book/lib/features/ai/cloud_clip.dart`.
