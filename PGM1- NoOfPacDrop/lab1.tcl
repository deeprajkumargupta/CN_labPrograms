# Create simulator
set ns [new Simulator]

# Create trace file
set tf [open out.tr w]
$ns trace-all $tf

# Create NAM file
set nf [open out.nam w]
$ns namtrace-all $nf

# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

# Network parameters
set bw 1Mb
set delay 10ms
set qsize 10

# Create duplex links
$ns duplex-link $n0 $n1 $bw $delay DropTail
$ns duplex-link $n1 $n2 0.5Mb $delay DropTail

# Set queue limits
$ns queue-limit $n0 $n1 $qsize
$ns queue-limit $n1 $n2 $qsize

# Set link orientation for NAM
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right

# Create TCP agent
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

# Create TCP sink
set sink [new Agent/TCPSink]
$ns attach-agent $n2 $sink

# Connect TCP and sink
$ns connect $tcp $sink

# Create FTP application
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# Start and stop FTP
$ns at 1.0 "$ftp start"
$ns at 7.0 "$ftp stop"

# Finish procedure
proc finish {} {
    global ns tf nf

    $ns flush-trace

    close $tf
    close $nf

    exec nam out.nam &
    exit 0
}

# End simulation
$ns at 10.0 "finish"

# Run simulation
$ns run