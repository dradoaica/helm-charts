# Install MicroK8s

## Via multipass with a static network

```
New-VMSwitch -SwitchName "MyStaticSwitch" -SwitchType Internal
Get-NetAdapter -Name "vEthernet (MyStaticSwitch)" -- e.g., ifIndex 52
New-NetIPAddress -IPAddress 192.168.85.1 -PrefixLength 24 -InterfaceIndex 52
New-NetNat -Name "MyNatNetwork" -InternalIPInterfaceAddressPrefix 192.168.85.0/24
multipass networks

# microk8s-vm-my-static-switch.yaml
write_files:
  - path: /etc/netplan/99-custom.yaml
    content: |
      network:
        ethernets:
          eth1:
            dhcp4: false
            addresses:
              - 192.168.85.3/24
        version: 2
runcmd:
  - netplan apply

multipass launch --name microk8s-vm --cpus 4 --memory 8G --disk 40G --network name=MyStaticSwitch --cloud-init microk8s-vm-my-static-switch.yaml
multipass shell microk8s-vm
sudo snap install microk8s --classic --channel=1.30/stable
echo '--node-ip=192.168.85.3' | sudo tee -a /var/snap/microk8s/current/args/kubelet
sudo snap restart microk8s
sudo snap install microk8s-integrator-windows
sudo iptables -P FORWARD ACCEPT
exit
microk8s config | ForEach-Object { $_ -replace 'https://.*:16443', 'https://192.168.85.3:16443' } > $env:LOCALAPPDATA\MicroK8s\config
microk8s status --wait-ready
```

## Or via microk8s

```
microk8s install --cpu=4 --mem=8 --disk=40 --channel=1.30/stable
microk8s status --wait-ready
```

## Turn on the services you plan to use

```
microk8s enable --help
microk8s enable dashboard
microk8s enable hostpath-storage
microk8s enable metrics-server
microk8s enable prometheus
```

# Re/Start MicroK8s

```
microk8s start
microk8s status --wait-ready
microk8s kubectl get all --all-namespaces
```

# Access the MicroK8s dashboard

```
microk8s dashboard-proxy
```

# Install helm charts

```
microk8s kubectl create namespace ra2

multipass exec microk8s-vm -- mkdir charts

multipass transfer charts\aspnetcore-ignite-server microk8s-vm:charts/aspnetcore-ignite-server -r
microk8s helm install aspnetcore-ignite-server ./charts/aspnetcore-ignite-server -n ra2
microk8s kubectl port-forward -n ra2 service/aspnetcore-ignite-server 10800:10800 8080:8080
microk8s helm uninstall aspnetcore-ignite-server -n ra2
multipass exec microk8s-vm -- rm -rf charts/aspnetcore-ignite-server

multipass transfer charts\clamav-openshift microk8s-vm:charts/clamav-openshift -r
microk8s helm install clamav-openshift ./charts/clamav-openshift -n ra2
microk8s kubectl port-forward -n ra2 service/clamav-openshift 3310:3310
microk8s helm uninstall clamav-openshift -n ra2
multipass exec microk8s-vm -- rm -rf charts/clamav-openshift

multipass transfer charts\conductor-oss-conductor microk8s-vm:charts/conductor-oss-conductor -r
microk8s helm install conductor-oss-conductor ./charts/conductor-oss-conductor -n ra2
microk8s kubectl port-forward -n ra2 service/conductor-oss-conductor 5000:5000 8080:8080
microk8s helm uninstall conductor-oss-conductor -n ra2
multipass exec microk8s-vm -- rm -rf charts/conductor-oss-conductor

multipass transfer charts\ignite microk8s-vm:charts/ignite -r
microk8s helm install ignite ./charts/ignite -n ra2
microk8s kubectl port-forward -n ra2 service/ignite 10800:10800 8080:8080
microk8s helm uninstall ignite -n ra2
multipass exec microk8s-vm -- rm -rf charts/ignite

multipass transfer charts\ignite-3 microk8s-vm:charts/ignite-3 -r
microk8s helm install ignite-3 ./charts/ignite-3 -n ra2
microk8s kubectl port-forward -n ra2 service/ignite-3 10800:10800 10300:10300
microk8s helm uninstall ignite-3 -n ra2
multipass exec microk8s-vm -- rm -rf charts/ignite-3
```

# Stop MicroK8s

```
microk8s stop
```

# Uninstall MicroK8s

## Via multipass

```
multipass delete microk8s-vm
multipass purge
```

## Or via microk8s

```
microk8s uninstall
```

# Misc

## Refresh MicroK8s certs

```
microk8s refresh-certs --cert ca.crt
microk8s refresh-certs --cert server.crt
microk8s refresh-certs --cert front-proxy-client.crt
multipass exec microk8s-vm -- sudo snap restart microk8s
microk8s config | ForEach-Object { $_ -replace 'https://.*:16443', 'https://192.168.85.3:16443' } > $env:LOCALAPPDATA\MicroK8s\config
```

## Install local tools

```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

```
scoop install helm
scoop install helm-docs
```
