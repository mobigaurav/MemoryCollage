import type { Metadata } from "next";

import { SiteFooter, SiteHeader } from "@/components/SiteChrome";

export const metadata: Metadata = { title: "Terms" };

export default function TermsPage() {
  return (
    <>
      <SiteHeader />
      <main className="wrap page">
        <h1>Terms</h1>
        <p>
          Memory Book is a photo book, collage, and film tool. You keep the rights to your
          pictures. We need a license only to show a picture back to you, print it when you ask,
          or send one confirmed photo to a video service for a credit.
        </p>
        <p>
          Premium and credit packs are sold by Apple or Google. Cloud video can fail; when it
          does, the credit returns and the phone can film the photo instead. The app is not a
          print-and-mail service. Printing uses the printer you already have.
        </p>
      </main>
      <SiteFooter />
    </>
  );
}
