# Sample Coding

set ns [new Simulator]

# Open trace and NAM files
set tracefile [open ess_sim.tr w]
$ns trace-all $tracefile
set namfile [open ess_sim.nam w]
$ns namtrace-all-wireless $namfile 1000 1000

# Topography setup
set topo [new Topography]
$topo load_flatgrid 1000 1000

# Node configuration for wireless LAN (802.11)
$ns node-config -adhocRouting DSDV \
    -llType LL \
    -macType Mac/802_11 \
    -ifqType Queue/DropTail \
    -ifqLen 50 \
    -phyType Phy/WirelessPhy \
    -channelType Channel/WirelessChannel \
    -propType Propagation/TwoRayGround \
    -antType Antenna/OmniAntenna \
    -topoInstance $topo \
    -agentTrace ON \
    -routerTrace ON

# General Operations Director (GOD) nodes
create-god 6

# Create 6 nodes (representing stations connected to APs)
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

# Set initial positions (in meters)
$n0 set X_ 100; $n0 set Y_ 100; $n0 set Z_ 0.0
$n1 set X_ 200; $n1 set Y_ 150; $n1 set Z_ 0.0
$n2 set X_ 300; $n2 set Y_ 200; $n2 set Z_ 0.0
$n3 set X_ 400; $n3 set Y_ 250; $n3 set Z_ 0.0
$n4 set X_ 500; $n4 set Y_ 300; $n4 set Z_ 0.0
$n5 set X_ 600; $n5 set Y_ 350; $n5 set Z_ 0.0

$ns initial_node_pos $n0 20
$ns initial_node_pos $n1 20
$ns initial_node_pos $n2 20
$ns initial_node_pos $n3 20
$ns initial_node_pos $n4 20
$ns initial_node_pos $n5 20

# UDP Connection: n0 -> n4
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0
set null1 [new Agent/Null]
$ns attach-agent $n4 $null1
$ns connect $udp0 $null1
$udp0 set packetSize_ 1000

# TCP Connection: n1 -> n5
set tcp0 [new Agent/TCP]
$ns attach-agent $n1 $tcp0
set sink1 [new Agent/TCPSink]
$ns attach-agent $n5 $sink1
$ns connect $tcp0 $sink1
$tcp0 set packetSize_ 1500

# CBR Application over UDP
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packetSize_ 1000
$cbr0 set rate_ 1.0Mb

# FTP Application over TCP
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

# Schedule events
$ns at 1.0 "$cbr0 start"
$ns at 2.0 "$ftp0 start"
$ns at 180.0 "$ftp0 stop"
$ns at 200.0 "$cbr0 stop"
$ns at 200.0 "finish"

# Finish procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam ess_sim.nam &
    exec echo "Simulation Complete. Number of packets dropped:" &
    exec grep -c "^D" ess_sim.tr &
    exit 0
}

$ns run