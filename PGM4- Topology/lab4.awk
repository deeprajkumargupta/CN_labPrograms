awk

BEGIN { 
    sends = 0; 
    recvs = 0; 
    drops = 0; 
    total_delay = 0; 
} 

{ 
    if ($1 == "s" && $4 == "AGT") { 
        sends++; 
        start_time[$6] = $2; 
    } 
    if ($1 == "r" && $4 == "AGT") { 
        recvs++; 
        end_time[$6] = $2; 
    } 
    if ($1 == "d") { 
        drops++; 
    } 
} 

END { 
    pdr = (recvs / sends) * 100; 
    
    for (i in end_time) { 
        if (start_time[i] > 0) { 
            total_delay += (end_time[i] - start_time[i]); 
        } 
    } 
    
    avg_delay = (total_delay / recvs) * 1000; 
    
    printf "Packets Sent: %d\n", sends; 
    printf "Packets Received: %d\n", recvs; 
    printf "Packets Dropped: %d\n", drops; 
    printf "Packet Delivery Ratio: %.2f%%\n", pdr; 
    printf "Average End-to-End Delay: %.2f ms\n", avg_delay; 
}