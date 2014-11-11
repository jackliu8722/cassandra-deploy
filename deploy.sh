#!/bin/bash

# Script for deploying cassandra on multi machchines.

. ./conf

case $1 in 
deploy)
   echo "===================Starting deploy cassandra......================"
   for machine in $hosts ;do
      host=`echo $machine | awk -F"#" '{print $1}'`
      echo "Transfering Cassandra to $host:$install_dir,please wait ..."
      cmd="mkdir -p $install_dir"
      ssh "$user@$host" "$cmd"
      scp "$cassandra_src.tar.gz" "$user@$host:$install_dir/" > /dev/null
      cmd="tar -zxvf $install_dir/$cassandra_src.tar.gz -C $install_dir"
      echo "Unpacking Cassandra on $host, please wait ..."
      ssh "$user@$host" "$cmd" > /dev/null 2>&1
      
      cassandra_conf=$install_dir/$cassandra_src/conf/cassandra.yaml
      
      echo "Starting change configuration, Please wait ..."
      # Change listen address to host 
      listen_address=$host
      cmd="sed -i 's/listen_address:.*/listen_address: $listen_address/' $cassandra_conf"
      ssh "$user@$host" "$cmd" > /dev/null 2>&1
      
      cmd="sed -i 's/rpc_address:.*/rpc_address: $listen_address/' $cassandra_conf"
      ssh "$user@$host" "$cmd" > /dev/null 2>&1

      # Change rpc port
      rpc_port=`echo $machine | awk -F"#" '{print $2}'`
      cmd="sed -i 's/rpc_port:.*/rpc_port: $rpc_port/' $cassandra_conf"
      ssh "$user@$host" "$cmd" > /dev/null 2>&1
     
      # Change num_token 
      num_tokens=`echo $machine | awk -F"#" '{print $3}'`
      cmd="sed -i 's/num_tokens:.*/num_tokens: $num_tokens/' $cassandra_conf"
      ssh "$user@$host" "$cmd" > /dev/null 2>&1
      
      # Change native_transport_port
      native_transport_port=`echo $machine | awk -F"#" '{print $4}'`
      cmd="sed -i 's/native_transport_port:.*/native_transport_port: $native_transport_port/' $cassandra_conf"
      ssh "$user@$host" "$cmd" > /dev/null 2>&1

      # Change storage_port
      storage_port=`echo $machine | awk -F"#" '{print $5}'`
      cmd="sed -i 's/storage_port:.*/storage_port: $storage_port/' $cassandra_conf"
      ssh "$user@$host" "$cmd" > /dev/null 2>&1
     
      # Change ssl_storage_port 
      ssl_storage_port=`echo $machine | awk -F"#" '{print $6}'`
      cmd="sed -i 's/ssl_storage_port:.*/ssl_storage_port: $ssl_storage_port/' $cassandra_conf"
      ssh "$user@$host" "$cmd" > /dev/null 2>&1
      
      # Change partitioner
      cmd="sed -i 's/partitioner:.*/partitioner: $partitioner/' $cassandra_conf"
      ssh "$user@$host" "$cmd" > /dev/null 2>&1
   
      # Change cluster name
      cmd="sed -i 's/cluster_name:.*/cluster_name: \"$cluster_name\"/' $cassandra_conf"
      ssh "$user@$host" "$cmd" > /dev/null 2>&1
            
      # Change seeds
      cmd="sed -i 's/seeds:.*/seeds: \"$seeds\"/' $cassandra_conf"
      ssh "$user@$host" "$cmd" > /dev/null 2>&1
      
      echo "---------------------------------------------------------------"
   done
   echo "=======================Deploy finished.========================"
   ;;
start)
   echo "==================Starting cassandra server...=================="
   
   bin_location="$install_dir/$cassandra_src/bin/cassandra"
   for machine in $hosts; do 
      host=`echo $machine | awk -F"#" '{print $1}'`
      
      cmd=". ~/.bash_profile && sh $bin_location"
      echo "Starting cassandra server at $host, Please wait ..."
      ssh "$user@$host" "$cmd" > /dev/null 2>&1
      if [ $? = 0 ];
      then
          echo "Start cassandra server at $host successfully."
      else
          echo "Start cassandra server at $host failed, Please check it."
      fi 
      echo "---------------------------------------------------------------"
   done
   echo "==================Start all cassandra server finlished.==================="
   ;;
stop)
   echo "=================Stopping cassandra server...================="
   stop_cmd="ps aux  | grep CassandraDaemon | grep -v  \"grep CassandraDaemon\" | awk -F \" \" '{print $2}' | xargs kill -9"
   for machine in $hosts;do     
      host=`echo $machine | awk -F"#" '{print $1}'`
      echo "Stopping cassandra server at $host, Please wait ..."
      ssh "$user@$host" "$stop_cmd" > /dev/null 2>&1
      echo "Stop cassandra server at $host successfully."
      echo "---------------------------------------------------------------"
   done
   echo "Stop all cassandra server finlished."
   ;;
*)
  echo -e "Usage: $0 {deploy|start|stop}\n"
esac


