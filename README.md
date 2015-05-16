# Bumper
The "bumper" gem allows you to automatically update all gems which pass your
build in separate commits.

## Usage:

- Create a new, clean branch off of master.
- Run `bumper update`

When you run `bumper update`, Bumper will Update, Test, and Bisect if necessary.

### Update:
(`bumper update`)

- Find all your outdated gems
- Update them each individually, using `bundle update --source #{gemname}`
- Commit each gem update separately, with a commit message like

`gemname, {0.0.1 -> 0.0.2}`

- Run `git rebase -i master` to allow you the chance to review and make changes.

### Test:
(`bumper test`)

- Run your build script.
- If there is a failure:

### Bisect:
(`bumper bisect`)

- `git bisect` against master.
- Find the bad commit and attempt to remove it.
- Log the bad commit in `log/bumper.log`.
- Test again until the build passes.

#### Notes

- Once the build passes, you can push your branch and create a pull-request!
- You may wish to `tail -f log/bumper.log` in a separate terminal window so you
  can see which commits are being removed.

## Installation

```bash
$ gem install bumper
```

Add a file called `.bumper-build.sh` to the root of your git directory.

Here is a suggested build script which will `bundle exec rake` 4 times:

```bash
#!/bin/sh
MAX_TRIES=4
COUNT=0
EXIT=0

while [ $COUNT -lt $MAX_TRIES ] && [ $EXIT -eq 0 ]; do
  git log --pretty=format:'%s' -n 1
  echo "\nRunning test suite... $COUNT of $MAX_TRIES"
  bundle exec rake
  let EXIT=$?
  let COUNT=COUNT+1
done

exit $EXIT
```

Commit this and merge it to master before attempting to update your gems.

## Contributing

Here are some things I'd love to add to Bumper:

- Test coverage.
- Configuration options (for test script path, name of master branch, etc)

1. Fork it ( https://github.com/lpender/bumper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Thank yous

Thanks to Ryan Sonnek for the [Bundler
Updater](https://github.com/wireframe/bundler-updater) gem.
