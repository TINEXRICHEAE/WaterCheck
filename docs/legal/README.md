# Privacy Policy and Terms of Use

The texts the apps show live in `packages/ui_kit/assets/legal/` (one copy, bundled with both apps). Each side of FieldQuire has its own (ADR-031), and a short general text introduces the platform:

- [fieldquire.md](../../packages/ui_kit/assets/legal/fieldquire.md): about FieldQuire and its sides, with what is the same everywhere;
- water testing: [water-privacy.md](../../packages/ui_kit/assets/legal/water-privacy.md) and [water-terms.md](../../packages/ui_kit/assets/legal/water-terms.md);
- research: [research-privacy.md](../../packages/ui_kit/assets/legal/research-privacy.md) and [research-terms.md](../../packages/ui_kit/assets/legal/research-terms.md).

People accept their side's two documents with the usual ticks when they sign up (Console accounts and Collect profiles alike). When a side's documents change in substance, raise its version in `legalVersions` (`packages/domain/lib/src/sides.dart`) and in `LEGAL_VERSIONS` (`backend/app/core/sides.py`): people on that side are then asked once, at their next sign-in in the Console or when their profile is next chosen in Collect.

Fill in the parts in [square brackets] and confirm all of them with the PDPO before real data is collected (ADR-026).
