# Kumade [![Build Status](https://secure.travis-ci.org/gabebw/kumade.png)](http://travis-ci.org/gabebw/kumade)
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
kumade will deploy to any remote in the repo.
For example, if you have a remote named "bamboo":

    $ kumade deploy bamboo

which will autodetect the name of the Heroku app that the bamboo remote points
to, and deploy to it.

To run in pretend mode, which just prints what would be done:

    $ kumade deploy bamboo -p

The default task is to deploy to staging:

    $ kumade # equivalent to "kumade deploy staging"

## Compatibility
Tested against:
 * MRI 1.8.7
 * MRI 1.9.2
 * REE 1.8.7

## What's with the name?
Kumade ([pronunciation here](http://translate.google.com/#ja|en|熊手)) means
"bamboo rake" in Japanese.
