# Member 1 — Team Lead & Integration

## Assignment
You are the team lead. Own integration, access/security conventions, release review, README, and merging.

## Primary files
app/bootstrap.php; scripts/create-manager.php; README.md; docs/team-work-split.md. Review shared public/index.php changes from all members. Coordinate any shared CSS or schema changes.

## Working agreement
- Start from the same agreed base commit and create a feature branch: `01-team-lead-integration`.
- Make focused changes for your assigned workflows and open a pull request; do not push directly to `main`.
- The current MVP is implemented in this baseline. Your work is to own, review, and make focused improvements to this area.
- `public/index.php` contains multiple modules in one shared file. Keep changes limited to your module's handlers/rendering and coordinate overlapping edits with the team lead.
- Keep `.env`, passwords, and private credentials out of commits. This pack omits the local `.env`; copy `.env.example` to `.env` and enter your own local settings.
- Include a concise PR summary, manual checks, and screenshots for visible UI changes.

## Repository context
The full application snapshot is included for context. Refer to `docs/team-work-split.md` for the complete five-member ownership map and presentation sequence.
