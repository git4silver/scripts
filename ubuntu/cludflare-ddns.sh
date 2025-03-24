#!/bin/bash

# A bash script to update a Cloudflare DNS A record with the external IP of the source machine
# Used to provide DDNS service for my home
# Needs the DNS record pre-creating on Cloudflare

# Proxy - uncomment and provide details if using a proxy
#export https_proxy=http://<proxyuser>:<proxypassword>@<proxyip>:<proxyport>

# Cloudflare zone is the zone which holds the record
zone=''
# dnsrecord is the A record which will be updated
dnsrecord=''
zoneid=''

## Cloudflare authentication details
## keep these private
cloudflare_auth_email=''
cloudflare_auth_key=''

a=0

until [ ! $a -lt 6 ]
do
  update=true
   #echo $a

  # Get the current external IP address
  ip=$(curl -s -X GET https://checkip.amazonaws.com)

  #echo "Current IP is $ip"

  if host $dnsrecord 1.1.1.1 | grep "has address" | grep "$ip"; then
    #echo "$dnsrecord is currently set to $ip; no changes needed"
    update=false  
  fi

  # if here, the dns record needs updating

  # Get the current external IP address
  ip=$(curl -s -X GET https://api.ipify.org)

  #echo "Current IP is $ip"

  if host $dnsrecord 1.1.1.1 | grep "has address" | grep "$ip"; then
    #echo "$dnsrecord is currently set to $ip; no changes needed"
    update=false
  fi

  # if here, the dns record needs updating
  if $update ; then
    
    echo "$(date) Updating the record with new ip: $ip"

    # get the dns record id
    dnsrecordid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?type=A&name=$dnsrecord" \
      -H "Authorization: Bearer $cloudflare_auth_key" \
      -H "Content-Type: application/json" | jq -r  '{"result"}[] | .[0] | .id')
    
    
    # update the record
    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records/$dnsrecordid" \
      -H "Authorization: Bearer $cloudflare_auth_key" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"A\",\"name\":\"$dnsrecord\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}" | jq
    echo "$(date) restarting the wireguard container"  
    docker container restart wireguard
  fi

  sleep 10s

   a=`expr $a + 1`
done