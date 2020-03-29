Preparations

1. find libIndexStore
  - default Swift toolchain?
2. create the index store instance
  - indexstore needs to be up-to-date
  - locate it
    - explict specification
    - convention
      - SwiftPM project
      - Xcode project

Refactoring steps

1. Find canonical occurrence (USR?).
  - lots of help for humans
  - input: (partial) cursor info or usr
2. Find references of USR.
  - not valid
  - list of occurrences
3. Do something about the references.
  - rename (for now)
