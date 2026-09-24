export const site = {
  name: "Memory Book",
  description:
    "A photo book, collage studio, and short film made from the pictures already on your phone.",
  url: process.env.NEXT_PUBLIC_SITE_URL?.trim() || "http://localhost:3000",
  supportEmail: "mobigaurav@gmail.com",
  appStoreUrl: process.env.NEXT_PUBLIC_APP_STORE_URL?.trim() || "",
  playStoreUrl: process.env.NEXT_PUBLIC_PLAY_STORE_URL?.trim() || "",
};
