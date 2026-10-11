# A website that is only the front door

The phone is the product. The website is the public explanation: what Memory Book is, a short journal, and the pages a store listing has to link to. Privacy, terms, and support are real routes. The You tab opens them in the browser. They are not placeholders inside the app.

The site is a Next.js app in `apps/web`. It ships on Vercel as its own project, under its own name. A push to `dev` runs a GitHub Action that deploys that directory with `vercel deploy --name memory-book`. The action unsets `VERCEL_PROJECT_ID` before it deploys.

That unset is the whole lesson. Vercel will attach a folder named `apps/web` to an existing project when an organization already has one and the CLI is told to say yes. Two products then share a deployment, and one of them loses its public URL. Memory Book’s site is a separate project. Its token and, if needed, its team id live in this repository’s secrets. Another product’s project id must not.

## What the site is allowed to know

The marketing pages do not read the photo library, the credit ledger, or Cognito. Store buttons appear when the App Store and Play URLs are set as public environment variables. Until those exist, the site still explains the product.

Account pages, if they ever exist on the web, would be a different app. Hosted UI for Apple and Google already assumes a phone callback, `memorybook://auth`. A website login would register its own callback on the same Cognito client or on a second client. That is not this site.

## Why it still belongs in the architecture

App Review and Play review follow the privacy and support links. If those links 404, the binary is not done. The site is therefore part of the release, even though no album is stored there. The essay you are reading can be published from the journal route without becoming a backend.

The operational notes for the API and the pool stay in the backend document. This page is the boundary: the website publishes words. The phone keeps the pictures.

## Diagram

```
  GitHub  dev branch
        |
        |  .github/workflows/web.yml
        |  unset VERCEL_PROJECT_ID
        |  vercel deploy --prod --yes --name memory-book
        v
  Vercel project "memory-book"
        |
        +-- /                what the product is
        +-- /privacy         You tab
        +-- /terms           You tab
        +-- /support         You tab
        +-- /features
        +-- /blog

  Phone --url_launcher--> those three URLs
  Phone does not send photos, tokens, or credits.

  A second product's VERCEL_PROJECT_ID must not be set.
  Same folder name "apps/web" plus --yes would attach to it.
```

## Libraries

| Library | Role |
| --- | --- |
| [Next.js](https://nextjs.org/) | App router, `apps/web` |
| [Vercel](https://vercel.com/) | Hosting. One project for this site |
| [url_launcher](https://pub.dev/packages/url_launcher) | You tab opens privacy, terms, and support |

## Source

The workflow is `.github/workflows/web.yml`. The line that keeps this site off another project:

```bash
unset VERCEL_PROJECT_ID
vercel deploy --prod --yes --name memory-book --token "$VERCEL_TOKEN"
```

Pages live under `apps/web/src/app/`. The phone builds the links from `AppConfig.siteUrl` in `memory_book/lib/features/settings/settings_screen.dart`.
