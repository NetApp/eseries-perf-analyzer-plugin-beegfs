Overview of the E-Series Performance Analyzer Plugin for BeeGFS
---------------------------------------------------------------

The BeeGFS Monitoring service (BeeGFS Mon) collects statistics from a BeeGFS filesystem and writes them to a time series database (InfluxDB). Data in the time series database can be visualized using a tool like Grafana, and the BeeGFS Mon package provides several predefined Grafana dashboards. As the BeeGFS Mon package does not include InfluxDB or Grafana, the E-Series Performance Analyzer provides a convenient "batteries included" platform to deploy BeeGFS Mon. 

For more information on BeeGFS Mon see https://www.beegfs.io/wiki/Mon. For more information on the E-Series Performance Analyzer please see https://github.com/NetApp/eseries-perf-analyzer/blob/master/README.md.

Plugin Prerequisites
--------------------
* An installation of the NetApp E-Series Performance Analyzer version 2.1 or later (https://github.com/NetApp/eseries-perf-analyzer).
* The server running the E-Series Performance Analyzer must be able to access the server running the BeeGFS Management service. In most cases this should be enough to allow the Docker container running BeeGFS Mon to reach the BeeGFS Management server over the Docker network used by the E-Series Performance Analyzer. 
    * In some environments the network or other configuration on the server running Docker may not be setup to allow this, and changes may be required this documentation cannot account for.

What configuration is required before enabling this plugin?
-----------------------------------------------------------
Note: Please see the E-Series Performance Analyzer's README (https://github.com/NetApp/eseries-perf-analyzer/blob/master/README.md) for the latest guidance on working with plugins. The documentation provided below specific to installing/configuring/starting/updating plugins is current as of this README's publishing date. 

#### Downloading and installing the plugin:
1. Navigate to the `plugins/` directory of your E-Series Performance Analyzer installation.
2. Under `plugins/` create a new directory `beegfs_monitoring`.
3. Clone this GitHub repository to the `plugins/beegfs_monitoring` directory (e.g. `git clone <url> beegfs_monitoring`). 

#### Initially configuring and starting the plugin:
1. In the `plugins/beegfs_monitoring/beegfs_mon/beegfs-mon.conf` file, update the `sysMgmtdHost` to point at the IP address of the BeeGFS Management server in your environment. 
2. To build all plugin requirements, navigate to the root directory of the E-Series Performance Analyzer and run `make build-plugins`.
3. To run all plugin(s) run `make run-plugins`.

#### Updating the plugin's configuration:
If you need to change the IP used for the BeeGFS Management server simply update the `sysMgmtdHost` line in `plugins/beegfs_monitoring/beegfs_mon/beegfs-mon.conf` then restart the E-Series Performance Analyzer by navigating to the root directory and running `make restart`.

What is included with this plugin?
----------------------------------
* A Dockerfile defining an Ubuntu 18.04 Docker image that runs the latest 7.1.x release of BeeGFS Mon.
* A beegfs-deb9.list file with the official BeeGFS repository and a DEB-GPG-KEY-beegfs file containing the corresponding GPG key.
* A repo_check.sh script that automatically detects if the container is being built in an air-gapped environment, and if needed adds alternate repositories for both Ubuntu and BeeGFS.
    * If required the provided `repomirror_*.list` files would need to modified to contain the proper URLs for your air-gapped environment, see the FAQ below.
* A docker-compose.yml file that sets up the Docker container to run BeeGFS Mon.
* A beegfs-mon.conf file.
* A BeeGFS Mon datasource for Grafana.
* A number of dashboards for BeeGFS including the default set included with BeeGFS Mon, and a few created by NetApp.
    * BeeGFS Aggregated Workload
    * BeeGFS Client Ops (by Node)
    * BeeGFS Client Ops (by User)
    * BeeGFS DF (Disk Free)
    * BeeGFS Meta Server
    * BeeGFS Overview
    * BeeGFS Storage Server
    * BeeGFS Storage Targets 
    
Note: Minor modifications were made to the default dashboards included with BeeGFS Mon, in particular to ensure data was displayed as expected with the version of InfluxDB used by the E-Series Performance Analyzer. 

What happens when I enable this plugin? 
---------------------------------------
When this plugin is enabled, the E-Series Performance Analyzer will create a Docker image running Ubuntu 18.04, then pull in the latest 7.1.x version of BeeGFS Mon from the official BeeGFS repository at https://www.beegfs.io/release/beegfs_7_1. It will also create a BeeGFS Mon datasource and add BeeGFS dashboards to Grafana with the label "BeeGFS Plugin". Whenever the E-Series Performance Analyzer is started up a `beegfs_mon` Docker container will be started running the BeeGFS Mon service.

Troubleshooting
---------------
Logs from the `beegfs_mon` container including the latest contents of `/var/log/beegfs-mon.log` can be viewed by running `docker logs beegfs_mon`. For example if the BeeGFS Management IP is not set correctly or otherwise cannot be reached, you will see output like the following:
```
#docker logs beegfs_mon
(0) Jan03 01:01:56 Main [InfluxDB.cpp:298] >> Pinging InfluxDB failed due to Curl error. Error: Could not resolve host: influxdb
(0) Jan03 01:01:56 Main [InfluxDB.cpp:28] >> Coudn't reach InfluxDB service.
(2) Jan03 01:01:56 Main [InfluxDB.cpp:32] >> Retrying in 10 seconds.
(0) Jan03 01:02:06 Main [InfluxDB.cpp:298] >> Pinging InfluxDB failed due to Curl error. Error: Could not resolve host: influxdb
(0) Jan03 01:02:06 Main [InfluxDB.cpp:28] >> Coudn't reach InfluxDB service.
(2) Jan03 01:02:06 Main [InfluxDB.cpp:32] >> Retrying in 10 seconds.
(0) Jan03 01:02:16 Main [InfluxDB.cpp:298] >> Pinging InfluxDB failed due to Curl error. Error: Could not resolve host: influxdb
(0) Jan03 01:02:16 Main [InfluxDB.cpp:28] >> Coudn't reach InfluxDB service.
(0) Jan03 01:02:16 Main [App.cpp:52] >> Generic error: Connection to InfluxDB failed.
```
For recommendations on troubleshooting general issues with the E-Series Performance Analyzer please reference https://github.com/NetApp/eseries-perf-analyzer/blob/master/README.md.

FAQs
-----

* I want to create my own dashboards, where are the InfluxDB measurements stored by BeeGFS Mon documented? 
    * The Mon database reference can be found here https://www.beegfs.io/wiki/MonDatabaseReference.
* Can I edit the provided dashboards? 
    * To prevent future updates to the plugin from overriding any user customizations, the E-Series Performance Analyzer requires you to create a copy of the dashboard you wish to modify.
* Where can I find updates to the BeeGFS Plugin?
    * Currently any updates to this plugin will be delivered alongside future releases of the E-Series Performance Analyzer. Special considerations or prerequisites to upgrading the BeeGFS plugin will be documented in the README provided with any future releases of the plugin.
* I'm needing to run the BeeGFS Plugin in an air-gapped environment (e.g. no internet access), how can I use the plugin?  
    * Provided you have repository mirrors setup in the air-gapped environment for both Ubuntu and BeeGFS, there are two files in the `plugins/beegfs_monitoring/beegfs_mon` directory that can be updated to point at your internal repository mirror URLs. Update `repomirror_sources.list` with the URL(s) for Ubuntu, and `repomirror_beegfs-deb9.list` with the URL for BeeGFS. Provided the GPG key is the same for the BeeGFS repository you do not need to update the `DEB-GPG-KEY-beegfs` file. 