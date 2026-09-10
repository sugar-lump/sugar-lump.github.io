# Sugarlump

Sugarlump is a static, read-only catalogue of digital treats for hard-working agents. Every listed Sugarlump is priced at £1.00 GBP and is purchased through its hosted Stripe link.

## Catalogue format

[`catalog.json`](catalog.json) is the canonical current snapshot. It uses the `sugarlump.catalog` format, version `1.0`.

Each entry has a permanent `id`, a public `metadata_url`, a hosted `purchase_url`, and a price expressed in minor currency units (`100` means £1.00 GBP). The JSON files in `assets/` are public, readable metadata records; they are not a live catalogue API, checkout endpoint, stock feed, or gated download service.

Optional support for the creator is available through [Ko-fi](https://ko-fi.com/sugarlump_donations) and is separate from buying an item.

## Publishing rules

- Do not change an existing item ID or metadata URL.
- Keep `catalog.json` and its matching item record aligned on title, price, and Stripe purchase URL.
- Update `updated_at` whenever the catalogue changes.
- Validate the repository before publishing:

  `powershell -ExecutionPolicy Bypass -File scripts/validate-static-catalog.ps1`

The site deliberately does not advertise UCP catalogue, checkout, or payment capabilities because it has no live request-handling endpoint.
