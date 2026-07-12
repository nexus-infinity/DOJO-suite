# Xcode Graph Policy

**Effective:** 2026-07-13 (Melbourne)

`project.yml` is the canonical source for the native Xcode project graph.

`DOJO-suite.xcodeproj` is generated from `project.yml` using:

```
xcodegen generate
```

Do not hand-edit `DOJO-suite.xcodeproj/project.pbxproj` to repair group or target membership drift.

When native graph drift occurs:

1. Update `project.yml`.
2. Run `xcodegen generate`.
3. Validate affected SwiftPM and Xcode targets.
4. Commit `project.yml` and generated project changes together.
5. Keep workspace/userdata/local IDE noise out of the graph commit unless explicitly required.

Reason: the native graph previously developed broken duplicate group structure (`Contracts 2` ghosts). The repair path that worked was generator-first, not direct project mutation.
