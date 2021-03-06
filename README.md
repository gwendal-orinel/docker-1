# Docker deployement of dns-loadbalancing

## Create docker network :
```
docker network create --subnet=192.168.0.0/24 dnsproject
```

## Build containers
- Core
```
docker build https://github.com/gwendal-orinel-pro/docker.git#master:core -t core
```

- Checker
```
docker build https://github.com/gwendal-orinel-pro/docker.git#master:checker -t checker
```

- Dnspub
```
docker build https://github.com/gwendal-orinel-pro/docker.git#master:dnspub -t dnspub
```

- Supermonkey
```
docker build https://github.com/gwendal-orinel-pro/docker.git#master:supermonkey -t supermonkey
```

## Run containers:
- Core
```
docker run -d --name=core -h core --net=dnsproject --ip 192.168.0.2 core
```

- Checker
```
docker run -d --name=checker -h checker --net=dnsproject --ip=192.168.0.3 checker
```

- Dnspub
```
docker run -d --name=dnspub -h dnspub -p 53:53 -p 53:53/udp --net=dnsproject --ip 192.168.0.4 dnspub
```

- Supermonkey
```
docker run -d --name=supermonkey -h supermonkey --add-host "core:192.168.0.2" --add-host "checker:192.168.0.3" --add-host "dnspub:192.168.0.4" --net=dnsproject --ip=192.168.0.5 -p 80:80 -p 8500:8501 -p 443:8502 -v /var/run/docker.sock:/var/run/docker.sock supermonkey
```

## Add a new service:
```
export PUBLIC_ADRESSES_LIST="12.13.14.15" # Public Address in your Supermonkey settings.json's file
export TOKEN="fdsq45-sq2z-4b75-9dbf-ae61fdpela76" # Token admin or new generated (via consul token page)
for address in $PUBLIC_ADRESSES_LIST; do \
curl \
    --request POST \
    --data \
'{
  "ID": "service1",
  "Name": "service1",
  "tags": [
    "ttl 0",
    "active"
  ],
  "Address": "8.8.4.4",
  "Port": 53,
  "Check": {
    "Interval": "2s",
	"TCP": "8.8.4.4:53",
	"TTL": "0s"
  }
}' http://$address:8500/v1/agent/service/register?token=$TOKEN ;done
```
>- ID must be different for each server
>- Name must be same for each server, it will become the name of subdomain
>- Change Tag "ttl 0" for your service's TTL desired value, configured by the dns
>- Change Tag "active" to "passive" for make active/passive strategy. If neither of both is specified, active profile is applied

## Testing service
`dig ID_OF_YOUR_SERVICE.YOUR_DOMAIN_NAME_CONFIGURED_IN_CONSUL @YOUR_PUBLIC_ADRESS`
> Check the status of service in SuperMonkey Projects page, if your service is up & running your service will be available through dns response otherwise it will not be.

## Delete service
```
export PUBLIC_ADRESSES_LIST="12.13.14.15" # Public Address in your Supermonkey settings.json's file
export TOKEN="fdsq45-sq2z-4b75-9dbf-ae61fdpela76" # Token admin or new generated (via consul token page)
for address in $PUBLIC_ADRESSES_LIST; do curl http://$address:8500/v1/agent/service/deregister/dns2?token=$TOKEN ;done
```
