
~bootTheServer.();
~numVoices = 64;
~configDSP.();

~lowerLimitPlayground = (45.506792)@(-73.568541);
~upperLimitPlayground = (45.508117)@(-73.566205);

~positioningSetup.();

~loadOSCResponders.();
~oscVerbose = false;
~oscVerbose = true;
OSCdef.trace_(true);
OSCdef.trace_(false);


(
~bootTheServer =
{

Server.killAll;

// execute this section to configure and boot the sound server
s = Server.internal; // Server.internal;
Server.supernova;
// Server.scsynth;
// ServerOptions.devices;  // this line lists all available audio devices works only on Mac
Server.internal = Server.default; // set the launched server to be the default server to make sure the masseages go to the right place
o = Server.internal.options; // Get the local server's options
// check what is listed as output from ServerOptions.devices and set the device correctly
o.device = nil;
// o.device = "112D";

o.numInputBusChannels = 64; // Set nuber of input channels
o.numOutputBusChannels = 64; // Set nuber of output channels

o.numAudioBusChannels = 2048 * 8; // these are the internal max number of audiobusses
o.blockSize = 512 * 1; // the blocksize
o.numWireBufs = 1024 * 8; // number of wired buffers
o.memSize = 2.pow(18); // the memory of the server
o.sampleRate = 48000;
o.threads_(16); // the number of threads supernova is using
s.reboot; // reboot (kill existing server, if running)

};

~configDSP =
{
s.doWhenBooted ({
		s.makeWindow; // make a Window
		s.scope(64, 64, 4096, 2); // make a scope with 9 channels starting at channel 0, window
		s.plotTree;

Routine.run
{		s.sync;

	SynthDef(\pannerAzDist,
	{|az = 0.78539816339745, dist =1, gain = 0, out= 6, freq = 880, delay = 0.5|
     var pannedSig, in;
			in = DelayN.ar( BPF.ar( Decay.ar(Impulse.ar(2), 0.05, PinkNoise.ar(1)), freq, 0.002, 10), 3.0, delay);
			pannedSig = HOAEncoder.ar(1, in , az.varlag(5), 0, 1, dist.varlag(5));
			Out.ar(out, pannedSig * gain)
		}).add;

	    s.sync;

	SynthDef(\pannerAzDistIn,
	{|az = 0.78539816339745, dist =1, gain = 0, out= 6, inBus = 0, freq = 880, delay = 0.5|
     var pannedSig, in;
			in = SoundIn.ar(inBus);
			pannedSig = HOAEncoder.ar(1, in , az.varlag(0.1), 0, 1, 0);
			Out.ar(out, pannedSig * gain)
		}).add;

		s.sync;

		~decoderGroup = ParGroup.new();

		s.sync;

			~decoder = {|azi|
		           var sig, rotated, decoded;
		           sig = In.ar(6,4);
		           rotated = HOATransRotateAz.ar(1, sig, azi);
		           decoded = HOADecBinaural.ar(1, rotated, 0, 0);
		          [sig + decoded].flatten * 0.1
	            }.play(~decoderGroup);
	    s.sync;

		~parPanners = ParGroup.new();

	    s.sync;

	   ~sources = {|i| Synth(\pannerAzDistIn,
		 [\az, 2pi.rand,
	      \elev, (pi * 0.5).rand,
		  \inBus, i,
		  // \dist, 0.1+ 200.rand,
		  // \gain, 0.1,
		  \freq, i.linexp(0,~numVoices, 200, 2000),
		 //  \delay, i.linlin(0,~numVoices, 0.0, 0.5)
		 //  \delay, 0.5.rand
		]
		,
		~parPanners, \addToHead )}!~numVoices;


	s.sync;
}
}
)
};


~toMeters = {|pointLonLatElev|
	Cartesian((pointLonLatElev.x - ~latMid) * ~mPerDegLon,
		      (pointLonLatElev.y - ~longMid) * ~mPerDegLat,
		       pointLonLatElev.z - ~elevMid);
             };

~absToRelAllSources = {~absSourcePositionsMeters.collect({|item,i|
		                             (item - ~listenerPositionMeters).rotate(~listenerOrientation.neg)
	                                   });};


~absToRelSource = {|cartAbsSourcePos| (cartAbsSourcePos - ~listenerPositionMeters).rotate(~listenerOrientation.neg) };

~positioningSetup=
{
// the values are calculated from this website:
// http://www.csgnetwork.com/degreelenllavcalc.html

~middlePlayground = ~lowerLimitPlayground + ((~upperLimitPlayground - ~lowerLimitPlayground) * 0.5);

~latMid = ~middlePlayground.x;
~longMid = ~middlePlayground.y;
~elevMid = 0;

// here are the formulas
~latMidRad = ~latMid * (pi/180);
~mPerDegLat = 111132.954 - (559.822 * ( 2 * ~latMidRad ).cos) + (1.175 * ( 4 * ~latMidRad).cos);
~mPerDegLon =  111412.84  * ( ~latMidRad ).cos -  (93.5 * (3*~latMidRad).cos);


~absSourcePositionsLongLat = {Cartesian(1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
		                         1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
		                         10.0.rand)
	                   }!~numVoices;  // make an array of numVoices

~absSourcePositionsMeters = ~absSourcePositionsLongLat.collect({|item,i| ~toMeters.(item) });

~listenerPositionLongLat = Cartesian(1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
		                         1.0.rand.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
		                         0.0);
~listenerPositionMeters = ~toMeters.(~listenerPositionLongLat) ;

~listenerOrientation = 0.0;

~relSourcePositionsMeters = ~absToRelAllSources.();

~relSourcePositionsSpherical = ~relSourcePositionsMeters.collect({|item,i| item.asSpherical });

~aCornerMeters = ~toMeters.(Cartesian(~upperLimitPlayground.x, ~upperLimitPlayground.y, 0.0));
~bCornerMeters = ~toMeters.(Cartesian(~lowerLimitPlayground.x, ~lowerLimitPlayground.y, 0.0));

~playGroundDiameter = ~aCornerMeters.dist(~bCornerMeters);

};



~loadOSCResponders =
{
~oscVerbose = false;

OSCdef.freeAll;

{|i|
OSCdef.newMatching(("pos"++i).asSymbol, {|msg, time, addr, recvPort|
			// register Lat Long Elev
		~absSourcePositionsLongLat[i].x = msg[1];
		~absSourcePositionsLongLat[i].y = msg[2];
		~absSourcePositionsLongLat[i].z = msg[3];
            // convert to Meters
		~absSourcePositionsMeters[i] = ~toMeters.(~absSourcePositionsLongLat[i]).deepCopy;
			// convert to Relative Position
		~relSourcePositionsMeters[i] = ~absToRelSource.(~absSourcePositionsMeters[i]);
			// convert to Relative Spherical
		~relSourcePositionsSpherical[i] = ~relSourcePositionsMeters[i].asSpherical;
		// ~sources[i].set(\az, msg[1], \dist,  msg[2]);
		if(~oscVerbose,{msg.postln});
	}, ("/source/"++i++"/pos").asSymbol, nil);
	}!~numVoices;


OSCdef.newMatching(("listener").asSymbol, {|msg, time, addr, recvPort|
				   // register Lat Long Elev
		~listenerPositionLongLat.x = msg[1];
		~listenerPositionLongLat.y = msg[2];
		~listenerPositionLongLat.z = msg[3];
			       // register Azimuth Orientation
	    ~listenerOrientation = msg[4];
                   // convert Listener Position To Meters
		~listenerPositionMeters = ~toMeters.(~listenerPositionLongLat) ;
		           // update all Sources to New realtive Positions
		~relSourcePositionsMeters = ~absToRelAllSources.();
                   // convert ALL to Relative Spherical
        ~relSourcePositionsSpherical = ~relSourcePositionsMeters.collect({|item,i| item.asSpherical });

		if(~oscVerbose,{msg.postln});
	    },("/listener").asSymbol, nil);
};
)






)





