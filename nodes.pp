#
# nodes.pp - defines all puppet nodes
#


# Global ! install some defaults
Package { ensure => "installed" }
$enhancers = [ "screen", "strace", "sudo", 
		"vim-enhanced", "mlocate", "lsof" , "sharutils",
		"tcpdump",
	     ]
package { $enhancers: }

# self-manage the puppet master server
node 'puppet' { }

##### CLIENTS

node 'client1' {
  class {'elasticsearch': 
	java_install => true,
	manage_repo  => true,
  	repo_version => '1.4',
	config => {
	    'cluster' => {
	      'name' => 'esearch',
	      'routing.allocation.awareness.attributes' => 'rack',
	    },
	},
  }
  class { 'helloworld': }
}

node 'client2' { 
  class {'elasticsearch': 
	java_install => true,
	manage_repo  => true,
  	repo_version => '1.4',
	config => {
	    'cluster' => {
	      'name' => 'esearch',
	      'routing.allocation.awareness.attributes' => 'rack',
	    },
	},
  }
}

node 'kibana' {
  class { 'java':
  	distribution => 'jdk',
  }
  class { 'kibana': 
	es_url => 'http://client1:9200',
  }
}
