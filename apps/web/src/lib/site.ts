export const site = {
  name: "Memory Book",
  description:
    "A photo book, collage studio, and short film made from the pictures already on your phone.",
  url:
    process.env.NEXT_PUBLIC_SITE_URL?.trim() ||
    "https://memory-book-pearl-zeta.vercel.app",
  appStoreUrl:
    process.env.NEXT_PUBLIC_APP_STORE_URL?.trim() ||
    "https://apps.apple.com/us/app/memory-book/id6741048860",
  playStoreUrl:
    process.env.NEXT_PUBLIC_PLAY_STORE_URL?.trim() ||
    "https://play.google.com/store/apps/details?id=com.playingview.mobigaurav.memorybook",
};
