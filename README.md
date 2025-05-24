## Setup Monitoring Tools On Aws Using Terraform.

In this Project, we want to install Grometheus, and Grafana in one ec2 instance and Node Exporter on anather ec2 instance using terraform.

These monitoring tools are:

- Prometheus
- Grafana
- Node Exporter

### Part I. Simple Installation Steps

# A. Setup Prometheus

### What is Prometheus?

- It is an open-source systems monitoring and alerting toolkit which collects and aggregates metrics as time series data. It stores a variety of events such as memory consumption, CPU and network uitilization, indiviudal incoming/outgoing requets in its database system called Time series Database (TSDB).  

# Installation Steps

**A.1.0.** From [Prometheus Download](https://prometheus.io/download/) page, download latest stable version. At the time of writing this tutorial, latest stable version is 3.3.1.

You can use `wget` command to download the compressed file. Copy the link address of the file that you want to download and then run the command in your terminal.


**A.1.1.**  Create directory called **prometheus** and extract the downloaded file to that directory. Unpack/untar/unzip the .

``` bash
sudo su
mkdir prometheus
cd prometheus
sudo wget https://github.com/prometheus/prometheus/releases/download/v3.3.1/prometheus-3.3.1.linux-amd64.tar.gz
sudo tar -xvf prometheus-3.3.1.linux-amd64.tar.gz
sudo rm -rf prometheus-3.3.1.linux-amd64.tar.gz
```


**A.1.2.** Change directory to the  extracted directory and start the prometheus server in the background using this command `./prometheus &`.

``` bash
cd prometheus-3.3.1.linux-amd64.tar.gz
./prometheus &
```

**A.1.3.** At this moment, prometheus will start running, and the default port which prometheus listens on, is port **9090**. 

**A.1.4.** If you use local linux machine you can access Prometheus UI here `http://localhost:9090/`. For this tutorial, we will use the external or public IP address our aws ec2 instance `https://<your_ec2_xtarnal_ip_address>:9090/`. And for us to access our prometheus UI, we need to open port **9090** in security group of our ecc2 instance where prometheus is running.

If you use local linux machine, run below commands:

``` bash
firewall-cmd --add-port 9090/tcp
firewall-cmd --permanent --add-port 9090/tcp
systemctl restart firewalld
```

- In the prometheus UI, if we execute  the`up` command, it will show the instances which are in UP state. Here, we will only have one instance which is the one in which prometheus is running. It will display this nessage `up{instance="localhost:9090", job="prometheus"}`. If we add IP adresses of other instances to `prometheus.yml` configuration file, it will display those instances,as well. For example, we'll add another instance when we install node exporter.


# B. Setup Node Exporter

**What is Node Exporter?** 

- There are a lot of exporters which are provided by Prometheus itself. Exporters are used to expose metrics so that Prometheus can collect scrap them. Node Exporter is one of the simple exporters out there and it is used to collect basic system metrics from the VM. Other exporter like `black box` collect application's metrics and expose them to prometheus.

### Installation Steps

**B.1.0.** From [Prometheus Download](https://prometheus.io/download/) page, download latest stable version of node exporter. At the time of writing this tutorial, latest stable version is 1.9.1.

You can use `wget` command to download the compressed file. Copy the link address of the file that you want to download and then run the command in your terminal.

**B.1.1.**  Create directory called **node-exporter** and extract the downloaded file to that directory. Then you can delete zip file.

``` bash
sudo su
mkdir node-exporter
cd node-exporter
sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz
sudo tar -xvf node_exporter-1.9.1.linux-amd64.tar.gz
sudo rm -rf node_exporter-1.9.1.linux-amd64.tar.gz
```

**B.1.2.** cd to extracted directory `node_exporter-1.9.1.linux-amd64` and start the node-exporter in the background using the command `./node-exporter &`.

``` bash
cd node-exporter/node_exporter-1.9.1.linux-amd64/
./node_exporter &
```

**B.1.3.** Node-exporter listens on port **9100**. 

**B.1.4.** If we were using a local linux machine, we would have accessed Node-exporter metrics using `http://localhost:9100/`. Since we are using an ec2 instance, we will use the public ip address to access our Node-Exporter web UI. In my case, it is `https://<your_ec2_public_ip_address>:9100/`. We must make sure that port **9100** is allowed in the instance security group rule. 

If we were using a local linux machine, the commands below will be useful:

``` bash
firewall-cmd --add-port 9100/tcp
firewall-cmd --permanent --add-port 9100/tcp
systemctl restart firewalld
```

# C. Setting Up Grafana

**What is Grafana?** 

- Grafana is an open-source interactive data-visualization platform for visualizing metrics, logs, and traces collected from your applications. It allows users to see their data via charts and graphs that are unified into dashboards for easier interpretation and understanding.

# Installation Steps

**C.1.0.** From [Grafana Download](https://grafana.com/grafana/download?platform=linux) page, download latest stable version of Grafana. At the time of writing, latest stable version of grafana is 12.0.0.


**C.1.1.**  Create directory called **grafana** and extract the downloaded file to that directory. Then you can delete zip file.

``` bash
sud su
mkdir grafana
cd grafana
sudo wget https://dl.grafana.com/enterprise/release/grafana-enterprise-12.0.0.linux-amd64.tar.gz
sudo tar -xvf grafana-enterprise-12.0.0.linux-amd64.tar.gz 
sudo rm -rf  grafana-enterprise-12.0.0.linux-amd64.tar.gz
```

**C.1.2.** In the current or `grafana` directory, cd to `grafana-12.0.0/`(*the extracted directory of grafana*) directory and type the command `./bin/grafana-server &` to run grafana in the background

``` bash
cd grafana/grafana-12.0.0/
./bin/grafana-server 
```

**C.1.3.** The default port for grafana is **3000**. 

**C.1.4.** Grafana listens on port **3000**. If we were using a local linux machine, we would access Grafana UI on `http://localhost:3000/`. We will use the public IP Address of our aws ec2 instance. Do`https://<your_ec2_public_ip_address>:3000/`. Let's make sure port **3000** is open in our instance security group rule.

If you use local linux machine, run below commands:

``` bash
firewall-cmd --add-port 3000/tcp
firewall-cmd --permanent --add-port 3000/tcp
systemctl restart firewalld
```
- You can also access Grafana UI by visiting `http://localhost:3000/` for local machine or `https://<your_ec2_public_ip_address>:3000/` for google cloud instance.

## D. Configure Node Exporter Host as Target on Prometheus Host

**D.1.0.** To configure node exporter as a target on prometheus, do the following:

- Edith `prometheus.yml` configuration file
```bash
sudo nano /etc/prometheus/prometheus.yml
```
- Copy the file below and paste at the end of the file 

``` bash
  - job_name: "node-exporter"
    scrape_interval: 5s
    static_configs:
      - targets: ["<your_ec2_public_ip_address>:9100"]
```
Check if the configuration was successful:

```bash
promtool check config /etc/prometheus/prometheus.yml
```

For prometheus to pickup the change, you need to restart prometheus. To do this, run the following command:

- Inspect prometheus process id or `PID` and obtain a number, e.g. `12345`

```bash
sudo pgrep prometheus
```
- Kill the id
```bash
sudo kill -9 <PID>
```
- restart promethous

```bash
./prometheus & 
```
or 

``` bash
sudo systemctl restart prometheus
```

# E: Configure Grafana with Prometheus as a data source 

To better visualize matrix scrapped by prometheus, we have to configure grafana with Prometheus as a data source 

**E.1.0**: Create the data source
 - Login to grafana
 - On the right-hand-side of grafana dashboard, click on `Connections` -> `Data source`. 
 - On the full screen, click on `Add data source`.
   - choose `prometheus`.
   - under `connection`, enter the prometheus server public IP and map it to prometheus port.`http:<prometheus-server-public_ip>:9090/`.
   - leave everything as default, scroll down and click on `Save & test` to save the data source configuration. 

**E.1.2**: Create node_exporter dashboard
- In the left navigation of grafana dasboard, click on `Dashboards`.
- In left navigation of the screen, click on;`New` -> `import`.
  - in the dialogue box showing `Grafana.com dashboard URL or ID`, paste the url that you want to visualize with grafana.
  - click on `load`
NB: In the case, prometheus target is node_exporter. So we search for `node_exporter grafana dashboard` on the browser. Copy the ID and past in the dialogue box and click on `load`.
  - under `Options`, Choose the `Name` of the dashboard. E.g, `Node Exporter Full`.
  - under `prometheus`, select `prometheus` as the data source -> `Import(Overwrite)`. 
Here you can view matrix scrapped by prometheus on grafana dashboard.


## PART II: BEST PRACTICE TO INSTALL PROMETHEUS, NODE EXPORTER AND GRAFANA
The best paractice is to install each of these tools to boot as systemd service.

## A. Setup Prometheus as Systemd Service

**A.2.0.** In previous step, we noticed that in order to start prometheus server we need to use command `./prometheus` while in the extracted directory. The problem with this method is that it keeps our terminal running and we can't run other commands using the same terminal. If we want to run other commands we will need to stop prometheus by `Ctrl + C`. To solve this issue, it is better to setup Prometheus as **Systemd service**.

**A.2.1.** Create prometheus user, required directories and make prometheus user as owner of the directories.

``` bash
useradd --no-create-home --shell /bin/false prometheus
mkdir /etc/prometheus
mkdir /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus
```

**A.2.2.** Copy *prometheus* and *promtool* from the extracted directory to */usr/local/bin* and change the ownership to prometheus.

``` bash
cp /root/prometheus/prometheus-3.3.1.linux-amd64/prometheus /usr/local/bin/
cp /root/prometheus/prometheus-3.3.1.linux-amd64/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
```

**A.2.3.** Copy *consoles*, *console_libraries* and *prometheus.yml* file from the extracted directory to */etc/prometheus* and change the ownership to prometheus.

``` bash
cp -r /root/prometheus/prometheus-3.3.1.linux-amd64/consoles /etc/prometheus
cp -r /root/prometheus/prometheus-3.3.1.linux-amd64/console_libraries /etc/prometheus
cp /root/prometheus/prometheus-3.3.1.linux-amd64/prometheus.yml /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries
chown prometheus:prometheus /etc/prometheus/prometheus.yml
```

**A.2.4.** Create a `prometheus.service` file.

``` bash
nano /etc/systemd/system/prometheus.service
```

**A.2.5.** Copy the following content to that `prometheus.service` file and save.

``` 
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
```

**A.2.6.** Reload the systemd service, enable service to start at boot time and start the service.

``` bash
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
```
**A.2.7.** Access Prometheus Web UI through - `http://localhost:9090/` for local machine or `https://<your_ec2_public_ip_address>:9090/` 


## B. Setup Node-exporter as Systemd Service

**B.2.0.** In the previous step, we found that in order to start node_exporter, we need to use tge command `./node_exporter` always. The problem with this method is that it populates the terminal and we can't run other commands. We've to stop the node-exporter service `Ctrl + C` when we want to use the terminal, run `./node_exporter` when want to re-run node-exporter. To get rid of this situation, it is better to setup Node-exporter as **Systemd service**.

**B.2.1.** Create node_exporter user, required directory and make node-exporter user as owner of the directory.

``` bash
useradd --no-create-home --shell /bin/false node_exporter
mkdir /etc/node_exporter
chown node_exporter:node_exporter /etc/node_exporter
```

**B.2.2.** Copy *node_exporter* from the extracted directory to */usr/local/bin* and change the ownership to node_exporter.

``` bash
cp /root/node-exporter/node_exporter-1.9.1.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter
```

**B.2.3.** Create node_exporter.service file.

``` bash
nano /etc/systemd/system/node_exporter.service
```

**B.2.4.** Copy the content below, paste in the file, and save.

``` 
[Unit]
Description=Node-Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

**B.2.5.** Reload the systemd service, enable service, start the service.

``` bash
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter
```
**B.2.6.** Go to Node Exporter UI web address - `http://localhost:9100/` for local machine or `https://<your_ec2_public_ip_address>:9090/` for google cloud instance.


## C. Configure Node Exporter Host as Target on Prometheus Host

**C.2.0.** Add Node_exporter as a target to prometheus

```bash
nano /etc/prometheus/prometheus.yml
```
**C.2.1.** Copy the information below, paste , and save.

``` bash
  - job_name: "node-exporter"
    scrape_interval: 5s
    static_configs:
      - targets: ["<your_ec2_public_ip_address>:9100"]
```
**C.2.2.** Check if the configuration was successful:

```bash
promtool check config /etc/prometheus/prometheus.yml
```
**C.2.3.** Restart prometheus service so that it will start scraping the matrix collected by node_exporter.

``` bash
sudo systemctl restart prometheus
sudo systemctl status prometheus --no-pager
```


## D. Setup Grafana as Systemd Service 

**D.2.0.** In the previous step, we realized that we have to use the command `./bin/grafana-server` everytime we want to restart grafana. The problem with this method is that it keeps our terminal busy and we can not execute other commands in the terminal. If you want to run other commands we'll need to stop it by `Ctrl + C`. To solve this issue, it is a best practice to setup Grafana as **Systemd service**.

```bash
#1!/bin/bash
sudo apt-get update
sudo apt-get install -y apt-transport-https software-properties-common wget
sudo mkdir -p /etc/apt/keyrings/
sudo wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install -y grafana
sudo systemctl enable grafana-server.service
sudo systemctl start grafana-server.service
sudo systemctl status grafana-server.service --no-pager
```
# E: Configure Grafana with Prometheus as a data source 
It's the same thing in the `E` section of Part I.
# NB: The practice part of installing these tools has been implemented using terraform
