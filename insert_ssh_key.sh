#!/usr/bin/env bash
set -euo pipefail

function help {
  echo "Usage: insert_ssh_key.sh [-c container] [-s ssh_server] [-p ssh_port] [-l user] [-u ssh_user] [-r rsa_pub_file]"
  echo "---------------------------------------"
  echo "container:	        The docker container to insert the authorized keys. Either this or the ssh_server should be specified but not both"
  echo "ssh_server:	        The ssh server to insert the authorized keys. Either this or the container should be specified but not both"
  echo "ssh_port:	        The ssh server port to connect to [default: 22]"
  echo "user:  			The user account to use for logging into ssh server to insert the keys. Not needed for container [default: root]"
  echo "ssh_user:  		The service account allowed to log into ssh server for tasks [default: root]"
  echo "rsa_pub_file:		The RSA public key file to allow access to [default: ~/.ssh/id_rsa.pub]"
}

# Set defaults
user=root
ssh_user=root
port=22
host=
container=
rsa_pub_file=~/.ssh/id_rsa.pub

while getopts ":hl:u:c:s:r:" opt; do
  case ${opt} in
    l )
      user=$OPTARG
      ;;
    u )
      ssh_user=$OPTARG
      ;;
    c )
      container=$OPTARG
      ;;
    s )
      host=$OPTARG
      ;;
    p )
      port=$OPTARG
      ;;
    r )
      rsa_pub_file=$OPTARG
      ;;
    \? )
      help
      ;;
    : )
      help
      ;;
    h )
      help
      ;;
  esac
done

# Check to ensure either host or container are specified
if [ "$host$container" = "" ];
then
  help
  exit 0
fi

# Define the home directory and hence ssh config directory
if [ $ssh_user == "root" ];
then
  homedir=/root
else
  homedir=/home/$ssh_user
fi
sshdir=$homedir/.ssh

rsa=$(cat $rsa_pub_file)
restrictions='no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty,command="remote-access-ctl.sh"'
authorized_keys="$restrictions $rsa"
if [ -n "$host" ];
then
  # Insert the keys into a server
  echo Inserting authorized keys into ssh server $host at port $port for user $ssh_user via user $user...
  echo $authorized_keys | ssh $user\@$host -p $port "sudo -u $ssh_user mkdir -p $sshdir && sudo -u $ssh_user cat >> $sshdir/authorized_keys && if [ -f $homedir/.profile ]; then source $homedir/.profile ; fi && sudo -u $ssh_user env > $sshdir/environment ;"
else
  # Insert the keys into docker
  echo Inserting authorized keys into docker container $container for user $ssh_user...
  echo $authorized_keys | docker exec -i $container bash -c "mkdir -p $sshdir && cat >> $sshdir/authorized_keys && if [ -f $homedir/.profile ]; then source $homedir/.profile ; fi && env > $sshdir/environment ;"
fi

