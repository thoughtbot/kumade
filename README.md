# Kumade 熊手 [![Build Status](https://secure.travis-ci.org/thoughtbot/kumade.png)](http://travis-ci.org/thoughtbot/kumade)
Kumade is a set of basic Rake tasks for deploying to Heroku. It aims to
provide most of what you want. Unlike other Heroku deploy gems, it is
well-tested.

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

which will autodetect the name of the Heroku app that the bamboo remote points
to and deploy to it.

To run in pretend mode, which prints what would be done without actually doing
any of it:

    $ bundle exec kumade bamboo -p

The default is to deploy to staging:

    $ bundle exec kumade # equivalent to "bundle exec kumade staging"

## Does it support the Cedar stack?

Yes. To indicate that a particular app is using Cedar, run with the -c flag:

    bundle exec kumade bamboo -c

## Sample Output

### Normal mode

    $ kumade heroku-staging
    ==> Deploying to: heroku-staging
    ==> heroku-staging is a Heroku remote
    ==> Git repo is clean
    /Users/gabe/.rvm/rubies/ree-1.8.7-2011.03/bin/ruby -S bundle exec rspec [blah blah]
    ....
    rake output removed
    ...
    ==> Rake passed
    ==> Packaged assets with Jammit
    ==> + git add /Users/gabe/thoughtbot/sushi/public/assets && git commit -m 'Assets'
    [master bc8932b] Assets
    4 files changed, 0 insertions(+), 0 deletions(-)
    ==> - true
    ==> Added and committed all assets
    ==> + git push origin master
    Counting objects: 15, done.
    Delta compression using up to 2 threads.
    Compressing objects: 100% (8/8), done.
    Writing objects: 100% (8/8), 639 bytes, done.
    Total 8 (delta 7), reused 0 (delta 0)
    To git@github.com:sushi/sushi.git
      a465afd..bc8932b  master -> master
    ==> - true
    ==> Pushed master -> origin
    ==> + git push -f heroku-staging master
    Counting objects: 15, done.
    Delta compression using up to 2 threads.
    Compressing objects: 100% (8/8), done.
    Writing objects: 100% (8/8), 639 bytes, done.
    Total 8 (delta 7), reused 0 (delta 0)

    -----> Heroku receiving push
    -----> Rails app detected
    -----> Detected Rails is not set to serve static_assets
          Installing rails3_serve_static_assets... done
    -----> Configure Rails 3 to disable x-sendfile
          Installing rails3_disable_x_sendfile... done
    -----> Configure Rails to log to stdout
          Installing rails_log_stdout... done
    -----> Gemfile detected, running Bundler version 1.0.7
          All dependencies are satisfied
    -----> Compiled slug size is 65.5MB
    -----> Launching... done, v172
          http://staging-sushi.heroku.com deployed to Heroku

    To git@heroku.com:staging-sushi.git
      a465afd..bc8932b  master -> master
    ==> - true
    ==> Pushed master -> heroku-staging
    ==> + bundle exec heroku rake db:migrate --remote staging-sushi
    ... Postgres output removed ...
    ==> - false
    ==> Migrated staging-sushi
    ==> Deployed to: heroku-staging

### Pretend mode

    $ kumade heroku-staging -p
    ==> In Pretend Mode
    ==> Deploying to: heroku-staging
    ==> heroku-staging is a Heroku remote
    ==> Git repo is clean
    ==> Rake passed
    ==> Packaged assets with Jammit
    ==> Pushed master -> origin
    ==> Pushed master -> heroku-staging
    ==> Migrated staging-sushi
    ==> Deployed to: heroku-staging

### Pretend Mode with a non-Heroku remote

    $ kumade origin -p
    ==> In Pretend Mode
    ==> Deploying to: origin
    ==> ! Cannot deploy: "origin" remote does not point to Heroku

## Compatibility

Tested against:

* MRI 1.8.7
* MRI 1.9.2
* REE 1.8.7

## Misc Features

Want to run a task before bundling your assets on deploy? In your rails app's rake tasks, drop in:

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
