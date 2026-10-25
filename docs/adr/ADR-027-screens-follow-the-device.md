# ADR-027: Screens follow the device: dark colours, folding controls, relative sizes

- Status: Accepted (2026-10-25)
- Covers: the lead's requests of 2026-10-25 (DEVLOG entries 41 and 42)
- Amends: ADR-022 (Collect kept a fixed 1280 px width on large monitors)

## Context

On a phone the map was covered by the path chips, the move and zoom pad, the latest issue and the list. The lead asked for:

- controls that fold and open on a tap;
- much smaller text and icons on small screens;
- the same folding on every device, so the map always has the whole screen;
- sizes that follow the detected screen, not fixed pixel caps;
- better colours in dark mode, which looked almost black and white.

Dark mode was generated from the brand blue at the highest contrast level. That suits the light theme in sunlight, but in dark mode it removed nearly all colour: selected tabs, toggles and warnings turned pale grey or white.

The lead chose to keep the map itself light in both themes.

## Decision

1. **Phone density** (`PhoneDensity`, below 600 px):
   - text at 84 % of its usual size, never below 10.5 pt;
   - 20 px icons, a 44 px app bar and a 56 px bottom bar with small labels;
   - dense fields, chips, segmented buttons, list rows and floating buttons;
   - touch targets stay at least 40 px.
2. **Folding on every screen.** These start folded on phones, tablets and computers, and open and fold on a tap:
   - the map path (`MapPathBar`: the last step and "+N");
   - the move and zoom pad (`MapNavigationButtons`: one button);
   - the Console's latest issue (a one-line strip);
   - Collect's list:
     - narrow screens: a sheet that peeks at the bottom; tap its handle or drag it;
     - wide screens: a side panel, 30 % of the width, opened from a button on the map.
3. **Relative sizes.** `screenShare` and `RelativeWidth` in the UI kit give a share of the screen's width for phones, tablets and computers. They replace fixed limits:
   - app shells: 1280 px in Collect, 1440 px in the Console;
   - sign-in, the legal pages, messages, error pages, the PIN pad and reference data;
   - the map search box and its suggestions;
   - the area suggestions in Collect;
   - the dashboard filters.
   Breakpoints, where the layout changes, stay as widths.
4. **Dark colours.**
   - The dark scheme uses standard contrast, with hand-set deep-navy surfaces and blue for what is chosen (tabs, toggles, chips).
   - Warning icons use the status colours tuned for each theme, not the scheme's error colour.
   - The round logo gets a ring on dark backgrounds.
   - The light theme keeps the highest contrast, for sunlight.
   - The map stays light in both themes.

## Consequences

- Computer users open the path, the pad and Collect's list when they need them; each control remembers its state only while the page is open.
- Very wide monitors now use most of their width. Text pages keep a readable share, not a fixed width.
- Screenshots in dark mode were checked by hand; there is no automatic colour-contrast test yet.
