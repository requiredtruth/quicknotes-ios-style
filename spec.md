# QuickNotes 1.7.0

## New views and widget selection

Completed shows every nondeleted completed reminder in active lists, regardless of the normal Show Completed preference. Urgent shows urgent reminders across active lists and supports the existing completed toggle. Both cards have counts and participate in smart-list editing/reordering. Existing installations gain the two cards automatically. Both are widget choices; Completed widget rows have no completion circle.

The bottom toolbar has an explicit stacking level above reminder rows and the list has extra bottom space. Dialogs retain their native modal behavior.

Widget configuration uses disabled Built-in Lists and My Lists headings with a divider, icons, and tinted bordered boxes from each list color. The selected row uses a fresh view so labels do not carry over. Saved selection is committed before refresh; the remote adapter URI includes the selected list, theme and completion preference so Android rebinds after a change. Header metadata is resolved from current storage on every refresh.

## Groceries

Create/edit a list and choose Standard or Groceries. On save, startup and sync merge, grocery lists classify common English item names on-device into Produce, Bakery, Meat & Seafood, Dairy & Eggs, Pantry & Grains, Canned & Jarred, Frozen, Snacks & Sweets, Drinks, Baking & Spices, Household, Personal Care or Pet Supplies. Longer matching names take precedence, such as milk chocolate, apple juice and dog food. Unrecognized items remain in Others. Classification is a local dictionary, not a cloud model or complete multilingual product catalog.

Only needed category sections are generated and empty generated sections are hidden. Section IDs are deterministic per list/category to avoid duplicates after sync. Subtasks follow their parent section. Dragging to another section or Others records a manual override; renaming the item resumes classification. Converting an existing list retains custom section placement. Returning to Standard retains reminders and sections without future automatic sorting.

## Transfer from iPhone or another app

Settings → Import copied text / CSV / JSON accepts pasted text or Android's file picker. Files are UTF-8 and limited to 1 MiB / 5,000 reminders. Text is one reminder per line; Markdown or Unicode checkboxes preserve completion. CSV (including tab separated data) has a header and supports quoted commas/newlines/quotes. JSON is an array of reminder objects or an object containing a reminders array. Supported fields include title, notes, due (ISO date/time or Unix timestamp), completed/done, flagged/flag, urgent, list/listName and section/sectionName. Date-only reminders use 09:00 local without Time enabled. Invalid input is rejected before saving.

A review screen shows counts and the first 30 titles; storage changes only after Import. Source list names can create/match destination lists, or a chosen destination overrides names. A default Imported Reminders list is reused. Stable record fingerprints skip the same imported records in the same destination while preserving intentional repeated lines in one file. Existing content is merged, never cleared. Imported source sections are preserved. Recurrence, photos, nested relationships and sharing permissions are not transferred. This feature does not connect to iCloud or read Apple credentials; users supply copied text or a compatible export from their source workflow.

## Validation and release

23 model tests cover smart filtering, phrase classification, unknowns, manual overrides, subtasks, deterministic section identity, conversion, CSV/JSON/text parsing, dates, preview immutability and repeat-import protection alongside existing regression coverage. Playwright covers the new cards, grocery creation/sections, floating button hit testing over long lists and import review/commit/error paths. Android 15 instrumentation covers native widget filters, picker headings/labels/colors, adapter identity and actual RemoteViews header updates alongside the existing alarm/completion tests. CI gates publication on all suites and verifies the signed APK against source. Version 1.7.0 / versionCode 8 uses the existing signing certificate. APK, source ZIP, spec and checksums accompany the release.

---

# QuickNotes 1.6.0

## Current widget and scheduling behavior

