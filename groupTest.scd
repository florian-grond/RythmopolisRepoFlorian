n = NetAddr



n = NetAddr("10.37.254.133 134", 57110);
n.ip;


NetAddr.broadcastFlag_(true)

n.broadcastFlag = true;



n = NetAddr("localhost", 57110);
n.ip;

n.isLocal

10.37.254.133.

OSCdef.newMatching(\test1, {|msg, time, addr, recvPort| msg.postln}, '/source/1', n);