if((w != nil) && ~visualize, {w.refresh} );


(
~visualize = false;
~visualize = true;
~absSourcePositions = {Cartesian(1.0.rand.linlin(0.0, 1.0, 45.506792,45.508117),1.0.rand.linlin(0.0, 1.0, -73.566205,-73.568541),10.rand)}!~numVoices;



)



~task.start

~task.stop


~task = Task({
	~counter = 1;
    inf.do({
		~counter = ~counter + 0.005;
		if (~counter > 2pi,{~counter = 0});
		m.sendMsg("/listener", (~counter.cos *0.5).linlin(-1.0, 1.0, 45.506792,45.508117), (~counter.sin).linlin(-1.0, 1.0, -73.566205,-73.568541), (~counter * 4).sin);

		if((w != nil) && ~visualize, {w.refresh} );
        0.02.wait;
    });
},AppClock).stop;


w = Window.new("HOA Scene Test", Rect(200,200,900,450));
~visualize = true;
// ~numVoices = 10;


if((w != nil) && ~visualize, {w.refresh} );



(
w.front;

~drawArrow ={|rotation = 0, x = 200, y = 200, scale = 0.15|
    Pen.fillColor = Color.red;
	Pen.translate(x,y); // 0@0 is now 200@100
	Pen.scale(scale, scale);
	Pen.rotate(rotation);
	Pen.rotate(pi);
	// Pen.scale(1);
	Pen.translate(0,-100);
    Pen.moveTo(0@0);
    Pen.lineTo(50@100);
    Pen.lineTo(100@100);
    Pen.lineTo(0@150);
    Pen.lineTo(-100@100);
    Pen.lineTo(-50@100);
    Pen.lineTo(0@0);
    Pen.fill;
	Pen.translate(0,100);
	Pen.rotate(-pi);
	Pen.rotate(rotation.neg);
	Pen.scale(scale.reciprocal, scale.reciprocal);
	Pen.translate(x.neg,y.neg); // 0@0 is now 200@100
};


/*
~drawArrow ={|rotation = 0, x = 200, y = 200, scale = 0.1|
	Pen.fillColor = Color.red;
    Pen.addOval(Rect(x - 2.5,y - 2.5,5, 5));
	Pen.strokeColor = Color.red;
	Pen.moveTo(x@y);
	Pen.rotate(rotation);
	Pen.lineTo((x + 100)@y);
	Pen.rotate(rotation.neg);
	Pen.fill;
	Pen.fillStroke;
};
*/




w.drawFunc = {
    Pen.use {
		var dotSize, xL, yL, scale, relBounds;
		dotSize = 10;
		scale = 50;
		relBounds = 300;

		~absSourcePositions.do(
			{|item, i|var x, y;
				x = item.x.linlin(45.506792, 45.508117, scale.neg * ~normalCorrection, scale * ~normalCorrection);
				y = item.y.linlin(-73.568541, -73.566205, scale.neg, scale);
        //Pen.translate(0, 0);
        Pen.addOval(Rect(x + 200,y + 200,dotSize,dotSize));
		Pen.fillAxialGradient(w.view.bounds.leftTop, w.view.bounds.rightBottom, Color.blue, Color.blue);
        i.asString.drawCenteredIn(Rect(x + 200,y + 200,dotSize,dotSize), Font("Monaco", 8), Color.white);
		});
		// draw Listener:
		xL = ~listenerPositions.x.linlin(45.506792,45.508117, scale.neg * ~normalCorrection, scale * ~normalCorrection);
	    yL = ~listenerPositions.y.linlin(-73.568541, -73.566205, scale.neg, scale);
		~drawArrow.(~listenerOrientation, xL + 200, yL + 200);

		~relSourcePositions.do(
			{|item, i|var x, y;
				x = item.x.linlin(relBounds.neg, relBounds, scale.neg * 2, scale * 2);
				y = item.y.linlin(relBounds.neg, relBounds, scale.neg * 2, scale * 2);
        //Pen.translate(450, 0);
        Pen.addOval(Rect(x + 650,y + 200,dotSize,dotSize));
		Pen.fillAxialGradient(w.view.bounds.leftTop, w.view.bounds.rightBottom, Color.blue, Color.blue);
        i.asString.drawCenteredIn(Rect(x + 650,y + 200,dotSize,dotSize), Font("Monaco", 8), Color.white);
		});
		// draw Listener:
		xL = 200.0;
	    yL = 200.0;
		~drawArrow.(0, xL + 450, yL);
    };
};
w.refresh;
)






~absSourcePositions.do({|item,i| item.x.linlin(45.506792,45.508117, 50.neg, 50).postln})



~absSourcePositions.do({|item,i| item.y.linlin(-73.568541, -73.566205, 50.neg, 50).postln})


~relSourcePositionsSpherical


Spherical
