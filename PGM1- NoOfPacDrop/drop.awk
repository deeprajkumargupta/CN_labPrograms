BEING{
    drop=0
}
{
    if($1=="d"){
        drop++
    }
}
END{
    print "total packets dropped =", drop
}


#execute
#gedit lab1.tcl
#ns lab1.tcl
#gedit drop.awk
#awk -f drop.awk out.tr