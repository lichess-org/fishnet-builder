# fishnet build tools

Docker image for an environment that can produce fully static Stockfish builds.

## Components

- [Alpine Linux](https://www.alpinelinux.org/)
- [Rust](https://www.rust-lang.org/)
- [cargo auditable](https://github.com/rust-secure-code/cargo-auditable)
- [Intel SDE](https://www.intel.com/content/www/us/en/developer/articles/tool/software-development-emulator.html) (proprietary)
- [sgerrand/alpine-pkg-glibc](https://github.com/sgerrand/alpine-pkg-glibc) (to run Intel SDE)
