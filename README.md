# Music App — Prioritas Pengembangan

## 🔴 High Priority

| # | Item | Status | Keterangan |
|---|------|--------|------------|
| 1 | **Error handling** | ❌ Belum | Banyak `try/catch` kosong, tidak ada error state di PlayerProvider, tidak ada global error handler |
| 2 | **Fitur stubs** | ❌ Belum | Lyrics button (now-playing), add online song ke playlist, favorite untuk lagu online belum berfungsi |
| 3 | **Test coverage** | ⚠️ Minimal | Hanya 2 unit test (playlist & search), widget test placeholder, tidak ada integration test |
| 4 | **YouTube stream cache** | ⚠️ Sebagian | Stream URL expire ~6 jam, mekanisme cache/refresh belum tuntas |
| 5 | **SourceBadge YouTube** | ❌ Belum | Lagu YouTube tidak menampilkan badge yang benar |
| 6 | **Genre filter** | ❌ Belum | Genre card hardcoded, navigasi ke Search tidak membawa filter genre |

## 🟡 Medium Priority

| # | Item | Status | Keterangan |
|---|------|--------|------------|
| 7 | **Deduplikasi search** | ⚠️ Placeholder | `source_aggregator.dart` line 26: TODO dedup logic |
| 8 | **API key management** | ⚠️ Placeholder | `.env` tidak ada, Jamendo & Last.fm silent fail |
| 9 | **DiscoveryProvider.loadGenres()** | ❌ Belum | Method disebut di README tapi belum diimplementasikan |
| 10 | **CI/CD pipeline** | ❌ Belum | Tidak ada GitHub Actions, Fastlane, Codemagic |
| 11 | **Platform iOS** | ❌ Belum | Hanya Android & Web, iOS belum di-generate |
| 12 | **Crash reporting** | ❌ Belum | Tidak ada Sentry / Firebase Crashlytics |

## 🟢 Low Priority

| # | Item | Status | Keterangan |
|---|------|--------|------------|
| 13 | **Lyrics caching & fallback** | ⚠️ Single source | Hanya lyrics.ovh tanpa fallback/cache |
| 14 | **Autentikasi & cloud sync** | ❌ Belum | Mungkin tidak diperlukan untuk music player lokal |
| 15 | **Filter/sort persist** | ❌ Belum | Sort/filter di Library Screen tidak persist |
| 16 | **Versi konsisten** | ⚠️ Tidak konsisten | pubspec.yaml = 1.0.0+1, app_constants.dart = 2.0.0 |
| 17 | **Song Info dialog** | ⚠️ Minimalis | Bisa diperkaya dengan metadata lebih detail |
| 18 | **User-Agent placeholder** | ⚠️ Placeholder | musicbrainz_source.dart pakai `fatur@example.com` |