- Completion belongs to each widget configuration: **Complete reminders in this widget**, enabled by default. When off, that widget hides all check circles and its receiver rejects completion taps. When on, every incomplete row can be completed without opening the app. Different widgets can choose different values. Legacy reminder-level `widgetComplete` fields are ignored and no longer shown in the reminder editor. Due sorting/filtering, recurrence and repeated-tap protection are preserved.
- Add List is an outlined square-plus icon, left of More. The Add Reminder plus is centered in the bottom toolbar; Describe remains available beside it.
- Both schedule editors use the app theme and a shared hour/minute/AM–PM picker. A date/time preview and +15/+30 minute, +1/+2/+3/+6/+12 hour and +1 day buttons share that picker. Increments add to the currently selected date/time, so taps accumulate and can cross days/months/years. The entire picker and interval controls hide when Time is disabled. The entire Early Reminders group, including custom amount/unit controls, hides when Date is disabled.
- Custom Repeat selection immediately shows frequency, interval and calendar rule controls in the current editor, preserving unsaved reminder fields. Rules are validated on Save; cancellation discards draft changes. Existing quick-bar custom repeat editing remains available.
- Completed reminders, deleted reminders and descendants of completed reminders cannot be chosen as new parents; cycle checks still apply. Dragging to a completed parent is rejected.

## Alarm display repair

The foreground alarm now uses one audible IMPORTANCE_HIGH alarm channel (`ringing-alarms-v2`) with ALARM audio attributes, public lock-screen visibility and only-alert-once updates. It no longer posts a competing regular alert while ringing. Its activity PendingIntent explicitly opts into Android 15 creator background-start privileges. The alarm activity declares showWhenLocked/turnScreenOn, uses an alarm task and full-screen window, and retains snooze/dismiss/complete controls. Flagged urgent alarms open directly when QuickNotes is already visible, including returning to an ongoing alarm. In the background, Android owns full-screen delivery; while another app is actively in use the system normally shows an expanded high-priority alert. Special full-screen access, notification access, exact alarm access and an enabled high-priority alarm channel must be allowed. The setup flow offers full-screen access after notification/exact alarm access. Permission denial is respected.

On alarm timeout, unfinished flagged reminders retain their due status notification. Completing/deleting/snoozing stops the relevant audio and display. Tests verify actual activity resumption with the device asleep/locked, actual foreground display, early notification followed by the due alarm, screen snooze, and widget-level enable/disable behavior.

## Validation

18 model tests plus Playwright UI regression coverage; Android 15 instrumentation gates release. The APK uses the existing release signing key and versionCode 7. Source, compiled assets, manifest and dex are checked against the published APK. Source ZIP, spec.md and SHA256SUMS accompany the release.

---

# QuickNotes 1.5.0

## Reminder capture, widgets and alert changes

- The top bar keeps an Add List icon immediately left of More on every screen. More → Edit Lists enables list editing. List labels cannot start text selection while dragging.
- Reminder editor includes an opt-in **Complete from widget** switch. Widgets show a separate completion circle only for opted-in reminders. Completing runs entirely in a receiver, updates storage and widgets, cancels alerts, and clones repeating occurrences. Repeated or stale widget actions cannot toggle completed reminders back or complete a newer due date. Row-title taps still open the reminder.
- Widget configuration opens with the current app theme, including spinner popup colors and system bars. Widget appearance defaults to App theme; System/Light/Dark remain selectable.
- HTTPS links display the page's Open Graph primary image, falling back to Twitter image, image_src or the first image if available. A native metadata fetcher follows up to five HTTPS redirects, blocks private addresses, fetches at most 512 KiB HTML and 2 MiB raster data, downsamples to 640px, and caches success for seven days / missing previews for six hours. Up to 100 cache entries are retained. Websites with no accessible image keep a plain URL. No website scripts run in the app. HTTP-only sites retain plain URLs.
- Completing or deleting in the app, widget, sync or notification cancels the corresponding notification, early alert, snooze and active alarm. A due flagged reminder has an ongoing status-bar notification until dismissed/completed/deleted; modern Android may still let users swipe ongoing notifications away. This uses Android notifications rather than privileged system timer UI.
- Urgent notification and alarm-screen actions include **Snooze 5 min**, preserving the reminder's identity and due date. Flagged + urgent reminders request a full-screen alarm. Android decides whether to launch it or show an expanded alert based on full-screen access, lock state and system policy. Urgent alarms require notification and exact alarm access; alarm volume controls audio.
- Home Back does not traverse WebView history. Android back callbacks close overlays, leave inline editing, return a list to home, or background the root task.
- Time editors offer +15/+30 minutes and +1/+2/+3/+6/+12 hours / +1 day from now. They turn on date/time together.
- **Describe Reminder** opens typed English capture or Android's voice-to-text activity. Parsing runs locally with no LLM service: relative times (including word amounts), today/tomorrow, weekdays, ISO dates, named month dates, AM/PM or 24-hour times, daily/weekly/monthly and interval repeats, named lists, flag and urgent. The recognized source and warnings are shown in the normal editable draft. User must explicitly save. Unsupported phrases remain visible for review. Voice recognition availability/offline behavior depends on the phone's recognizer.
- Early reminders add a separate alert without consuming the due alert: None, 5/15/30 minutes, 1/2 hours, 1/2 days, 1 week, 1 calendar month, or custom 1–999 minutes/hours/days/weeks/months. Calendar month offsets clamp at month ends. Exact early scheduling uses existing permission if granted, otherwise Android's inexact delivery; normal due notifications remain subject to Android scheduling. Early alerts never start urgent audio.
- New per-reminder widget and early fields remain in the same version-1 JSON records and use existing timestamp-based sync/backup/recurrence cloning.

