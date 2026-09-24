import Link from "next/link";

import { site } from "@/lib/site";

export function SiteHeader() {
  return (
    <header className="wrap site-header">
      <Link href="/" className="wordmark">
        Memory Book
      </Link>
      <nav className="nav">
        <Link href="/features">Features</Link>
        <Link href="/blog">Blog</Link>
        <Link href="/support">Support</Link>
      </nav>
    </header>
  );
}

export function SiteFooter() {
  return (
    <footer className="wrap site-footer">
      <span>Photos stay on your phone until you choose otherwise.</span>
      <nav className="nav">
        <Link href="/privacy">Privacy</Link>
        <Link href="/terms">Terms</Link>
        <a href={`mailto:${site.supportEmail}`}>Email</a>
      </nav>
    </footer>
  );
}

export function StoreLinks() {
  return (
    <div className="actions">
      {site.appStoreUrl ? (
        <a className="button" href={site.appStoreUrl}>
          App Store
        </a>
      ) : (
        <span className="button">iOS update coming on the existing listing</span>
      )}
      {site.playStoreUrl ? (
        <a className="button-quiet" href={site.playStoreUrl}>
          Google Play
        </a>
      ) : (
        <Link className="button-quiet" href="/features">
          See the book
        </Link>
      )}
    </div>
  );
}
