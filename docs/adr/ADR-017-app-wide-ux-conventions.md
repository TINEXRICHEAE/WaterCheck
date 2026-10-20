# ADR-017: App-wide UX conventions

- Status: Accepted (2026-10-13)
- Asked for by: the lead, 2026-10-13 ("general inclusions")
- Covers: both apps (Collect, Console) and the shared `ui_kit`

## Context

The apps had grown phase by phase, and each screen handled navigation, errors, loading and settings in its own way:
- Some pages had no way back.
- Some errors printed the raw exception.
- The app images were Flutter's defaults.
- Theme and time zone were not configurable.

The lead asked for these to be consistent everywhere.

## Decision

### 1. Shared building blocks (`packages/ui_kit`)

| Piece | Use |
|-------|-----|
| `AppLogo`, `AppBrand` | The WaterCheck icon (design/watercheck-icons) wherever the app shows its own image: sign-in, welcome, activation, title bar, About, PDF report and notice |
| `PasswordField` | Every password box, with a show/hide eye button (hidden by default) |
| `BusyButton`, `BusyLabel` | Buttons that wait on a request show a small spinner and ignore a second tap |
| `ErrorView`, `errorKindOf` | Safe error pages and panels: no connection, too slow, signed out, not allowed, not found, server problem, unknown. Each says what to do and has Try again and, for whole pages, Go to the start page. The raw exception only goes to the debug log. |
| `PageLoading` | Whole-page loading |
| `SearchField`, `ResetFiltersButton` | Searches clear with ×; "Reset filters" appears when any filter differs from its default |
| `AppearanceSettings`, `ThemeChoice`, `TimeZoneChoice`, `WcTime`, `TimeZoneScope` | Theme and time zone (below) |
| `confirmAction`, `showWaterCheckAbout` | Confirmation before destructive actions; About with version and licences |

### 2. Theme and time zone, per user

- **Theme:** System, Light or Dark.
- **Time zone:**
  - **East Africa Time, Kampala (UTC+3)** is the default;
  - also Nairobi (UTC+3), Automatic (the device's zone) and UTC.

  EAT has no daylight saving, so a fixed offset is exact. Times stay stored in UTC; only display changes.
- **Console:** the setting is saved with the account (`app_user.theme`, `time_zone`; migration 0008; `PUT /v1/me/appearance`), so it follows the person to any device. It applies on the device at once, even offline.
- **Collect:** collectors are not server accounts, so it is saved on the phone per collector. The last choice also applies before anyone is chosen.
- **Implementation:** all displayed times go through `WcTime.local`, including PDFs and the trend chart. Date filters convert back with `WcTime.toUtc`.

### 3. Navigation

- **Console:** every page below a section's first page (a source, an alert, Profile, each Admin page) has a back button in the title bar. It goes to the page above.
- **Collect:** pages open on top of each other, so they already had back. Reset now opens on top of Settings, so it has back too. The result page has ×, which goes home: going back would reopen the finished form.
- **Unknown addresses:** both apps show a "Page not found" page with a way home.

### 4. Loading

- **Near the button:** buttons show their own spinner (sign-in, password change, saves, exports, reviews, stakeholder approval in Collect, "Nearest" in Collect).
- **Console, top of the window:** a thin bar shows while any change is being sent to the server, including actions started from a dialog. Background sync does not show it.
- **Page loads:** a spinner or bar only where a page waits on the server (the admin pages). Pages read from the device and open at once.

### 5. Filters

- **Dashboard, Sources, Collectors, Reports:** area, period and limit set have "All…" choices and a Reset filters button.
- **Sources:** search with ×, status "All", reset.
- **Alerts:** Open | All.
- **Audit log:** action, dates, reset.
- **People:** search with ×.
- **Collect:** "Which source?" gets a search box.

### 6. Other conventions added

- **App names and icons:** "WaterCheck Collect" and "WaterCheck Console" for the Android launcher (adaptive icon on navy), the Windows window and executable, the web tab title, the favicon and the installable-app manifest.
- **About:** About WaterCheck in the Console account menu and in Collect Settings, with version and open-source licences.
- **Sign out:** the Console asks before signing out while changes are still waiting to be sent.
- **Confirmation:** rejecting a field parameter asks first.
- **Collect home:** pull down to sync now.

## Amendment (2026-10-20): "today" in the chosen zone

`WcTime.local` returns a wall-clock time in the chosen zone. Comparing it with
the device's `DateTime.now()` is wrong whenever the device's zone differs. On
a UTC computer between 21:00 and 24:00, a Kampala time is already tomorrow,
so a calibration made minutes earlier did not count as "today" (CI failure,
2026-10-20). `WcTime.isToday` converts both sides, and all date-only
comparisons use it. Regression test: `packages/ui_kit/test/conventions_test.dart`.

## Consequences

- New screens use these pieces. A raw `Text('$e')` or a bare `obscureText: true` is a review finding.
- Android themed (monochrome) icons are not provided: the icon is full colour. A monochrome version can come with the release work (P12).
- In the Console on the web, the theme before sign-in follows the device. After sign-in it follows the account.
