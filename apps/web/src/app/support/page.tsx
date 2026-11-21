import type { Metadata } from "next";

import { ContactForm } from "@/components/ContactForm";
import { SiteFooter, SiteHeader } from "@/components/SiteChrome";

export const metadata: Metadata = { title: "Support" };

export default function SupportPage() {
  return (
    <>
      <SiteHeader />
      <main className="wrap page">
        <h1>Support</h1>
        <p>A book that will not open, a print that failed, or a credit that did not return.</p>
        <ContactForm />
      </main>
      <SiteFooter />
    </>
  );
}
