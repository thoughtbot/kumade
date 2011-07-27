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
## Set the name of the staging remote (autodetected by default)
# Kumade.staging_remote = 'staging'
## Set the name of the production remote (autodetected by default)
# Kumade.production_remote = 'production'

# Set the name of the staging app on Heroku (required)
Kumade.staging_app = 'my-staging-app'
# Set the name of the production app on Heroku (required)
Kumade.production_app = 'my-production-app'
```

Now running `rake -T` shows the new tasks:

```bash
rake deploy             # Alias for kumade:deploy
rake deploy:production  # Alias for kumade:deploy:production
rake deploy:staging     # Alias for kumade:deploy:staging

rake kumade:deploy             # Alias for kumade:deploy:staging
rake kumade:deploy:production  # Deploy to Heroku production
rake kumade:deploy:staging     # Deploy to Heroku staging
```

If you only want the namespaced tasks (the ones with "kumade:" in front), do
this in your Rakefile:

```ruby
Kumade.load_namespaced_tasks
```

Now `rake -T` will only show this:

```bash
rake kumade:deploy             # Alias for kumade:deploy:staging
rake kumade:deploy:production  # Deploy to Heroku production
rake kumade:deploy:staging     # Deploy to Heroku staging
```

## Compatibility
Tested on MRI 1.8.7 and 1.9.2.

## What's with the name?
Kumade ([pronunciation here](http://translate.google.com/#ja|en|熊手)) means
"bamboo rake" in Japanese.
