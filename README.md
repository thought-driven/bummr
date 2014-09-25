# Bundler::Updater
> Updating your entire bundle is dangerous.
> Updating your gems one at a time is tedious.

bundler-updater interactively walks you through updating outdated gems
and gives you the power to choose what gems to update.

## Installation

```bash
$ gem install bundler-updater
```

## Usage

Execute `bundler-updater` command and respond to prompts for
selecting what gems to update.

```bash
$ bundler-updater
> Update my_gem from 0.0.1 to 0.0.2? (y/n) y
> Update another_gem from 1.0.0 to 2.0.0? (y/n) n
>
> Updating my_gem...
```

## TODO
Contribute this gem to core bundler gem as an enhancement to the core bundler project.

```bash
$ bundle update --interactive
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/bundler-updater/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
