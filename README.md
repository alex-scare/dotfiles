
#### Prerequisites

1. Connect to wifi via networkmanager 

Package should be selected as additional package during the installation

```
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
nmcli device wifi connect "name" password "pass"
```

2. Make script executable

```
chmod +x install.sh
```

3. Execute
