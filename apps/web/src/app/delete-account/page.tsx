import type { Metadata } from "next";

import { SiteFooter, SiteHeader } from "@/components/SiteChrome";

export const metadata: Metadata = { title: "Delete your Memory Book account" };

export default function DeleteAccountPage() {
  return (
    <>
      <SiteHeader />
      <main className="wrap page">
        <h1>Delete your Memory Book account</h1>
        <p>
          Memory Book lets you delete the account from the app. The deletion runs when you
          confirm it. There is no waiting period.
        </p>
        <h2>Steps</h2>
        <ol>
          <li>Open Memory Book and sign in.</li>
          <li>Open You.</li>
          <li>Tap Delete account.</li>
          <li>Tap Delete to confirm.</li>
        </ol>
        <h2>What is deleted</h2>
        <ul>
          <li>The Memory Book account and the email stored with it.</li>
          <li>Books and reels saved to that account.</li>
          <li>Family books you own, and the photos stored for those books.</li>
          <li>The AI credit balance on the account.</li>
        </ul>
        <h2>What is kept</h2>
        <ul>
          <li>
            Books, collages, and photos that live only on the phone. Delete those in the app, or
            delete the app, to remove them from the device.
          </li>
          <li>
            A post you already shared to World. Open that post and delete it before you delete
            the account. Account deletion does not take a World post down.
          </li>
          <li>
            A Premium subscription. Cancel it in the App Store or Google Play. Deleting the
            account does not cancel the store subscription.
          </li>
        </ul>
        <p>
          You can delete one book on the phone, or one World post, without deleting the account.
          There is no separate control that erases the cloud shelf and leaves the account in
          place.
        </p>
      </main>
      <SiteFooter />
    </>
  );
}
