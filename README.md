puppet-lint-fileserver-check
=================================

[![Build Status](https://travis-ci.org/camptocamp/puppet-lint-fileserver-check.svg)](https://travis-ci.org/camptocamp/puppet-lint-fileserver-check)

A puppet-lint plugin to check that you use the `file()` function instead of the Puppet Fileserver.


## Checks

### Fileserver use

Fileserver use is very slow and for small files (<16KB)

#### What you have done

```puppet
file { 'foo':
  ensure => file,
  source => 'puppet:///modules/foo/bar',
}
```

#### What you should have done

```puppet
file { 'foo':
  ensure  => file,
  content => file('foo/bar'),
}
```

#### Disabling the check

To disable this check, you can add `--no-fileserver-check` to your puppet-lint command line.

```shell
$ puppet-lint --no-fileserver-check path/to/file.pp
```

Alternatively, if you’re calling puppet-lint via the Rake task, you should insert the following line to your `Rakefile`.

```ruby
PuppetLint.configuration.send('disable_fileserver')
```
