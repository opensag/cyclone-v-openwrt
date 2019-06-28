#!/bin/sh

#==========================================
#Configure following ports first
#==========================================
ipsec_port="eth2"
fwd_port="eth3"

ifconfig $ipsec_port up   #make sure ipsec_port is up before the following setting
ifconfig $fwd_port up     #make sure fwd_port is up before the following setting

ethtool -X $fwd_port equal 2
ethtool -X $ipsec_port equal 2

ethtool -G $fwd_port rx 4096
ethtool -G $fwd_port tx 4096
ethtool -G $ipsec_port rx 4096
ethtool -G $ipsec_port tx 4096

#==========================================
#Place /etc/sysctl.conf correctly before
#using this script
#==========================================
sysctl -p

sysctl -w net.core.rps_sock_flow_entries=32768
sysctl -w net.ipv4.ip_early_demux=0
sysctl -w net.core.netdev_max_backlog=65535
sysctl -w net.core.dev_weight=2048
sysctl -w net.core.netdev_tstamp_prequeue=0

IRQ=`cat /proc/interrupts | grep -i $ipsec_port-rx-0 | cut  -d:  -f1 | sed "s/ //g"`
echo 1 > /proc/irq/$IRQ/smp_affinity
IRQ=`cat /proc/interrupts | grep -i $ipsec_port-rx-1 | cut  -d:  -f1 | sed "s/ //g"`
echo 2 > /proc/irq/$IRQ/smp_affinity
IRQ=`cat /proc/interrupts | grep -i $ipsec_port-tx-0 | cut  -d:  -f1 | sed "s/ //g"`
echo 1 > /proc/irq/$IRQ/smp_affinity
IRQ=`cat /proc/interrupts | grep -i $ipsec_port-tx-1 | cut  -d:  -f1 | sed "s/ //g"`
echo 2 > /proc/irq/$IRQ/smp_affinity

IRQ=`cat /proc/interrupts | grep -i $fwd_port-rx-0 | cut  -d:  -f1 | sed "s/ //g"`
echo 1 > /proc/irq/$IRQ/smp_affinity
IRQ=`cat /proc/interrupts | grep -i $fwd_port-rx-1 | cut  -d:  -f1 | sed "s/ //g"`
echo 2 > /proc/irq/$IRQ/smp_affinity
IRQ=`cat /proc/interrupts | grep -i $fwd_port-tx-0 | cut  -d:  -f1 | sed "s/ //g"`
echo 1 > /proc/irq/$IRQ/smp_affinity
IRQ=`cat /proc/interrupts | grep -i $fwd_port-tx-1 | cut  -d:  -f1 | sed "s/ //g"`
echo 2 > /proc/irq/$IRQ/smp_affinity

echo 1 > /sys/class/net/$ipsec_port/queues/rx-0/rps_cpus
echo 1 > /sys/class/net/$ipsec_port/queues/rx-1/rps_cpus
echo 3 > /sys/class/net/$fwd_port/queues/rx-0/rps_cpus
echo 3 > /sys/class/net/$fwd_port/queues/rx-1/rps_cpus

echo 3 > /sys/class/net/$ipsec_port/queues/tx-0/xps_cpus
echo 3 > /sys/class/net/$ipsec_port/queues/tx-1/xps_cpus
echo 3 > /sys/class/net/$fwd_port/queues/tx-0/xps_cpus
echo 3 > /sys/class/net/$fwd_port/queues/tx-1/xps_cpus
