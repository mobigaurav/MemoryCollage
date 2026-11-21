import type { Metadata } from "next";

import { ContactForm } from "@/components/ContactForm";
import { SiteFooter, SiteHeader } from "@/components/SiteChrome";

export const metadata: Metadata = { title: "Contact" };

export default function ContactPage() {
  return (
    <>
      <SiteHeader />
      <main className="wrap page">
        <h1>Contact</h1>
        <p>A book that will not open, a print that failed, or a question about the account.</p>
        <ContactForm />
      </main>
      <SiteFooter />
    </>
  );
}
