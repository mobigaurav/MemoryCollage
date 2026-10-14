# Memory Book — Product Roadmap

**Status:** living document  
**Companion:** [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md)  
**North star:** the most beautiful way to live with your photos and turn them into pages, collages, and films — with optional AI that serves *their* memories, not a generic video generator.

Capture everything we discussed so we do not forget it. Dates are relative to “book feels magical,” not calendar guesses.

---

## 1. Positioning

**Promise:** Open your memories like a book. Edit any page. Share a still or a reel.

**Not:** another purple-gradient collage tab. Not CapCut. Not Sora.

**Is:** tactile photobook + serious still/video craft + later AI motion and enhance, all local-first until the user asks for cloud or credits.

**Store:** rebrand the live iOS app to Memory Book on the existing listing. Android ships as a new Play app under the same name. Visual language: paper, film, leather, foil.

---

## 2. Product principles

1. **Book first.** If the page-turn is not demo-able, templates will not save us.
2. **Local-first, privacy-default.** No login wall. Photos stay on device.
3. **AI is a spice.** On-device smarts (dates, Ken Burns, auto reel) before generative APIs.
4. **Paywall honesty.** Premium must actually gate what the sheet claims.
5. **Exports are real.** Canvas + encoder. Never screenshot the window.
6. **Free must still delight.** A three-book shelf with watermarked exports is OK; a broken book is not.

---

## 3. Now / next / later

```mermaid
flowchart LR
  P0[P0 Foundation]
  P1[P1 Magical book]
  P2[P2 Collage craft]
  P3[P3 Films and reels]
  P4[P4 Store polish]
  P5[P5 AI plus identity]
  P6[P6 World-class craft]
  P7[P7 Cloud print social]
  P0 --> P1 --> P2 --> P3 --> P4 --> P5 --> P6 --> P7
```

| Phase | Intent | Login | AI |
| --- | --- | --- | --- |
| P0 Foundation | Flutter, Drift, RevenueCat, nav, permissions | No | No |
| P1 Magical book | Cover, curl, slots, persist, share spread | No | No |
| P2 Collage | Canvas export, ~30 templates, watermark gate | No | No |
| P3 Video | Film studio + Album→Reel + save to roll | No | On-device smart reel only |
| P4 Store | Onboarding, ASO, privacy labels, paywall | No | No |
| P5 Identity + generative | Apple/Google, credits, proxy image-to-video | Optional | Yes, paid credits |
| P6 Craft depth | Pro photo/video editor, stickers, music, notifications | Optional | Enhance, captions, cleanup |
| P7 Platform | Cloud backup, shared family book, print, web flipbook | Yes for those features | Style packs, optional B-roll |

**Do not start P5 until P1 feels magical.**

---

## 4. Feature inventory

Legend: **Shipped** in the Flutter client · **Next** in P1–P4 polish · **Later** P5+

### 4.1 Living photo album (hero)

| Feature | AI? | Status |
| --- | --- | --- |
| Physical covers (leather, linen, Polaroid, wedding, baby, travel) | Non-AI | Shipped |
| Two-page spread + perspective page-turn + haptics | Non-AI | Shipped |
| Empty photo corners; tap to add | Non-AI | Shipped |
| Replace, caption, filter, remove | Non-AI | Shipped |
| Page layouts: 1 / 2 / 3 / polaroid / scrapbook / blank | Non-AI | Shipped |
| Insert blank spread | Non-AI | Shipped |
| Share spread as image | Non-AI | Shipped |
| Album → 9:16 flip reel | Non-AI | Shipped (iterate quality) |
| Interactive crop / rotate / straighten in slot | Non-AI | Shipped (crop/pan/zoom; rotate later) |
| Reorder pages, duplicate, trash | Non-AI | Shipped |
| Auto-fill from a date range / trip | Non-AI (EXIF) | Shipped |
| Paper rustle, cover parallax, reduce-motion fallback | Non-AI | Shipped (haptic rustle) |
| Face-aware default crop | Light AI / ML Kit on-device | Next |
| Handwriting fonts, washi, photo corners packs | Non-AI, premium | Later |
| Collaborative family book | Non-AI + login | Later |
| Print photobook partner | Non-AI | Later |

### 4.2 Images — collage & photo craft

