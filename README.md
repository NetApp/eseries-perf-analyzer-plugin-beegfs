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
1. In the `plugins/beegfs_monitoring/beegfs_mon/beegfs-mon.conf` file, update the `sysMgmtdHost` variable to point at the IP address of the BeeGFS Management server in your environment.
2. By default, data points are retained for 4 weeks before being dropped by the database. This value is configurable via the `dbRetentionDuration` variable in `plugins/beegfs_monitoring/beegfs_mon/beegfs-mon.conf`. Valid values are described in the config file in the section describing this variable. 
    * See the NOTE in the section below if you want to change this value after initially starting the plugin.
3. To build/start the plugin, navigate to the root directory of the E-Series Performance Analyzer and use one of the following commands:
    * If the E-Series Performance Analyzer is already running use: `make restart`.
    * If the E-Series Performance Analyzer is stopped or this is the first time starting it use: `make run`.

#### Updating the plugin's configuration:
Any changes to the configuration file (located at `plugins/beegfs_monitoring/beegfs_mon/beegfs-mon.conf`) requires a restart of the E-Series Performance Analyzer. This can be done by navigating to the root directory of the project (not just the plugin) and running 'make restart'.

NOTE: The `dbRetentionDuration` variable described in the section above only takes effect when the database is created initially. In order to update the retention duration at any point in the future you must do so via the command line. We have provided a simple one-line Docker command for this purpose:
```
docker exec -it influxdb influx -execute 'alter retention policy auto on beegfs_mon duration 4w'
```
(Replace '4w' with your desired retention duration)

To verify the new retention policy has been accepted, you can run this command and check the output:
```
docker exec -it influxdb influx -execute 'show retention policies on beegfs_mon'
```


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
# docker logs beegfs_mon
(1) Feb19 18:14:28 Main [App.cpp:301] >> Detaching process...
(1) Feb19 18:14:28 Main [App.cpp:251] >> Version: 7.1.4
(2) Feb19 18:14:28 Main [App.cpp:279] >> Usable NICs: eth0(TCP) 
(3) Feb19 18:14:34 NodeListReq [NodeListRequestor.cpp:41] >> Did not receive a response from management node!
(3) Feb19 18:15:10 NodeListReq [NodeListRequestor.cpp:41] >> Did not receive a response from management node!
```
For recommendations on troubleshooting general issues with the E-Series Performance Analyzer please reference https://github.com/NetApp/eseries-perf-analyzer/blob/master/README.md.

### Known Issues
* The `BeeGFS Workload (Aggregated)` dashboard displays a lot of data as a summation of all of your servers. As such, this dashboard's performance is heavily impacted by the chosen time range. A determination has been made that users would prefer much more accurate data on a more immediate basis, so the focus of these graphs is on that use case. Expect performance issues when viewing time ranges greater than one or two weeks on this dashboard.

FAQs
-----

* I want to create my own dashboards, where are the InfluxDB measurements stored by BeeGFS Mon documented? 
    * The Mon database reference can be found here https://www.beegfs.io/wiki/MonDatabaseReference.
* Can I edit the provided dashboards? 
    * To prevent future updates to the plugin from overriding any user customizations, the E-Series Performance Analyzer requires you to create a copy of the dashboard you wish to modify.
* Where can I find updates to the BeeGFS Plugin?
    * Currently any updates to this plugin will be delivered in this repository. Special considerations or prerequisites to upgrading the BeeGFS plugin will be documented in the README provided with any future releases of the plugin.
* I'm needing to run the BeeGFS Plugin in an air-gapped environment (e.g. no internet access), how can I use the plugin?  
    * Provided you have repository mirrors setup in the air-gapped environment for both Ubuntu and BeeGFS, there are two files in the `plugins/beegfs_monitoring/beegfs_mon` directory that can be updated to point at your internal repository mirror URLs. Update `repomirror_sources.list` with the URL(s) for Ubuntu, and `repomirror_beegfs-deb9.list` with the URL for BeeGFS. Provided the GPG key is the same for the BeeGFS repository you do not need to update the `DEB-GPG-KEY-beegfs` file. 