## Verification for 1.5.0

Model tests cover parser dates, relative times, repeat rules, unknown lists, regex-sensitive list names and negative flag/urgent wording. Playwright covers parsing review, editor persistence, widget opt-in, quick times, custom early rules, month presets, dictation callback, URL card and root navigation, alongside existing interactions. Android instrumentation covers actual background urgent audio, snooze, recurrence, notification actions/cancellation, calendar month offsets, metadata image selection, receiver completion idempotency/opt-in and early delivery. CI gates release publication on both UI and Android 15 instrumentation jobs. Published APK keeps the previous release's signing certificate and versionCode increments to 6.

---

# QuickNotes Android specification

Version 1.3.0; package `com.quicknotes.app`; versionCode 4; Android 8+ / API 26 minimum; API 35 target.

## Lists, sections and order

Lists save stable IDs, titles, lowercase `#rrggbb` colors, icon strings, timestamps, and order. Thirty original preset icons plus emoji (`emoji:<text>`) are available. Eighteen color presets, native HTML color picker, and validated hex entry preserve the exact color in sync and backup.

`data.sections` is a collection of `{id,list,title,order,updated,deleted?}`. IDs are stable UUIDs; order is an independently saved numeric position rather than encoding position into mutable IDs. Old version-1 bundles without sections migrate to an empty collection. JavaScript and Java merges include sections using the same record-ID/timestamp rule as reminders and lists.

Sections are optional. Add Section asks for its name. Unassigned reminders render in a derived Others section while any active reminder in the list remains unassigned (including hidden completed reminders). Others has no persisted ID and is always last. Dropping a reminder onto a section header or empty area assigns that section and all descendants, clearing the root's subtask parent. Dropping onto a reminder creates a subtask, inheriting its list and section. Cycle checks prevent recursive parenting. Drag sections by long-pressing the header, or use Edit Section → Move Up/Down. Deleting a section moves its reminders into Others. List rows have no hamburger handles; long-press retains drag/reorder. Reminder handles and arrow-key reorder remain.

## Reminders and scheduling

Tap a title/notes to edit inline. Quick bar: Date → Time → Urgent → Repeat → Tags → Flag → Photos. Time/Urgent/Repeat appear when Date is enabled. Date presets: None, Today, Tomorrow, Next Weekend, Next Week, Custom. Custom scheduling presents Date, Time, Urgent, Repeat, Early Reminders. Separate date/time/repeat switches and validation prevent past urgent alarms. Custom recurrence supports intervals, weekdays, month days and ordinal weekdays. Completing a repeating reminder preserves the completed occurrence and creates a new ID with copied descendants/photos; it never silently reopens the original.

Multiple image attachments use Android's document picker and private copied files. Inline and Details previews are square thumbnails; full-screen preview supports close, outside tap, and Back. Native thumbnails are downsampled and EXIF rotation corrected. URL links, notes, priority, tags, subtasks, smart views, Show Completed, and manual/date/priority/title sorting remain available. Home smart cards can be hidden and reordered in Edit mode.

Location options, map editor, native geolocation service, Maps API settings, and all location permissions are removed. Legacy location fields can remain in imported data but are not shown or monitored.

## Deletion and recovery

