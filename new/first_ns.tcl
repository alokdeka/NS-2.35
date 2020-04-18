#First of all, you need to create a simulator object. This is done with the command
set ns [new Simulator]

#Now we open a file for writing that is going to be used for the nam trace data.
#The first line opens the file 'out.nam' for writing and gives it the file handle 'nf'.
#In the second line we tell the simulator object that we created above to write all simulation data that is going to be relevant for nam into this file. 
set nf [open out.nam w]
$ns namtrace-all $nf

set tr [open out.tr w]
$ns trace-all $tr 



#The next line tells the simulator object to execute the 'finish' procedure after 5.0 seconds of simulation time.
$ns at 5.0 "finish"



#A new node object is created with the command '$ns node'. The above code creates two nodes and assigns them to the handles 'n0' and 'n1'. 
set n0 [$ns node]
set n1 [$ns node]

#The next line connects the two nodes.
$ns duplex-link $n0 $n1 1Mb 10ms DropTail




#Create a UDP agent and attach it to node n0
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

# Create a CBR traffic source and attach it to udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

set null0 [new Agent/Null] 
$ns attach-agent $n1 $null0


$ns connect $udp0 $null0


$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"



#The next step is to add a 'finish' procedure that closes the trace file and starts nam.
proc finish {} {
        global ns nf
        $ns flush-trace
        close $nf
        exec nam out.nam &
        exit 0
}z


#The last line finally starts the simulation.
$ns run
