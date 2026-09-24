import type { Metadata } from "next";

import { SiteFooter, SiteHeader } from "@/components/SiteChrome";

export const metadata: Metadata = { title: "Privacy" };

export default function PrivacyPage() {
  return (
    <>
      <SiteHeader />
      <main className="wrap page">
        <h1>Privacy</h1>
        <p>
          Albums, collages, and the photo library stay on your phone. Memory Book does not require
          an account to make a book, and it does not read your camera roll in the background.
        </p>
        <p>
          A photo leaves the device in three cases: you save or share it, you print it, or you
          confirm a credit and send that one picture to make a short clip. That clip is not used
          to train a model. The credit is stored with your account so a reinstall cannot invent a
          new balance.
        </p>
        <p>
          Sign-in uses Memory Book’s own account system. We store the email you register and the
          credit ledger. We do not sell either.
        </p>
      </main>
      <SiteFooter />
    </>
  );
}