Swiping left reveals Details, Flag, Delete. A full swipe (72% row width) or a further left swipe on an already open row triggers deletion without another confirmation. Beyond the action width, Delete expands across Details/Flag and follows the reveal distance. A 240-ms fold/collapse occurs before trash marking. Edit/detail deletion still confirms.

Trash sets `deleted=true`, `deletedAt` to the deletion time, and advances `updated`, recursively including descendants. Recently Deleted appears on Home only while recoverable reminders exist, independently of source-list visibility. Restore reactivates the reminder and retained descendants/photos; when its original list is deleted it uses an active list or creates Recovered. Invalid/deleted sections are cleared. A missing/deleted parent is detached. Clear Recently Deleted confirms irreversible clearing. Expiration is exactly 30 × 24 hours after deletion; maintenance runs when the app renders/saves/resumes. Expired and manually cleared content becomes `{id,updated,deleted:true,purged:true,deletedAt}`. Minimal tombstones remain indefinitely to prevent older-device resurrection. Previously referenced files no longer retained by active/recoverable records are removed on native saves. Offline devices and independently exported backups cannot be remotely erased.

## Settings and appearance

Settings is grouped into Appearance, Google account sync, Sync file, Backup, Notifications & alarms. Theme choices System/Light/Dark persist per device and apply to body, outer background, dialogs, WebView, status/navigation bars and native icon contrast. System selection follows the current OS preference. Theme/UI preferences are device-local, whereas list colors/icons and section order sync.

## Sync

Portable format remains version 1 with `lists`, `items`, and `sections`. Per-record last-modified timestamps plus deterministic equal-time serialized-record comparison resolve merges; clock accuracy matters. JSON imports validate IDs, duplicate IDs, colors, priorities, and dates. ZIP paths are restricted to `data.json` and safe `attachments/<id>` entries. Old bundles gain empty sections. Deleted records retain their photos while recoverable; purged records do not reference photos.

Sync-file mode uses Android Storage Access Framework with persistent read/write permission. Install/sign in to Google Drive or another provider; create/select the same QuickNotes ZIP on each device. Reads merge into local data before writes. Provider uploads/cache timing vary and simultaneous document writes can race, so finish one device before switching. Local data remains on errors/disconnect. Before replacing a document, a local recovery ZIP is written. Export and merge-import include all referenced active/recoverable photos.

Google account mode uses Google Play services `AuthorizationClient` 22.0.0, scope `https://www.googleapis.com/auth/drive.appdata`, consent resolution, silent reauthorization after consent, and expired-token cache invalidation. Tokens stay in native memory/Google's token cache, never in WebView or ZIPs. REST uses TLS, timeouts, bounded transfers, and visible failures. A private app-data snapshot named `quicknotes-v1-<installation UUID>.zip` is written per installation. Sync reads/merges all snapshots, merges again against current local data under the storage lock, then updates its own snapshot. Pagination is supported. This avoids simultaneous devices replacing one shared Drive object. Disconnect disables future automatic sync but retains cloud data and consent; Google account permissions can revoke access. Sync runs after saves with a 1.8-second debounce, on return, and via Sync Now; this is not guaranteed continuous background or real-time collaborative sync. Google Play services is required for account mode; the Drive app itself is not.

Limits: 20 MiB per image, 100 MiB uncompressed bundle, 5 MiB imported manifest, 1,000 Google snapshots and 200 MiB downloaded snapshot bytes per sync. These limits report errors without clearing local reminders.

### Google developer configuration prerequisite

Account-mode code is compiled and included, but no Google Cloud project/client configuration was created and no live sign-in/Drive transfer was verified for this release. Enable Drive API, configure the OAuth consent screen and allowed audience/test users, and register an Android OAuth client for `com.quicknotes.app` with the signed release SHA-1: `CC:E0:47:FC:59:3F:A8:C5:30:2D:7E:8A:63:90:B0:E4:47:9A:C3:17`. Google matches the installed package/certificate; no OAuth client secret is embedded. Existing file sync remains available without this registration. See Google's [Android authorization guide](https://developer.android.com/identity/authorization) and [Drive app-data guide](https://developers.google.com/workspace/drive/api/guides/appdata).

## Native alerts and notification photo metadata

