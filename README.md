# Bummr

[![CircleCI](https://circleci.com/gh/lpender/bummr.svg?style=svg)](https://circleci.com/gh/lpender/bummr)
[![Code Climate](https://codeclimate.com/github/lpender/bummr/badges/gpa.svg)](https://codeclimate.com/github/lpender/bummr)
[![Test Coverage](https://codeclimate.com/github/lpender/bummr/badges/coverage.svg)](https://codeclimate.com/github/lpender/bummr/coverage)

Updating Gems one by one is a bumm(e)r: especially when one gem causes your build
to fail.

Gems should be updated in [separate commits](http://ilikestuffblog.com/2012/07/01/you-should-update-one-gem-at-a-time-with-bundler-heres-how/).

The bummr gem allows you to automatically update all gems which pass your
build in separate commits, and logs the name and sha of each gem that fails.

Bummr assumes you have good test coverage and follow a [pull-request workflow]
with `master` as your default branch.

Please note that this gem is *alpha* stage and may have bugs.

## Installation

```bash
$ gem install bummr
```

By default, bummr will use `bundle exec rake` to run your build.

To customize your build command, `export BUMMR_TEST="./bummr-build.sh"`

If you prefer, you can [run the build more than once], to protect against
brittle tests and false positives.

By default, bummr will assume your base branch is named `master`. If you would
like to designate a different base branch, you can set the `BASE_BRANCH`
environment variable: `export BASE_BRANCH='develop'`

[run the build more than once]: https://gist.github.com/lpender/f6b55e7f3649db3b6df5

## Usage:

Using bummr can take anywhere from a few minutes to several hours, depending
on the number of outdated gems you have and the number of tests in your test
suite.

For the purpose of these instructions, we are assuming that your base branch is
`master`. If you would like to specify a different base branch, see the
instructions in the Installation section of this README.

- After installing, create a new, clean branch off of your `master` branch.
- Run `bummr update`. This may take some time.
- `Bummr` will give you the opportunity to interactively rebase your branch
  before running the tests. Careful.
- At this point, you can leave `bummr` to work for some time.
- If your build fails, `bummr` will notify you of failures, logging the failures to
  `log/bummr.log`. At this point it is recommended that you lock that gem version in 
  your Gemfile and start the process over from the top. Alternatively, you may wish 
  to implement code changes which fix the problem.
- Once your build passes, open a pull-request and merge it to your `master` branch.

##### `bummr update`

- Finds all your outdated gems
- Updates them each individually, using `bundle update --source #{gemname}`
- Commits each gem update separately, with a commit message like:
- Options:
  - `--all` to include indirect dependencies (`bummr` defaults to direct dependencies only)
  - `--group` to update only gems from a specific group (i.e. `test`, `development`)

`Update gemname from 0.0.1 to 0.0.2`

- Runs `git rebase -i master` to allow you the chance to review and make changes.
- Runs `bummr test`

##### `bummr test`

- Runs your build script (`.bummr-build.sh`).
- If there is a failure, runs `bummr bisect`.

##### `bummr bisect`

- `git bisect`s against master.
- Finds the bad commit and attempts to remove it.
- Logs the bad commit in `log/bummr.log`.
- Runs `bummr test`.

## Notes

- Bummr assumes you have good test coverage and follow a [pull-request workflow]
  with `master` as your default branch.
- Once the build passes, you can push your branch and create a pull-request!
- You may wish to `tail -f log/bummr.log` in a separate terminal window so you
  can see which commits are being removed.
- Bummr conservatively updates gems using `bundle update --source gemname`
- Bummr automatically rebases out commits which fail the build using an "ours"
  merge strategy.
- Bummr may not be able to remove the bad commit due to a merge conflict, in
  which case you will have to remove it manually, continue the rebase, and
  run `bummr test` again.

## License

See LICENSE

## Developing

`rake build` to build locally

`gem install --local ~/dev/mine/bummr/pkg/bummr-X.X.X.gem` in the app you
wish to use it with.

`rake` will run the suite of unit tests.

I'd like to create feature tests, but because Bummr relies on command line
manipulations which need to be doubled, I'm waiting on [this
issue](https://github.com/bjoernalbers/aruba-doubles/issues/5)

## Thank you!

Thanks to Ryan Sonnek for the [Bundler
Updater](https://github.com/wireframe/bundler-updater) gem.

[pull-request workflow]: https://help.github.com/articles/using-pull-requests
