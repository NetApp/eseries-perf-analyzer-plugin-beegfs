#!/bin/bash

/opt/beegfs/sbin/beegfs-mon cfgFile=/etc/beegfs/beegfs-mon.conf
tail -f /var/log/beegfs-mon.log

/bin/bash
