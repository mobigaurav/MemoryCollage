import Link from "next/link";

import { SiteFooter, SiteHeader, StoreLinks } from "@/components/SiteChrome";
import { latestPosts } from "@/content/blog";

export default function HomePage() {
  const posts = latestPosts(2);
  return (
    <>
      <SiteHeader />
      <main className="wrap">
        <section className="hero">
          <h1>Open your photos like an album.</h1>
          <p className="lede">
            Memory Book is a shelf of photo books, a collage studio, and a short film of the
            pictures you pick. Print a spread. Bring one photo to life when you ask.
          </p>
          <StoreLinks />
        </section>
        <section className="section">
          <h2>Made to be held</h2>
          <div className="cards">
            <article className="card">
              <h3>A book, not a feed</h3>
              <p>Covers, page turns, and empty frames you fill yourself.</p>
            </article>
            <article className="card">
              <h3>Collage shelves</h3>
              <p>Grids, stories, scrapbook, social sizes, shapes, and freeform.</p>
            </article>
            <article className="card">
              <h3>Print and film</h3>
              <p>Send a page to your printer, or share a reel from the same book.</p>
            </article>
          </div>
        </section>
        <section className="section">
          <h2>From the journal</h2>
          <div className="posts">
            {posts.map((post) => (
              <Link key={post.slug} href={`/blog/${post.slug}`} className="post">
                <strong>{post.title}</strong>
                <span>{post.excerpt}</span>
              </Link>
            ))}
          </div>
        </section>
      </main>
      <SiteFooter />
    </>
  );
}
