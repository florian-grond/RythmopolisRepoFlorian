

~oscVerbose = false;
~oscVerbose = true;
OSCdef.trace(true);
OSCdef.trace(false);

m = NetAddr("127.0.0.1", 57120); // loopback
(
~numVoices.do( {|i| m.sendMsg("/source/"++i++"/pos",
	                     1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                     1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                     0;
) } );
)

(
m.sendMsg("/listener",  0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                    0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                    0.0,
	                    0;

)

)




~sources.do({| item,i | item.set(\gain, 0.0)       })

~sources.do({| item,i | item.set(\gain, 0.1)       })


~sources[3].set(\gain, 1.0)




(
~numVoices.do( {|i| m.sendMsg("/source/"++i++"/pos",
	                     0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                     0.0.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                     0;
) } );
)


(
~numVoices.do( {|i| m.sendMsg("/source/"++i++"/pos",
	                     0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                     1.0.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                     0;
) } );
)


(
~numVoices.do( {|i| m.sendMsg("/source/"++i++"/pos",
	                     0.0.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                     0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                     0;
) } );
)


(
~numVoices.do( {|i| m.sendMsg("/source/"++i++"/pos",
	                     1.0.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                     0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                     0;
) } );
)


(
~numVoices.do( {|i| m.sendMsg("/source/"++i++"/pos",
	                     0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                     0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                     0;
) } );
)


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
 m.sendMsg("/source/1/pos",1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                       1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                       10.0.rand; )
)

(
m.sendMsg("/source/2/pos",1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                      1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                      10.0.rand; )
)





(
m.sendMsg("/source/2/pos", 1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                       1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                       10.0.rand; )
)




(
m.sendMsg("/listener",  1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                    1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                    10.0.rand,
	                    pi.rand2;


)

)



(
m.sendMsg("/listener",  0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                    0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                    0.0,
	                    pi.rand2;


)

)


// MOVE ALL SOURCES in a circle around the listener
(
~testTask = Task({
	~counter = 1;
    inf.do({
		~counter = ~counter + 0.1;
		if (~counter > 2pi,{~counter = 0});
         ~numVoices.do( {|i| m.sendMsg("/source/"++i++"/pos",
	                     ~counter.cos.linlin(-1.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                     ~counter.sin.linlin(-1.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                     0;
                       ) } );

		       0.2.wait;
    });
}, AppClock ).stop;

~testTask.start
)
~testTask.stop



// MAKE the Listener Rotate on the spot
(
~testTask = Task({
	~counter = 1;
    inf.do({
		~counter = ~counter + 0.1;
		if (~counter > 2pi,{~counter = 0});
		m.sendMsg("/listener",  0.0.linlin(-2.0, 2.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                            0.0.linlin(-2.0, 2.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
			                    0,
			                    ~counter,
			                    0.0
			                      );
		       0.2.wait;
    });
}, AppClock ).stop;


~testTask.start
)
~testTask.stop


// MOVE the Listener around the sources
(


(
m = NetAddr("127.0.0.1", 57120); // loopback
~numVoices.do( {|i| m.sendMsg("/source/"++i++"/pos",
	                     0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                     0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                     0;
) } );

)


~testTask = Task({
	~counter = 1;
    inf.do({
		~counter = ~counter + 0.1;
		if (~counter > 2pi,{~counter = 0});
		m.sendMsg("/listener",  ~counter.cos.linlin((-2.0, 2.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                            ~counter.sin.linlin((-2.0, 2.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
			                    0,
			                    ~counter,
			                    0.0
			                      );
		       0.2.wait;
    });
}, AppClock ).stop;


~testTask.start
)
~testTask.stop





(
~testTask = Task({
	~counter = 1;
    inf.do({
		~counter = ~counter + 0.005;
		if (~counter > 2pi,{~counter = 0});
		m.sendMsg("/listener",  ~counter.cos.linlin(-2.0, 2.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                            ~counter.sin.linlin(-2.0, 2.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
			                    0,
			                    ~counter.cos.linlin(-1,1.0, -pi, pi)
			                      );
		       0.1.wait;
    });
}, AppClock ).stop;


~testTask.start
)
~testTask.stop

~sources.do( {|item, i| item.set(\az, -0.5pi,	 \elev, 0 ) })
~sources.do( {|item, i| item.set(\az, 0.5pi,	 \elev, 0 ) })
~sources.do( {|item, i| item.set(\az, 0,	 \elev, 0 ) })
~sources.do( {|item, i| item.set(\az, pi,	 \elev, 0 ) })
~sources.do( {|item, i| item.set(\az,  pi.rand2,	 \elev, 0.5pi.rand2 ) })





