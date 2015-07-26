Puppet RPMForge repo module
==============

Adds the RPM Forge repo. Tested on CentOS 6.

Usage
--------------

```puppet
include rpmforge
```

Or to enable extras repo:

```puppet
class {'rpmforge':
	extras => 1,
}
```

Enable the testing repo:

```puppet
class {'rpmforge':
	testing => 1,
}
```

If you later want to disable the repo:

```puppet
class {'rpmforge':
	enabled => 0,
}
```

Dependencies
--------------
* [puppet-module-epel](https://github.com/stahnma/puppet-module-epel)