| Feature | AI? | Status |
| --- | --- | --- |
| ~30 curated templates; free vs premium actually gated | Non-AI | Shipped |
| Canvas render JPEG / PNG / HEIC, 720–2160 | Non-AI | Shipped (HEIC Android = JPEG fallback) |
| Text + backgrounds + shuffle | Non-AI | Shipped |
| Watermark on free | Non-AI | Shipped |
| Stickers, frames, film borders | Non-AI | Shipped (film, foil, heart, tape, corners, date) |
| True freeform drag/pinch/rotate | Non-AI | Shipped (drag/pinch; rotate later) |
| Light / color / crop editor | Non-AI | Next |
| 4K export | Non-AI, premium | Later |
| Magic enhance, sky, portraits | On-device enhance is Premium; generative cleanup is later | Enhance shipped on a page |
| Object remove / uncrop | AI | Later |
| Style transfer on a page (film, watercolor) | AI | Later |

Collage photo cap stays modest (~15). Books allow many more pages.

### 4.3 Video — memory film

| Feature | AI? | Status |
| --- | --- | --- |
| Stills → MP4; 9:16, 1:1, 16:9 | Non-AI | Shipped |
| Per-slide duration, bundled scores | Non-AI | Shipped |
| Filters | Non-AI | Shipped (preview/encode alignment Next) |
| Transitions in UI | Non-AI | Shipped — Crossfade/Slide/Zoom/Cut encoded |
| Save to camera roll + share | Non-AI | Shipped |
| User-picked audio | Non-AI | Shipped |
| Beat-aware cuts, Ken Burns faces | On-device “smart” | Next |
| Titles / end cards | Non-AI | Shipped |
| Background encode + “your reel is ready” | Non-AI + local notification | Shipped (local notify on finish) |
| Image-to-video motion on a still or spread | Generative AI, credits | On a photo: credit for cloud, Premium for on-phone film |
| Auto captions / voiceover script from dates | AI | P6 |
| Do **not** ship prompt-to-video as the home tab | Generative | Out of scope / never lead |

### 4.4 Saving, sharing, library

| Feature | Status |
| --- | --- |
| Copy-on-ingest into sandbox | Shipped |
| System share sheet | Shipped |
| Gallery save (`gal`) | Shipped |
| Project auto-save (collage/video drafts) | Shipped (local draft restore) |
| Export history | Shipped (recent list in Settings) |
| Share as Stories/Reels preset (safe areas) | Next |
| Web flipbook link | Later (needs backend) |
| Original-quality export toggle | Later, premium |

### 4.5 Templates & content packs

- Collage layouts (shipped, expand in seasons: wedding, baby, travel).
- Book page masters (more scrapbook grids).
- Cover cloths (shipped set + seasonal premium).
- Music packs (11 bundled; licensed extra packs via IAP).
- Sticker / LUT packs as RevenueCat non-consumables or attached to premium.

### 4.6 RevenueCat & growth

| Item | Status |
| --- | --- |
| Entitlement `premium` | Shipped (store entitlement or dev unlock) |
| Annual primary, monthly secondary | Shipped in the paywall; products live in the RC dashboard |
| Consumable AI credits | P5 |
| Experiments / offering copy | P4 once RC key is live |
| `logIn` after identity | P5 |
| Promo codes / win-back | Later |

Free: 3 books (`AppConfig.freeAlbumLimit`), basic templates, watermark, 720p-class video.  
Paid: unlimited books, clean export, all templates, 4K, music/sticker packs.

### 4.7 Notifications

| Item | When |
| --- | --- |
| Opt-in local: export complete | Shipped |
| Opt-in local: “photos from this week” | Shipped (shelf reminder, opt-in) |
| “On this day” from album dates | P6 |
| Remote: AI job done, credit receipt | P5 |
| No unsolicited marketing push | Never |

### 4.8 Account (optional)

No login wall. The shelf opens without an account.

| Path | Status |
| --- | --- |
| Email sign-up, confirmation code, sign-in, forgot password | Shipped (Cognito when `COGNITO_CLIENT_ID` is set; on-device account otherwise) |
| Sign in with Apple / Google | Shipped as secondary options on the account screen |
| Welcome credits (3) on first sign-in | Shipped |
| Prompt only when spending a credit or opening Account | Shipped |
| Cloud backup / shared album requiring an account | Later |

Own Cognito pool. Do not point this app at Arogya’s health pool.

---

## 5. Phase detail

### P0 — Foundation (client exists)

Flutter app, Drift schema, go_router, paper theme, RevenueCat wrapper, photo permissions, SPM iOS (no CocoaPods).

