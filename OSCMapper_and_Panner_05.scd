
~bootTheServer.();
~numVoices = 64;
~configDSP.();

~lowerLimitPlayground = (45.506792)@(-73.568541);
~upperLimitPlayground = (45.508117)@(-73.566205);

~positioningSetup.();

~loadOSCResponders.();
~oscVerbose = false;
~oscVerbose = true;
OSCdef.trace(true);
OSCdef.trace(false);

~monitorWindow.()
~refreshTask.stop;
~refreshTask.start;


(
~bootTheServer = {
Server.killAll;
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

// o.numInputBusChannels = 9; // Set nuber of input channels
// o.numOutputBusChannels = 9; // Set nuber of output channels

o.numAudioBusChannels = 2048 * 2; // these are the internal max number of audiobusses
o.blockSize = 512 * 2; // the blocksize
o.numWireBufs = 1024 * 4; // number of wired buffers
o.memSize = 2.pow(18); // the memory of the server
o.sampleRate = 48000;
o.threads_(8); // the number of threads supernova is using
s.reboot; // reboot (kill existing server, if running)
};

~configDSP =
{
s.doWhenBooted ({
		s.makeWindow; // make a Window
		s.scope(9, 0, 4096, 2); // make a scope window with 64 channels starting at channel 64,
		s.plotTree; // plot the DSP Tree

Routine.run
{		s.sync;

	SynthDef(\pannerAzDist,
	{|az = 0.78539816339745, dist =1, gain = 0, out= 6, freq = 880, delay = 0.5|
     var pannedSig, in;
			in = DelayN.ar( BPF.ar( Decay.ar(Impulse.ar(2), 0.05, PinkNoise.ar(1)), freq, 0.002, 10), 3.0, delay);
			pannedSig = HOAEncoder.ar(1, in , az.varlag(0.1), 0, 1, dist.varlag(0.1));
			Out.ar(out, pannedSig * gain)
		}).add;

	    s.sync;

	SynthDef(\pannerAzDistIn,
	{|az = 0.78539816339745, elev = 0, gain = 0.1, ir_out= 6, ir_inBus = 0|
     var pannedSig, in;
			in = SoundIn.ar(ir_inBus);
			pannedSig = HOAEncoder.ar(1, in , az.varlag(0.1), elev.varlag(0.1), 0, 0);
			Out.ar(ir_out, pannedSig * gain)
		}).add;

		s.sync;

		~decoderGroup = ParGroup.new();

		s.sync;

			~decoder = {|azi|
		           var sig, rotated, decoded;
		           sig = In.ar(6,4);
		           rotated = HOATransRotateAz.ar(1, sig, azi);
		           decoded = HOADecBinaural.ar(1, rotated, 0, 0);
		           // [decoded, sig].flatten;
				   Out.ar(0,[sig,decoded].flatten);
	            }.play(~decoderGroup);
	    s.sync;

		~parPanners = ParGroup.new();

	    s.sync;

	   ~sources = {|i| Synth(\pannerAzDistIn,
		 [\az, 2pi.rand,
	      \elev, (pi * 0.5).rand,
		  \inBus, i,
		  // \dist, 0.1+ 200.rand,
		  \gain, 1,
		  \freq, i.linexp(0,~numVoices, 200, 2000),
		 //  \delay, i.linlin(0,~numVoices, 0.0, 0.5)
		 //  \delay, 0.5.rand
		] ,	~parPanners, \addToHead )}!~numVoices;

	s.sync;
} // close Routine run
	} ) // close doWhenBooted
};


~toMeters = {|pointLonLatElev|
	Cartesian((pointLonLatElev.y - ~longMid) * ~mPerDegLon,
		      (pointLonLatElev.x - ~latMid) * ~mPerDegLat,
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

		~sources.do( {|item, i| item.set(\az, ~relSourcePositionsSpherical[i].theta,	 \elev, ~relSourcePositionsSpherical[i].phi ) });
		if(~oscVerbose,{msg.postln});
	    },("/listener").asSymbol, nil);
};

