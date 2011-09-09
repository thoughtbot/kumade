# Kumade 熊手 [![Build Status](https://secure.travis-ci.org/thoughtbot/kumade.png)](http://travis-ci.org/thoughtbot/kumade)
Kumade is a set of basic Rake tasks for deploying to Heroku. It aims to
provide most of what you want. Unlike other Heroku deploy gems, it is
well-tested.

## Development
Development is happening very fast, and the internals are in constant flux. The
public API is constant (e.g. `kumade production` will work), but you may have to
rebase against master a couple times before your pull request can be merged.

## What does Kumade do?
Before deploying, Kumade ensures the git repo is clean and that all tests pass.
After that, it packages assets using
[Jammit](http://documentcloud.github.com/jammit/) and/or
[More](https://github.com/cloudhead/more), commits them, and pushes to origin.
Then it force pushes to the correct remote and runs `rake db:migrate` on the
Heroku app.

If any step fails, it immediately prints an error and stops the deploy
process.

## Install
In your Gemfile:

```ruby
gem 'kumade'
```

## Usage

kumade will deploy to any Heroku remote in the repo.
For example, if you have a remote named "bamboo":

    $ bundle exec kumade bamboo

or

    # in your Rakefile:
    require 'kumade'

    # kumade auto-generates a deploy:ENV task for every Heroku environment
    $ rake deploy:bamboo

which will autodetect the name of the Heroku app that the bamboo remote points
to and deploy to it.

To run in pretend mode, which prints what would be done without actually doing
any of it:

    $ bundle exec kumade bamboo -p

The default is to deploy to staging:

    $ bundle exec kumade # equivalent to "bundle exec kumade staging"


## Does it support the Cedar stack?

Yes. kumade will automatically detect if your app is running on Cedar.

## Compatibility

Tested against:

* MRI 1.8.7
* MRI 1.9.2
* REE 1.8.7

## Misc Features

Want to run a task before bundling your assets on deploy? In your Rails app's rake tasks, drop in:

``` ruby
namespace :kumade do
  task :before_asset_compilation do
    puts "This runs before assets are committed and pushed to the remote"
  end
end
```

You can hook in any custom code you want to run there before deploying!

## What's with the name?

Kumade ([pronunciation here](http://translate.google.com/#ja|en|熊手)) means
"bamboo rake" in Japanese.

## License

kumade is Copyright © thoughtbot. It is free software, and may be redistributed under the terms specified in the LICENSE file.
