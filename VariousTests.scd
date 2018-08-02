

~oscVerbose = false;
~oscVerbose = true;
OSCdef.trace_(true);
OSCdef.trace_(false);

m = NetAddr("127.0.0.1", 57120); // loopback
(
~numVoices.do( {|i| m.sendMsg("/source/"++i++"/pos",
	                     1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                     1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                     10.0.rand;
) } );
)

(
 m.sendMsg("/source/0/pos",
	                     1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                     1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                     10.0.rand; );
["LatLong", ~absSourcePositionsLongLat[0]].postln;
["Meters", ~absSourcePositionsMeters[0]].postln;
["RelMeters", ~relSourcePositionsMeters[0]].postln;
["RelSpherical", ~relSourcePositionsSpherical[0]].postln;
)




(
 m.sendMsg("/source/1/pos",
	                     1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                     1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                     10.0.rand; )
)

(
m.sendMsg("/source/2/pos",
	                     1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                     1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                     10.0.rand; )
)





m.sendMsg("/listener", 1.0.rand2, 1.0.rand2, pi.rand2);










~absSourcePositionsLongLat[0] = Cartesian(1.0.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
		                         1.0.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
		                         0.rand)

~toMeters.(~absSourcePositionsLongLat[0])
