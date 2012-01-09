## 0.8.2 (2011-11-09)
* Add kumade:pre\_deploy Rake task hook

* Git#push when remote does not exist returns silently

## 0.8.1 (2011-11-08)
* Correctly restart apps

## 0.8.0 (2011-10-21)
* Kumade now has working (and autoloaded!) Rake tasks. `rake deploy:staging`
  will Just Work.

* Removed Less::More packager. The only included packager is now Jammit.

## 0.7.0 (2011-10-15)
* Kumade now has a working check for the Cedar stack.

## 0.6.0 (2011-10-15)
* Remove thor dependency, since Thor is no longer in the gem.

## 0.5.0 (2011-10-15)
* Use Kumade::Outputter instead of inheriting from Kumade::Base. Remove
  Kumade::Base.

## 0.0.1 - 0.4.0
* No changelog was kept.
