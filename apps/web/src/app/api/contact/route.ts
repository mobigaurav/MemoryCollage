import { NextResponse } from "next/server";

function clean(value: unknown, max: number) {
  return String(value ?? "")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, max);
}

function configured() {
  const to = process.env.CONTACT_TO?.trim() ?? "";
  const from = process.env.CONTACT_FROM?.trim() ?? "";
  const key = process.env.RESEND_API_KEY?.trim() ?? "";
  if (!to || !from || !key) return null;
  return { to, from, key };
}

export async function POST(request: Request) {
  let body: Record<string, unknown>;
  try {
    body = (await request.json()) as Record<string, unknown>;
  } catch {
    return NextResponse.json({ ok: false }, { status: 400 });
  }

  if (clean(body.company, 200)) {
    return NextResponse.json({ ok: true });
  }

  const name = clean(body.name, 80);
  const email = clean(body.email, 120);
  const subject = clean(body.subject, 140);
  const message = String(body.message ?? "").trim().slice(0, 4000);

  if (!name || !subject || message.length < 5) {
    return NextResponse.json({ ok: false }, { status: 400 });
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return NextResponse.json({ ok: false }, { status: 400 });
  }

  const mail = configured();
  if (!mail) {
    console.error("contact form mail is not configured");
    return NextResponse.json({ ok: false }, { status: 503 });
  }

  const sent = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${mail.key}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: mail.from,
      to: [mail.to],
      reply_to: email,
      subject: `Memory Book: ${subject}`,
      text: `Name: ${name}\nReply to: ${email}\n\n${message}`,
    }),
  });

  if (!sent.ok) {
    console.error("contact form send failed", sent.status);
    return NextResponse.json({ ok: false }, { status: 502 });
  }

  return NextResponse.json({ ok: true });
}