Normal notifications include title/notes, Dismiss, and Mark As Completed. Urgent alarms use exact alarm-clock scheduling, foreground audio, wake lock, looping local alarm WAV, Dismiss/Complete/Snooze controls, and reconciliation on edits/deletion. Permission/volume/device restrictions can delay or prevent alerts; force-stop/device shutdown prevent delivery. Recurrence actions preserve original completed records and create the next independent occurrence. Boot/time/timezone changes reschedule.

The first image supplies custom notification extras `quicknotes.photoId`, `quicknotes.photoMime`, and `quicknotes.contactPhoto` (bounded thumbnail Bitmap). Notification-listener apps can read those extras after the user grants notification access. No visible large icon or BigPictureStyle is set; stock notification fronts remain title/notes. Both ordinary and urgent notification builders attach the extras.

## Build, release and validation

Standalone aapt/javac/d8/zipalign/apksigner build with JDK 17 and platform/build-tools 35. Python resolves pinned Google authorization dependency versions and highest requested transitives; only runtime classes/resources are bundled. AAR ID resources are adapted for AAPT1. Build directories are cleaned for reproducible classes. Stable signing uses the retained private keystore; no keys, tokens, private attribution, or account credentials are committed.

Release includes `QuickNotes-v1.3.0.apk`, source ZIP, this specification and SHA256SUMS. CI checks the signed APK against a fresh build and runs model/UI and native Android 15 tests before publishing from main. Model tests cover recurrence/cycles/merge/order, section migration/sync, 30-day expiration, restore and tombstones. UI tests cover inline editing, swipe actions, folding deletion, scheduling, repeats, photos/subtasks, list long-press, section drops, emoji/hex persistence, settings/themes and recovery/clear. Native tests cover real urgent audio, permission-sensitive scheduling/reconciliation, confirmation, recurrence notification actions, section merge, expiration, system bars, and hidden photo metadata. Live Google authorization/Drive transfer remains unverified pending external configuration.

Not exhaustive iOS parity: no iCloud, Siri, shared-list assignment, widgets or Apple integrations.

## Version 1.4.0 — widgets and organization

Android AppWidgetProvider with RemoteViews ListView, a RemoteViewsService, and configuration Activity. Each widget selects All, Scheduled, Today (including overdue), Flagged, or a live user-created list and chooses System, Light, or Dark. It resizes horizontally/vertically and scrolls its reminder rows. Incomplete, nondeleted reminders in live lists are sorted by due timestamp ascending, title as a tie breaker, undated last. Widgets refresh on saves, sync/import, notification completion, clock/timezone/day changes, and every 30 minutes. Widget settings remain local to each home-screen instance. Tapping a title opens its list, a row opens its editor, + opens a new reminder in the selected user list, and the gear reconfigures it.

Launcher static shortcut New Reminder and in-app empty-home long-press menu create a reminder. MainActivity consumes new-reminder and widget intents after WebView readiness, including warm launches. Sorting choices are Manual, Due date, Priority, A–Z, Flagged first, Newest first. List preferences sync as updated list records; smart-list preferences stay local. Newest uses creation order (legacy records use their existing order). Dragging manually resets the list preference to Manual. Post-drag taps do not navigate or edit lists. Others is a derived gray temporary group based on effective root section membership; it disappears when no visible unassigned reminders remain and reappears after dropping on the remove-from-section area.

Google App Actions / Gemini are omitted for this sideload release because official App Actions deployment requires Play Store publication and separate review: https://developer.android.com/develop/devices/assistant/get-started . Android launcher shortcuts do not provide Gemini conversation or list/date/urgent voice extraction.



## Version 1.8.0

Ordinary due reminders now use `setExactAndAllowWhileIdle` when exact-alarm permission is granted; otherwise Android's inexact fallback is used. Urgent reminders continue using alarm-clock delivery. Boot, time changes, exact-alarm permission grants and package updates rebuild schedules. Missed due-time alerts are recovered once per reminder/due timestamp on reschedule. Notification and precise-alarm permissions must be enabled; Android force-stop and manufacturer restrictions can still block delivery.

Flagged non-urgent reminders publish an ongoing low-importance notification immediately on save, with a system chronometer countdown if dated. Due-time delivery alerts through the high-importance reminder channel. Completion, deletion, unflagging and list deletion remove live notifications. Android may allow the user to dismiss ongoing notifications.

