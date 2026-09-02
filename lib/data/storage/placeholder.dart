// This folder is intentionally empty.
//
// srd.md's suggested project structure lists `data/storage/` for Hive/box
// wiring, but that responsibility already lives in
// `lib/core/services/hive_storage_service.dart`, established in Phase 0
// before any domain model existed. Phase 1 extended that same service
// with adapter registration and the four domain boxes rather than
// introducing a second, competing place for storage setup.
//
// This folder is kept (with this file) so the documented structure stays
// discoverable, in case a future phase needs a storage concern that
// doesn't belong in a general-purpose service (e.g. box migrations).
