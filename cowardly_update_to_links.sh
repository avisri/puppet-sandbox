#!/bin/bash

dsts=( /etc/hiera.yaml 		/etc/puppet/hiera.yaml  /etc/puppet/modules /etc/puppet/puppet.conf /etc/puppet/hieradata )
srcs=( /vagrant/hiera.yaml 	/vagrant/hiera.yaml 	/vagrant/modules    /vagrant/puppet.conf    /vagrant/hieradata )

#ln -s /etc/hiera.yaml  /etc/puppet/hiera.yaml
#ln -s /vagrant/hiera.yaml  /etc/hiera.yaml
#ln -s /vagrant/modules
#ln -s /vagrant/puppet.conf
#ln -s /vagrant/hieradata

count=0
for dst in ${dsts[*]}
do 
  src="${srcs[$count]}"
  ((count++))
  echo "----------------[$count/${#dsts[*]}]-----------"
  echo "$dst will be linked to $src -----"
  mv -v $dst $dst.orig.`date +%s`
  ln -v -s $src $dst 
done