Section headers support expand/collapse arrows, hidden reminder counts, and arbitrary section text color. Section state and list background colors are record fields preserved through document sync. The visible remove-from-section drop box is removed; dropping on the exposed list title/search/count space or into Others clears the section, including on grocery lists via a manual override.

List and app backgrounds accept arbitrary colors. Foreground is automatically pure black or white using WCAG relative luminance and the higher contrast ratio. App custom appearance remains a local setting. Native status/navigation bars use the displayed background. Widget configuration offers custom #RRGGBB background and Follow list background alongside app/system/light/dark; rows, header and controls select pure black/white text.

Describe Reminder opens Android voice input first, prefers offline recognition, requests no partial results, and never parses while speech is in progress. After speech finishes the user reviews the transcript, then requests local Google ML Kit English entity extraction (`16.0.0-beta6`). ML Kit requires a one-time language model download, then runs locally. Recognition availability and offline support depend on the installed speech provider. Model failure leaves the transcript intact and reports a retry/manual entry choice. Dates are accepted from trailing ML Kit spans, not interior title words. Final explicit flag/urgent commands and list selection are resolved against the complete sentence; the user reviews before saving. ML Kit provides dates, not a general purpose semantic sentence parser. The previous regex date parser remains only for legacy model tests; the Android capture flow does not call it.

Grocery classification is a packaged multinomial Naive Bayes text model trained from the supplied dictionary: 2,604 source entries and 18 categories, plus retained phrase aliases for compatibility. `scripts/train_grocery.py` reproduces `grocery-model.js`; source SHA-256 is embedded. Whole normalized keyword matches gate classification: no keyword always yields Others. Longest phrases establish candidates, then learned word/bigram likelihoods resolve ties. Manual placement survives until the title changes. No network, account, or language-model download is required for grocery classification. This is a small lexical statistical classifier, not an embedding or generative model.

Google account linking, background account synchronization, and copied-text/CSV/JSON reminder import are removed. Existing local reminders remain. ZIP backup restore and user-selected document synchronization remain available. Gradle 8.9 / Android Gradle Plugin 8.7.3 handle ML Kit transitive resources, manifest components and native libraries.

## Version 1.8.1 — production installation repair
The production APK retains com.quicknotes.app and the original release signing certificate, with versionCode 10. Native libraries must remain ZIP_STORED and begin at offsets divisible by 16384. Alignment occurs after any ZIP modifications and before apksigner; the final signed bytes are checked again. CI installs the actual production APK using non-incremental Package Installer and tests an in-place upgrade from signed v1.7.0. This catches packaging errors that installation of the temporary-key test build alone cannot detect.


## 1.8.2: urgent notification visibility
Urgent reminders never show a notification or alarm screen before their due timestamp, whether flagged or unflagged. Early-notification alarms are only scheduled for non-urgent reminders. A shared guard in notification publication also cancels an existing pre-due notification, and reconciliation removes a live notification after the item becomes urgent. Due alarm delivery checks the actual timestamp without the previous two-second allowance and reschedules premature broadcasts. AlarmService independently rejects pre-due and snoozed starts. Non-urgent flagged countdown notifications remain unchanged. The supplied expanded grocery dictionary is byte-for-byte identical to data/expanded_grocery_dictionary.json.


## 1.8.3: flagged notification visibility
Flagged reminders with a future due timestamp do not publish notifications, including early alerts. Scheduling, direct notification publication, and reconciliation share the visibility check; changing a due reminder to a future timestamp cancels the existing notification. Due-time alarm broadcasts still publish ongoing flagged notifications, with an elapsed-time chronometer and no countdown. Undated non-urgent flagged reminders retain a static ongoing notification. Unflagged non-urgent early reminders remain available. This supersedes the pre-due countdown behavior described in 1.8.0 and 1.8.2. Android instrumentation covers save, direct/early publication, actual due-time delivery, and rescheduling into the future. Version code is 12.


## 1.8.4: flagged notification delivery
Flagged non-urgent reminders require a positive due date at or before now. Their first due notification posts the alert and then records delivery for that exact due date. Silent persistent refreshes require that delivery record. Undated and future reminders never show a timer; moving a reminder into the future clears its old notification.
