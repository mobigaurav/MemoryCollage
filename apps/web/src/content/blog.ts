export type BlogPost = {
  slug: string;
  title: string;
  date: string;
  excerpt: string;
  sections: { heading?: string; body: string }[];
};

export const BLOG_POSTS: BlogPost[] = [
  {
    slug: "open-your-photos-like-an-album",
    title: "Open your photos like an album",
    date: "2026-09-24",
    excerpt:
      "Memory Book starts as a shelf of books. A collage and a short film come after the page, not instead of it.",
    sections: [
      {
        body: "Most camera rolls are a grid that never ends. A book gives the same pictures a cover, a sequence, and a place to stop. Memory Book is built around that: you choose the photos, turn the page, and the shelf remembers the book.",
      },
      {
        heading: "The book comes first",
        body: "Blank, family, trip, wedding, baby, and sticky-note books are starting points. Nothing is pulled in from the last week of your camera roll unless you pick those pictures yourself.",
      },
      {
        heading: "Collage and film sit beside it",
        body: "The studio has grids, stories, scrapbook layouts, social frames, and freeform. A reel is a flip through the book or a film of one photo. The page is still the thing you come back to.",
      },
    ],
  },
  {
    slug: "ai-belongs-on-a-photo-you-chose",
    title: "AI belongs on a photo you chose",
    date: "2026-09-24",
    excerpt:
      "Enhance and bring-to-life run on one picture, after you ask. The rest of the library stays on the phone.",
    sections: [
      {
        body: "A photo book should not upload the camera roll so a model can browse it. Memory Book keeps albums on the device. The cloud is used when you pick one photo, confirm that it can leave, and spend a credit to make a short clip.",
      },
      {
        heading: "What stays here",
        body: "Page turns, collage layouts, print, and the on-phone film do not need an account. Premium enhance is done on the device.",
      },
      {
        heading: "What a credit is for",
        body: "One credit asks our server to send that single picture to a video model and return a clip. If that service is down, the credit comes back and the phone films the photo instead. We do not use those pictures to train a model.",
      },
    ],
  },
];

export function getPost(slug: string): BlogPost | undefined {
  return BLOG_POSTS.find((post) => post.slug === slug);
}

export function latestPosts(count: number): BlogPost[] {
  return [...BLOG_POSTS].sort((a, b) => b.date.localeCompare(a.date)).slice(0, count);
}
