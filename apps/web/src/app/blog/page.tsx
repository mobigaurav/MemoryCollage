import type { Metadata } from "next";
import Link from "next/link";

import { SiteFooter, SiteHeader } from "@/components/SiteChrome";
import { BLOG_POSTS } from "@/content/blog";

export const metadata: Metadata = { title: "Journal" };

export default function BlogPage() {
  return (
    <>
      <SiteHeader />
      <main className="wrap page">
        <h1>Journal</h1>
        <div className="posts">
          {BLOG_POSTS.map((post) => (
            <Link key={post.slug} href={`/blog/${post.slug}`} className="post">
              <span className="meta">{post.date}</span>
              <strong>{post.title}</strong>
              <span>{post.excerpt}</span>
            </Link>
          ))}
        </div>
      </main>
      <SiteFooter />
    </>
  );
}
