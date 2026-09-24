import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";

import { SiteFooter, SiteHeader } from "@/components/SiteChrome";
import { BLOG_POSTS, getPost } from "@/content/blog";

export function generateStaticParams() {
  return BLOG_POSTS.map((post) => ({ slug: post.slug }));
}

export function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> {
  return params.then(({ slug }) => {
    const post = getPost(slug);
    return { title: post?.title ?? "Journal" };
  });
}

export default async function PostPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const post = getPost(slug);
  if (!post) notFound();
  return (
    <>
      <SiteHeader />
      <main className="wrap page">
        <p className="meta">{post.date}</p>
        <h1>{post.title}</h1>
        {post.sections.map((section) => (
          <section key={section.heading ?? section.body.slice(0, 24)}>
            {section.heading ? <h2>{section.heading}</h2> : null}
            <p>{section.body}</p>
          </section>
        ))}
        <p>
          <Link href="/blog">All notes</Link>
        </p>
      </main>
      <SiteFooter />
    </>
  );
}
