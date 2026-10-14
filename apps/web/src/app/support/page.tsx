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
        <p>A book that will not open, a print that failed, or a credit that did not return.</p>
        <div className="cards">
          <div className="card">
            <h3>How to reach us</h3>
            <p>
              Email <a href={`mailto:${site.supportEmail}`}>{site.supportEmail}</a>. That is the
              Memory Book support address.
            </p>
            <p>We typically respond within 24–48 hours.</p>
          </div>
        </div>
      </main>
      <SiteFooter />
    </>
  );
}
