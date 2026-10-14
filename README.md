# Memory Book

A photo book that lives on the phone, with a collage studio and films made on the device. The store name is Memory Book on iOS and Android.

The old Swift app is no longer in this tree. Its history is still in git if a layout needs to be checked.

## Layout

| Path | What it is |
| --- | --- |
| [`memory_book/`](memory_book/README.md) | Flutter app for iOS and Android |
| [`apps/web/`](apps/web) | The public site |
| [`services/api/`](services/api) | The API: accounts, credits, family books, and one photo sent for a clip |
| [`infra/lite/`](infra/lite) | Cognito, API Gateway, Lambda, and the private media bucket |
| [`docs/BACKEND.md`](docs/BACKEND.md) | How the API is run and where dev is deployed |

iOS release builds keep the live bundle id `com.playingview.mobigaurav.MemoryCollage`, so this update replaces the app already on the App Store. Debug and Profile use `com.playingview.mobigaurav.memoryBook` and install beside it. Android is a new Play listing, `com.playingview.mobigaurav.memorybook`.

## Run the phone

From `memory_book`:

```bash
./flutterw pub get
./flutterw run
```

## Run the API and the site

```bash
make api-dev
make web-dev
```

## License

MIT. See [LICENSE](LICENSE).
