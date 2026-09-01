---
name: supabase-storage
description: 'Uses Supabase Storage — buckets, uploading/downloading files, access policies, and signed URLs. Use when storing user files/images/documents in a Supabase app, configuring bucket security, or generating temporary download links.'
---

# Supabase Storage

Object storage for files (images, documents, media), backed by the same auth + policy model as the DB.

## Buckets

- Create a bucket per purpose (e.g. `avatars`, `documents`). **Private by default** — make a bucket
  public only when its contents are truly public.
- Set file size limits and allowed MIME types on the bucket where supported.
- Manage bucket creation/policies via migrations/SQL where possible so it's reproducible.

## Access control (policies)

Storage objects are rows in `storage.objects` and are governed by **RLS policies**, just like tables.
Scope access to the owner/tenant, typically using a path convention like `<user_id>/<file>`:

```sql
-- Users can read their own files in the "documents" bucket
create policy "read own documents" on storage.objects
  for select to authenticated
  using (bucket_id = 'documents' and (storage.foldername(name))[1] = auth.uid()::text);

-- Users can upload into their own folder
create policy "upload own documents" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'documents' and (storage.foldername(name))[1] = auth.uid()::text);
```

## Upload / download

- **Clients** upload with the SDK using the **anon** key + the user's session (policies enforce access):
  `supabase.storage.from('documents').upload(path, file)`.
- **Public buckets:** `getPublicUrl(path)` for a stable URL.
- **Private buckets:** generate a **signed URL** with a short expiry for temporary access:
  `createSignedUrl(path, expiresInSeconds)`. Don't hand out long-lived links.
- Large files: upload directly to Storage (resumable where supported) — don't route big blobs through
  your API or store them in the database.

## Per-framework notes

- **Angular/Flutter:** wrap storage calls in a Service; never expose `service_role`. Use signed URLs
  for private content shown in the UI.
- **.NET/Python backend:** use the server key to issue signed URLs or manage lifecycle; enforce your
  own authorization before doing so.

## Rules

- Private buckets by default; access via policies or short-lived signed URLs.
- Validate file type/size on upload; store metadata (owner, tenant) so policies can authorize.
- Keep the path/owner convention consistent so RLS policies stay simple.
