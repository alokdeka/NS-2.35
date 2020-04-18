#First of all, you need to create a simulator object. This is done with the command
set nss [new Simulator]

# Define different colors 
# for data flows (for NAM) 
$nss color 1 Blue 


#Now we open a file for writing that is going to be used for the nam trace data.
#The first line opens the file 'out.nam' for writing and gives it the file handle 'nf'.
#In the second line we tell the simulator object that we created above to write all simulation data that is going to be relevant for nam into this file. 
set nff [open out.nam w]
$nss namtrace-all $nff

set tr [open out.tr w]
$nss trace-all $tr 



#The next line tells the simulator object to execute the 'finish' procedure after 5.0 seconds of simulation time.
$nss at 5.0 "finish"



#A new node object is created with the command '$ns node'. The above code creates two nodes and assigns them to the handles 'n0' and 'n1'. 
set n0 [$nss node]
set n1 [$nss node]

#The next line connects the two nodes.
$nss duplex-link $n0 $n1 1Mb 10ms DropTail

# Give node position (for NAM) 
$nss duplex-link-op $n0 $n1 orient right-down



#Create a UDP agent and attach it to node n0
set udp0 [new Agent/UDP]
$nss attach-agent $n0 $udp0

# Create a CBR traffic source and attach it to udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

set null0 [new Agent/Null] 
$nss attach-agent $n1 $null0


$nss connect $udp0 $null0


$nss at 0.5 "$cbr0 start"
$nss at 1.0 "$cbr0 stop"
$nss at 1.5 "$cbr0 start"
$nss at 2.0 "$cbr0 stop"



#The next step is to add a 'finish' procedure that closes the trace file and starts nam.
proc finish {} {
        global nss nff
        $nss flush-trace
        close $nff
        exec nam out.nam &
        exit 0
}


#The last line finally starts the simulation.
$nss run
