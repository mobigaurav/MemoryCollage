from fastapi import APIRouter, Request
from fastapi.responses import HTMLResponse, JSONResponse, Response

from mb_api.notes_store import MAX_BYTES, MIN_BYTES, get_notes

router = APIRouter()


def _store_or_503():
    notes = get_notes()
    if notes is None:
        return None, JSONResponse(
            status_code=503,
            content={"message": "Voice notes are not on this server yet."},
        )
    return notes, None


def _page(note_id: str) -> str:
    return f"""<!doctype html>
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>A voice note</title>
<style>
  body {{
    margin: 0; min-height: 100vh; display: grid; place-items: center;
    background: #FAF4E8; color: #4A2C1A; font-family: Georgia, serif;
  }}
  main {{ text-align: center; padding: 32px; }}
  p {{ color: #4A3B32; }}
  audio {{ width: min(320px, 80vw); margin-top: 18px; }}
</style>
<main>
  <h1>A voice note</h1>
  <p>Someone left this on a Memory Book page.</p>
  <audio controls autoplay src="{note_id}/audio"></audio>
</main>
"""


@router.post("/v1/notes")
async def create_note(request: Request):
    notes, error = _store_or_503()
    if error is not None:
        return error
    audio = await request.body()
    if len(audio) < MIN_BYTES:
        return JSONResponse(
            status_code=400,
            content={"message": "That recording was too short."},
        )
    if len(audio) > MAX_BYTES:
        return JSONResponse(
            status_code=400,
            content={"message": "A voice note has to stay under a few seconds."},
        )
    note = notes.create(sub=request.state.sub, audio=audio)
    return {"id": note.id}


@router.get("/v1/notes/{note_id}")
def read_note(note_id: str):
    notes, error = _store_or_503()
    if error is not None:
        return error
    if notes.get(note_id) is None:
        return JSONResponse(status_code=404, content={"message": "That voice note is gone."})
    return HTMLResponse(_page(note_id))


@router.get("/v1/notes/{note_id}/audio")
def read_audio(note_id: str):
    notes, error = _store_or_503()
    if error is not None:
        return error
    note = notes.get(note_id)
    if note is None:
        return JSONResponse(status_code=404, content={"message": "That voice note is gone."})
    return Response(content=note.audio, media_type="audio/mp4")
