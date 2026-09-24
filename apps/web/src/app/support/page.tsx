import type { Metadata } from "next";

import { SiteFooter, SiteHeader } from "@/components/SiteChrome";
import { site } from "@/lib/site";

export const metadata: Metadata = { title: "Support" };

export default function SupportPage() {
  return (
    <>
      <SiteHeader />
      <main className="wrap page">
        <h1>Support</h1>
        <p>
          Write to <a href={`mailto:${site.supportEmail}`}>{site.supportEmail}</a> for a book that
          will not open, a print that failed, or a credit that did not return.
        </p>
        <p>
          The iOS app updates the existing Memory Collage listing. Android will be a new Play
          listing under the same name.
        </p>
      </main>
      <SiteFooter />
    </>
  );
}
