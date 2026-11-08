import type { Metadata } from "next";

import { SiteFooter, SiteHeader } from "@/components/SiteChrome";

export const metadata: Metadata = { title: "About" };

export default function AboutPage() {
  return (
    <>
      <SiteHeader />
      <main className="wrap page">
        <h1>About Memory Book</h1>
        <p>A shelf for the photos you actually want to keep.</p>
        <div className="cards">
          <div className="card">
            <h3>A book, then a film</h3>
            <p>
              Memory Book turns the pictures you pick into a photo book, a collage, or a short
              reel. The page stays paper. The film stays short.
            </p>
          </div>
          <div className="card">
            <h3>On the phone first</h3>
            <p>
              Books and reels are made on the device. Sign in when you want them to come back
              after a new install, or when a family shares one collage.
            </p>
          </div>
        </div>
      </main>
      <SiteFooter />
    </>
  );
}