### P1 — Magical book (priority)

Polish until someone films the page-turn:

- Curl quality on Android, snap physics, optional sound
- Slot crop UI that matches stored scale/offset
- Cover photo + title editing on the shelf
- Empty shelf that still feels like a studio
- Accessibility reduce-motion

**Exit:** a friend says “I want this for our wedding photos.”

### P2 — Collage craft

- Stickers/text fonts; true freeform
- Face-aware cell crop
- HEIC on Android where possible
- Persist collage projects in the existing Drift tables
- Template packs themed to book covers

### P3 — Films and reels

- Native transition ramps (the old Swift code existed but was unused — do it properly in the encoder)
- Android audio mix
- Beat-friendly duration from track length
- Album→Reel Ken Burns + hold timing
- Save-to-roll reliability (never lie in a toast)
- Local notification when encode finishes

### P4 — Store

- Onboarding that *is* the book (already sketched)
- Screenshot set in [store/ASO.md](../store/ASO.md)
- Privacy nutrition [store/PRIVACY.md](../store/PRIVACY.md)
- Production RevenueCat key; hide dev unlock in release
- Crash reporting without photo PII
- Confirm bundle IDs vs existing listing

### P5 — AI + identity

- Sign in with Apple / Google
- Server credit ledger + RevenueCat webhook
- Image-to-video on a chosen page/spread via proxy
- Confirmation: “This photo leaves the device”
- Fallback to on-device reel if vendor fails (refund credit)

### P6 — World-class craft

- Full photo adjust + video timeline (order, trim stills, ducking music)
- On-device ML: grouping, faces, quiet auto-captions
- AI enhance / cleanup as credits
- Seasonal content, widgets (“open today’s page”), watch later optional
- Localization

### P7 — Platform

- Opt-in encrypted cloud shelf
- Shared family book with roles
- Print partnership
- Web flipbook for relatives who will not install the app
- Creator/template marketplace only if it does not dilute the book

---

## 6. AI vs non-AI (so we do not blur them)

**Non-AI (always the bulk of the app):** album UX, templates, crop, filters, music, transitions, share/save, IAP, notifications, print.

**On-device smart (not billed as “AI video”):** date clusters, face crop, Ken Burns, music fit, auto memory reel from an album.

**Generative (credits, login, proxy):** image-to-video, enhance, object remove, style transfer, optional short B-roll. Never home-screen text-to-video.

---

## 7. Success metrics (when analytics exist)

Privacy-friendly only (counts, not photo contents):

- Activation: created a book and turned a page in first session
- Aha: exported a spread or reel
- Retention: D7 opened an existing book (not only the editor)
- Paid: trial/annual start after a watermark intercept
- AI (later): credit attach rate, not raw generation volume
- Quality: export failure rate, crash-free sessions, encode time p50

---

## 8. Competitive notes (why we win)

| App | They own | We own |
| --- | --- | --- |
| Canva / Picsart | Graphic templates | Personal album object |
| CapCut / InShot | Pro timeline | Memory film from a book |
| Google Photos | Archive + “memories” | Craft, paper, export you designed |
| Relive | Trip videos | Ongoing household book |
| Mixbook / Chatbooks | Print | Daily living digital book that *can* print later |
| Runway / Pika | Prompt video | Their photos, optional motion |

---

## 9. Risks we already named

- Android page-curl performance
- Limited photo library UX
- Encoder size/quality (stay native until forced otherwise)
- Existing Swift albums stay on disk after the iOS update and will not open until a migration exists
- AI cost and latency — keep credits honest, refund on failure
- Paywall trust if templates are not really gated (fixed in Flutter; keep tests)

---

## 10. Near-term checklist (do not forget)

- [ ] RevenueCat dashboard: annual, monthly, entitlement `premium` (client paywall is ready)
- [ ] Hide local “Dev unlock” in the store binary (`--dart-define=DEV_UNLOCK=false`). Stays on for testing.
- [x] Encode real transitions; Android AAC mix
- [x] Slot crop gestures matching saved offsets
- [x] Persist collage/video projects in UI
- [x] Local notification permission copy
- [ ] Bundle ID decision for App Store Connect
- [ ] Golden screenshots of the curl for ASO
- [ ] Decide cloud vendor only when P1 is magical
- [x] AI confirmation sheet + privacy label update before first networked photo

When in doubt: ship a better book, not a bigger model.
