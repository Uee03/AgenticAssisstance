---
name: project-licensing
description: 'Chooses and adds a software license — open source (MIT, Apache-2.0, GPL-3.0, LGPL-3.0) or closed/commercial (proprietary) — and wires the LICENSE file plus package metadata. Use at project start, when the user asks about licensing, or when deciding whether a project is open source or closed source.'
---

# Project Licensing

**Best model:** Quick tier (GPT-6 Luna) via Quick Helper.

Add a license at project start. **Ask first — don't assume MIT.**

## Step 1 — ask: open source or closed/commercial?

> "Is this project **open source** (others may use/modify/redistribute under a license) or
> **closed source / commercial** (proprietary, all rights reserved)?"

## Step 2a — open source: recommend one (use the latest version)

Use the SPDX identifier and add the **verbatim** license text (see Step 3).

| License (SPDX) | Type | Recommend when |
|----------------|------|----------------|
| **MIT** | Permissive | Default for most apps/libraries — simple, maximal adoption, attribution only. |
| **Apache-2.0** | Permissive + patent grant | Same freedom as MIT but with an explicit patent grant — prefer for larger/company/enterprise projects or anything patent-sensitive. |
| **GPL-3.0-or-later** | Strong copyleft | You want derivatives/redistributions of the **whole app** to stay open source. |
| **LGPL-3.0-or-later** | Weak copyleft | A **library** you want to keep open, while allowing proprietary apps to link to it. |

Quick guide: **broad adoption →** MIT; **patent safety →** Apache-2.0; **keep the app open →** GPL-3.0;
**keep a library open but linkable →** LGPL-3.0. (BSD-3-Clause and MPL-2.0 are fine alternatives if the
user asks.) A GPL app may use LGPL libraries — that combination is compatible.

## Step 2b — closed source / commercial: proprietary

- No OSI license. Add a `LICENSE` (or `LICENSE.txt`) stating **"Copyright (c) <year> <holder>. All
  rights reserved."** plus any usage terms, or reference a separate EULA/commercial agreement.
- Keep the repository **private**. Set package metadata license to a proprietary marker.

## Step 3 — add the LICENSE file (do not fabricate legal text)

- Put a `LICENSE` file at the repo root containing the **exact, verbatim** text for the chosen license.
  For open-source licenses copy it from an authoritative source (choosealicense.com / spdx.org / the
  FSF) — **never hand-write, summarize, or alter** license wording. Fill only the copyright line
  (year + holder). `.NET`: `dotnet` doesn't generate one; add the file. GitHub's "Add file → license"
  also inserts the canonical text.
- **GPL/LGPL** ship as two files: `COPYING` (GPLv3) and, for LGPL, `COPYING.LESSER` (LGPLv3), plus a
  short per-file header if the license recommends it.

## Step 4 — set package metadata to match

- **.NET:** `Directory.Build.props` → `<PackageLicenseExpression>MIT</PackageLicenseExpression>`
  (or `Apache-2.0`, `GPL-3.0-or-later`, `LGPL-3.0-or-later`); for proprietary use `<PackageLicenseFile>`.
- **Python:** `pyproject.toml` → `license = "MIT"` (SPDX) or `license-files`.
- **Node/Angular:** `package.json` → `"license": "MIT"` (or `"UNLICENSED"` + `"private": true` for closed).
- **Flutter/Dart:** set `pubspec.yaml` metadata; a published package needs a permissive license.

## Step 5 — record it

State the license in `README.md` and confirm the **copyright holder + year**. Keep third-party
attributions (e.g. `CREDITS.md`) if dependencies require notices.
