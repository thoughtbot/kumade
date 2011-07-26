# Kumade
Kumade is a set of basic Rake tasks for deploying to Heroku. It aims to
provide most of what you want. Unlike other Heroku deploy gems, it is
well-tested.

## What does Kumade do?
Before deploying, Kumade ensures the git repo is clean and that all tests pass.
After that, it packages assets using
[Jammit](http://documentcloud.github.com/jammit/) and/or
[More](https://github.com/cloudhead/more)), commits them, and pushes to
origin. Then it force pushes to the staging or production remote as
appropriate and runs rake db:migrate on the Heroku app.

If any step fails, it immediately raises an error and stops the deploy
process.

## Install
In your Gemfile:

```ruby
gem 'kumade'
```

## Usage
In your Rakefile:

```ruby
Kumade.load_tasks
# Set the name of the staging remote (default: 'staging')
Kumade.staging = 'staging'
# Set the name of the production remote (default: 'production')
Kumade.production = 'production'

# Set the name of the staging app on Heroku
Kumade.staging_app = 'my-staging-app'
# Set the name of the production app on Heroku
Kumade.production_app = 'my-production-app'
```

Now running `rake -T` shows the new tasks:

```bash
rake deploy             # Alias for deploy:staging
rake deploy:production  # Deploy to Heroku production
rake deploy:staging     # Deploy to Heroku staging
```

## What's with the name?
Kumade ([http://translate.google.com/#ja|en|熊手](pronunciation here)) means
"bamboo rake" in Japanese.
