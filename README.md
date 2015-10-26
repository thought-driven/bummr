# Bummr

Updating Gems one by one is a Bummr: especially when one gem causes your build
to fail.

Gems should be updated in [separate commits](http://ilikestuffblog.com/2012/07/01/you-should-update-one-gem-at-a-time-with-bundler-heres-how/).

The *Bummr* gem allows you to automatically update all gems which pass your
build in separate commits, and logs the name and sha of each gem that fails.

## Installation

#### 1. Install Gem

```bash
$ gem install bummr
```

#### 2. Merge `.bummr-build.sh`

Add a file called `.bummr-build.sh` to the root of your git directory.
`

`.bummr-build.sh`

```bash
#!/bin/sh
bundle exec rake
```

Commit it and merge it to master.

`.bummr-build.sh` is be used to to test your build. If it exits with `0`, 
it is assumed that the gem updates were performed correctly.

If you prefer, you can [run the build more than once]
(https://gist.github.com/lpender/f6b55e7f3649db3b6df5), to protect against 
brittle tests and false positives.

## Usage:

- After installing, create a new, clean branch off of master.
- Run `bummr update`.
- `Bummr` will give you the opportunity to interactively rebase your branch 
  before running the tests. Delete any commits for gems which you don't want
  to update and close the file.
- At this point, you can leave `bummr` to work for some time.
- If your build fails, `bummr` will attempt to automatically remove breaking 
  commits, until the build passes, logging any failures to `/log/bummr.log`.
- Once your build passes, open a pull-request and merge it to your `master` branch.

##### `bummr update`

- Finds all your outdated gems
- Updates them each individually, using `bundle update --source #{gemname}`
- Commits each gem update separately, with a commit message like:

`gemname, {0.0.1 -> 0.0.2}`

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

- Bummr assumes you have good test coverage and follow a (pull-request workflow)
  [https://help.github.com/articles/using-pull-requests/] with `master` as your
  default branch.
- Once the build passes, you can push your branch and create a pull-request!
- You may wish to `tail -f log/bummr.log` in a separate terminal window so you
  can see which commits are being removed.
- Bummr may not be able to remove the bad commit due to a merge conflict, in
  which case you will have to remove it manually, continue the rebase, and
  run `bummr test` again.

## Contributing

1. Fork it ( https://github.com/lpender/bummr/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Wanted

Here are some things I'd love to add to Bummr:

- Test coverage.
- Configuration options (for test script path, name of master branch, etc)

## Thank you!

Thanks to Ryan Sonnek for the [Bundler
Updater](https://github.com/wireframe/bundler-updater) gem.
