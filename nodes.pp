#
# nodes.pp - defines all puppet nodes
#


# Global ! install some defaults
#include rpmforge
include epel
include repoforge
Package { ensure => "installed" }
$enhancers = [ "screen", "strace", "sudo", "tree",
		"vim-enhanced", "mlocate", "lsof" , "sharutils",
		"git","patch",
		"tcpdump", "nmap", "iftop",
		"htop",
		"lynx",
	     ]
package { $enhancers: }


node default {
  include stdlib
  include firewall
  notice("Hello from ${hostname}")

  firewall {
    '000 accept all icmp':
      proto   => 'icmp',
      action  => 'accept';

    '001 accept all to lo interface':
      proto   => 'all',
      iniface => 'lo',
      action  => 'accept';

    '002 accept related established rules':
      proto   => 'all',
      ctstate => ['RELATED', 'ESTABLISHED'],
      action  => 'accept';

    '100 allow ssh access':
      port   => [22],
      proto  => tcp,
      action => accept;

    '999 drop all':
      proto   => 'all',
      action  => 'drop';
  }
}



# self-manage the puppet master server
node 'puppet' { }

##### CLIENTS
node /^.*client\d+.*$/ inherits default {
  notice("Elastic search for ${hostname}")
  #### collectd
  include collectd
  class { 'collectd::plugin::network':
	  servers       => { 'puppet' => { 'port'=> '25826',
					    'interface'     => 'eth0',
					    'securitylevel' => '',
	    				 },
	  },
  }
  #### Elastic search 

  class {'elasticsearch': 
	datadir      => '/var/lib/elasticsearch-data',
	java_install => true,
	manage_repo  => true,
  	repo_version => '1.4',
  }

 #create an instance!
  elasticsearch::instance { 'esearch': 
	config => {
	    'cluster' => {
	      'name' => 'esearch',
	      'routing.allocation.awareness.attributes' => 'rack',
	      'index.number_of_replicas' => '2',
	      'index.number_of_shards'   => '5',
	      'network.host' => '0.0.0.0',
	      'network.publish_host' => '0.0.0.0', # hmm need to do this as first non loop interface is host-only 
	      'network.bind_host'    => '0.0.0.0', # hmm need to do this as first non loop interface is host-only 
	      'marvel.agent.enabled' => false #DISABLE marvel data collection.
	    },
	},
  }

  elasticsearch::plugin {
    'elasticsearch/marvel/1.1.1':
      ensure     => present,
      instances  => 'esearch',
      module_dir => 'marvel';
  }

  elasticsearch::plugin{'royrusso/elasticsearch-HQ':
  	instances  => 'esearch'
  }


  $config_hash = {
 		'LS_USER' => 'root',
 		'START' => 'true'
  }

  class { 'logstash':
	  ensure       => 'present',
	  manage_repo  => true,
	  repo_version => '1.5',
	  require      => [ Class['java'], Class['elasticsearch'] ],
	  init_defaults => $config_hash,
  }

  logstash::configfile { 'configname':
  	content => template('logstash/final_config.erb')
  } 


  firewall {
    '201 allow access to elasticsearch':
      port   => [9200, 9300],
      proto  => tcp,
      action => accept;
  }
  #we might have 
}


node 'kibana' {
  include collectd
  class { 'java':
  	distribution => 'jdk',
  }
  class { 'kibana': 
	es_url => 'http://client1:9200',
  }

  firewall { '140 Kibana' :
          chain  => 'INPUT',
          proto  => 'tcp',
          state  => 'NEW',
          dport  => [ '5601' ],
          action => 'accept',
    }
}
