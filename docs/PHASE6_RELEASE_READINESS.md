# Phase 6 — Testing, optimization and release readiness

## Automated quality gate

The GitHub Actions workflow at `.github/workflows/flutter-ci.yml` runs for pushes to main, pull requests targeting main, and manual dispatch. It resolves packages, runs Flutter static analysis, and executes the complete Flutter test suite on the stable Flutter channel.

## Regression coverage

The suite covers:
- Recipe serialization, compatibility, search, filters, sorting and catalog validation.
- Weekly meal assignment/replacement/removal, serving-scaled grocery aggregation, pantry deductions, manual edits and incompatible units.
- Cooking progress, serving scaling, independent timer lifecycle and deadline completion.
- App navigation, discovery interactions, locale switching and Arabic RTL directionality.

## Release checklist

- [ ] CI workflow green on the exact release commit.
- [ ] `flutter analyze --fatal-infos` clean.
- [ ] `flutter test` green.
- [ ] Verify on a small Android device and a tablet; inspect text scaling and overflow.
- [ ] Verify offline launch, missing catalog asset fallback, and interrupted content update recovery.
- [ ] Verify English and Arabic, RTL mixed text, and screen-reader labels.
- [ ] Verify timer behavior after background/resume and document notification limitations.
- [ ] Review app icon, application ID, version/build number, signing, privacy disclosure and store listing.
- [ ] Confirm all bundled images and fonts have suitable licences and attribution.

## Known release gates

The repository environment used for this implementation did not have Flutter/Dart CLI available, so no local analyze/test result is claimed. The CI workflow must run before release. Platform notifications, process-death timer restoration, and store signing remain explicit release decisions rather than silently assumed capabilities.

## Constraints retained

No login, Firebase, custom backend, cloud synchronization, or state-management package. Personal data remains local. Static public recipe content is read-only and is not allowed to contain personal planner data.
