[![Build Status](https://travis-ci.org/outrightmental/strap.svg)](https://travis-ci.org/outrightmental/strap)

# Jump in there

Most of all, thanks! Please take a look at [our issues](https://github.com/outrightmental/strap/issues) and go for one, or write more!

# Tagging a Release

1. Be on a stable `master` branch
2. Be certain. Run every test one last time.
3. Tag the release, e.g. `git tag -a 'v0.2.1' -m 'Stable interim release.'`
4. Push the tag, e.g. `git push origin v0.2.1`
5. Edit `src/strap.sh` and bump the `VERSION=` number at the top of the file.
6. Commit this new version, e.g. `git add src/strap.sh && git commit -m"bump working version to 0.2.2" && git push`

# Readme

Also see [README](README.md)
