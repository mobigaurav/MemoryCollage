import type { Metadata } from "next";

import { SiteFooter, SiteHeader } from "@/components/SiteChrome";

export const metadata: Metadata = { title: "Features" };

const features = [
  ["Books", "Start blank, or from a family, trip, wedding, baby, or sticky-note cover. You choose every photo."],
  ["Page turns", "Swipe the spread. Pinch a photo to zoom in, or pinch together until the whole picture fits the frame."],
  ["Collage", "Browse layouts by shelf. Resize a cell, change the paper, add a sticker, then save or share."],
  ["Print", "Print the open spread or the whole book through the printer already on your phone."],
  ["On your phone", "Enhance and a Ken Burns film stay on the device with Premium."],
  ["One credit", "Bring a chosen photo to life in the cloud. If that service is offline, the phone makes the film and the credit returns."],
];

export default function FeaturesPage() {
  return (
    <>
      <SiteHeader />
      <main className="wrap page">
        <h1>What the app does</h1>
        <p>The phone is the product. An account is for credits and the clip you asked for.</p>
        <div className="cards">
          {features.map(([title, body]) => (
            <article key={title} className="card">
              <h3>{title}</h3>
              <p>{body}</p>
            </article>
          ))}
        </div>
      </main>
      <SiteFooter />
    </>
  );
}