~drawArrow ={|rotation = 0, x = 200, y = 200, dotSize = 8|
	Pen.color = Color.red;
	Pen.translate(x,y); // 0@0 is now 200@100
	Pen.rotate(rotation);
    Pen.addWedge((0)@(0), dotSize, 0.4pi, 0.2pi);
    Pen.perform(\fill);
	Pen.rotate(rotation.neg);
	Pen.translate(x.neg,y.neg);
};


~monitorWindow = {

~visualize = true;
~refreshTask = Task({inf.do({ if((w != nil) && ~visualize, {w.refresh} ); 0.02.wait; }); },AppClock).start;
~canvasSize = 600;

	~scaleDown = 0.4;

w = Window.new("HOA Scene Test", Rect(10,10,~canvasSize * 2,~canvasSize));
w.front;

w.drawFunc = {
    Pen.use {
		var dotSize, xL, yL, scale, halfDotSize;
		dotSize = 8;
		halfDotSize = dotSize * 0.5;
		scale = 50;

		~absSourcePositionsMeters.do(
			{|item, i|var x, y;
				x = item.x.linlin( ~playGroundDiameter * -0.5, ~playGroundDiameter * 0.5, ~canvasSize * ~scaleDown.neg , ~canvasSize * ~scaleDown );
				y = item.y.linlin( ~playGroundDiameter * -0.5, ~playGroundDiameter * 0.5, ~canvasSize * ~scaleDown.neg , ~canvasSize * ~scaleDown );
		Pen.color = Color.hsv(~relSourcePositionsSpherical[i].theta.abs.linlin(0,pi, 0.0, 1.0), 1 , 1 , 1);
		Pen.addArc((x + (~canvasSize * 0.5))@(y+(~canvasSize * 0.5)), dotSize, 2pi, 2pi);
        Pen.perform(\stroke);
        i.asString.drawCenteredIn(Rect(x + (~canvasSize * 0.5) - halfDotSize,y + (~canvasSize * 0.5) - halfDotSize,dotSize,dotSize), Font("Times", 8), Color.black);
		});
		// draw Listener:
		xL = ~listenerPositionMeters.x.linlin( ~playGroundDiameter * -0.5, ~playGroundDiameter * 0.5, ~canvasSize * ~scaleDown.neg , ~canvasSize * ~scaleDown );
	    yL = ~listenerPositionMeters.y.linlin( ~playGroundDiameter * -0.5, ~playGroundDiameter * 0.5, ~canvasSize * ~scaleDown.neg , ~canvasSize * ~scaleDown );
		~drawArrow.(~listenerOrientation, xL + (~canvasSize * 0.5), yL + (~canvasSize * 0.5), dotSize * 2);


		~relSourcePositionsMeters.do(
			{|item, i|var x, y;
				x = item.x.linlin( ~playGroundDiameter * -1.0, ~playGroundDiameter * 1.0, ~canvasSize * ~scaleDown.neg * 2, ~canvasSize * ~scaleDown * 2);
				y = item.y.linlin( ~playGroundDiameter * -1.0, ~playGroundDiameter * 1.0, ~canvasSize * ~scaleDown.neg * 2, ~canvasSize * ~scaleDown * 2);

	    Pen.color = Color.hsv(~relSourcePositionsSpherical[i].theta.abs.linlin(0,pi, 0.0, 1.0), 1 , 1 , 1);
		Pen.addArc((x + (~canvasSize + (~canvasSize * 0.5)))@(y+(~canvasSize * 0.5)), dotSize, 2pi, 2pi);
        Pen.perform(\stroke);
        i.asString.drawCenteredIn(Rect(x + (~canvasSize + (~canvasSize * 0.5)) - halfDotSize,y + (~canvasSize * 0.5) - halfDotSize,dotSize,dotSize), Font("Times", 8), Color.black);

			});
		// draw Listener:
		xL = (~canvasSize + (~canvasSize * 0.5));
	    yL = (~canvasSize * 0.5);
		~drawArrow.(0, xL, yL, dotSize * 2);
    };
};
w.refresh;
}
)




~relSourcePositionsSpherical[0].phi.abs.linlin(0,pi, 0.0, 1.0)
Color.hsv( ~relSourcePositionsSpherical[0].phi.abs.linlin(0,pi, 0.0, 1.0), 1 , 1 , 1);