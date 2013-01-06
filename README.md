# Kumade 熊手 [![Build Status](https://secure.travis-ci.org/thoughtbot/kumade.png)](http://travis-ci.org/thoughtbot/kumade)
Kumade is a command-line program  for deploying to Heroku. It aims to
provide most of what you want. Unlike other Heroku deploy gems, it is
well-tested.

# Deprecated!

Kumade is deprecated. Please use the Cedar stack on Heroku instead.

## Development
Development is happening very fast, and the internals are in constant flux. The
public API is constant (e.g. `kumade production` will work), but you may have to
rebase against master a couple times before your pull request can be merged.

## What does Kumade do?
Before deploying, Kumade ensures the git repo is clean.
After that, it packages assets using
[Jammit](http://documentcloud.github.com/jammit/) (if it's installed), commits
them, and pushes to origin.
Then it force pushes to the correct Heroku remote, runs `rake db:migrate` on the
Heroku app, and then restarts the app.  If all of this succeeds, it will
also run the rake task `kumade:post_deploy` if it is defined.

If any step fails, it immediately prints an error and stops the deploy
process.

## Install
In your Gemfile:

    gem 'kumade'

## Usage

kumade will deploy to any Heroku remote in the repo.
For example, if you have a remote named "staging":

    $ bundle exec kumade staging

To run in pretend mode, which prints what would be done without actually doing
any of it:

    $ bundle exec kumade staging -p

The default is to deploy to staging:

    # equivalent to "bundle exec kumade staging"
    $ bundle exec kumade

## Rake

Kumade auto-generates a deploy:ENV task for every Heroku environment. You don't
need to do anything to get the Rake tasks, they're automatically set up for you.
If you have a "staging" remote, you would run:

    $ rake deploy:staging

## Does it support the Cedar stack?

Yes. Kumade will automatically detect if your app is running on Cedar.

## Compatibility

Tested against:

* MRI 1.8.7
* MRI 1.9.2
* MRI 1.9.3
* REE 1.8.7

## Miscellaneous Features

Want to run a task before bundling your assets on deploy? In your Rails app's rake tasks, drop in:

    namespace :kumade do
      task :before_asset_compilation do
        puts "This runs before assets are committed and pushed to the remote"
      end
    end

You can hook in any custom code you want to run there before deploying!

## Development
To generate coverage (only on 1.9.x), run rake with COVERAGE set:

    COVERAGE=1 rake

## What's with the name?

Kumade ([pronunciation here](http://translate.google.com/#ja|en|熊手)) means
"bamboo rake" in Japanese.

## Credits

![thoughtbot](http://thoughtbot.com/images/tm/logo.png)

Kumade is maintained and funded by [thoughtbot, inc](http://thoughtbot.com/community)

The names and logos for thoughtbot are trademarks of thoughtbot, inc.

## License

Kumade is Copyright © 2011-2013 thoughtbot, inc. It is free software, and may be redistributed under the terms specified in the LICENSE file.
