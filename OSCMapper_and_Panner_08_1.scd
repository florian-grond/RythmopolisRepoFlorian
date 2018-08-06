(

~oscVerbose = true;
~refreshTask.stop;

~busOffset = 0;

~numVoices = 64 - ~busOffset;


~window = true;


~lowerLimitPlayground = (-73.568541)@(45.506792);
~upperLimitPlayground = (-73.566205)@(45.508117);


~bootTheServer = {

Server.killAll;

s = Server.local; // Server.internal;
//  Server.supernova;
Server.scsynth;
// ServerOptions.devices;  // this line lists all available audio devices works only on Mac
Server.default = Server.local; // set the launched server to be the default server to make sure the masseages go to the right place
o = Server.local.options; // Get the local server's options
// check what is listed as output from ServerOptions.devices and set the device correctly
o.device = nil;
// o.device = "JackRouter";
o.numInputBusChannels = 64; // Set nuber of input channels
o.numOutputBusChannels = 64; // Set nuber of output channels

o.numAudioBusChannels = 2048 * 1; // these are the internal max number of audiobusses
o.blockSize = 128 * 2; // the blocksize
o.numWireBufs = 1024 * 4; // number of wired buffers
o.memSize = 8192 * 1; // the memory of the server
o.sampleRate = 48000;
// o.threads_(1); // the number of threads supernova is using

s.reboot; // reboot (kill existing server, if running)

};

~configDSP =
{|testOnLaptop|
s.doWhenBooted ({


Routine.run{

  ~binauralDecoder = FoaDecoderKernel.newCIPIC;
  ~micAngle = (131/2).degrad; // at 131 deg
  ~micPattern = 0.5; // Cardioids
  // ~binauralDecoder = FoaDecoderMatrix.newStereo(~micAngle, ~micPattern);
  ~converterMatrix = FoaEncoderMatrix.newHoa1(\acn, \sn3d);

s.sync;

~decoder = {|monitorAz1 = 0, monitorElev1 = 0, monitorAz2 = 0, monitorElev2 = 0|
		           var sig, bFormatSN3D, adjust, rotatedFieldMonitor1, rotatedFieldMonitor2, binauralMonitor1, binauralMonitor2 ;
		           sig = In.ar(11,4) ;
				   adjust   = FoaRotate.ar(sig, -0.5pi) ;
				   // bFormatSN3D = HOAConverterFuma2AcnSn3d.ar( 1, adjust ) ;
				   bFormatSN3D = [adjust[0] * 2.sqrt, adjust[2], adjust[3]  * -1, adjust[1] * -1];
				   rotatedFieldMonitor1 =  FoaRotate.ar( adjust, monitorAz1 ) ;
				   rotatedFieldMonitor2 =  FoaRotate.ar( adjust, monitorAz2     ) ;
				   binauralMonitor1     =  FoaDecode.ar( rotatedFieldMonitor1 , ~binauralDecoder)   ;
				   binauralMonitor2     =  FoaDecode.ar( rotatedFieldMonitor2 ,  ~binauralDecoder ) ;
				   Out.ar(0,[binauralMonitor1, binauralMonitor2, bFormatSN3D,  SoundIn.ar( [0,1]) ].flatten );
				   // Out.ar(0,[SoundIn.ar( [0,1]), bFormatSN3D, binauralMonitor1].flatten );
			       }.play;


s.sync;

~sources = {}!~numVoices;



if(testOnLaptop,
				{
                  ~numVoices.do({|item,i |
	              ~sources[i] =
	              {|az = 0.0, elev = 0, gain = 0.1, i_out= 11, i_inBus = 0|
                  var pannedSig, in;
                  in = In.ar(20, 1);
                  // pannedSig = HOAEncoder.ar(1, in , az, elev, 0, 0);
		          pannedSig = FoaPanB.ar(in , az , elev);
	              // pannedSig = FoaEncode.ar(in, FoaEncoderMatrix.newDirection(az,elev) );
	              Out.ar(i_out, pannedSig * gain)
                  }.play;
                  s.sync;
		          });
				 }
				,
				{
                  ~numVoices.do({|item,i |
	              ~sources[i] =
	              {|az = 0.0, elev = 0, gain = 0.1, i_out= 11, i_inBus = 0|
                  var pannedSig, in;
				  in = SoundIn.ar(i + ~busOffset);
                  // pannedSig = HOAEncoder.ar(1, in , az, elev, 0, 0);
		          pannedSig = FoaPanB.ar(in , az , elev);
	              // pannedSig = FoaEncode.ar(in, FoaEncoderMatrix.newDirection(az,elev) );
	              Out.ar(i_out, pannedSig * gain)
                  }.play;
                  s.sync;
		          });
				 }
			);







{ Out.ar(20, /* WhiteNoise.ar(0.1) */  SinOsc.ar(440, 0, 1) );}.play;


        ~lowerLimitPlayground = (-73.568541)@(45.506792);
        ~upperLimitPlayground = (-73.566205)@(45.508117);
        ~positioningSetup.();
        ~loadOSCResponders.();
			if(~window, { {~monitorWindow.();}.defer; });
			if(~window, { ~refreshTask.start; });



}



/*


Routine.run
{
		{
		s.makeWindow; // make a Window
		s.scope(10,0, 4096, 2); // make a scope window with 64 channels starting at channel 64,
		s.plotTree; // plot the DSP Tree
		}.defer;

		//~converterMatrix = FoaEncoderMatrix.newHoa1(\acn, \sn3d);
	    ~binauralDecoder = FoaDecoderKernel.newCIPIC;
        ~micAngle = (131/2).degrad; // at 131 deg
        ~micPattern = 0.5; // Cardioids
		~binauralDecoder = FoaDecoderMatrix.newStereo(~micAngle, ~micPattern);

	    s.sync;

	if(testOnLaptop,
				{
				SynthDef(\pannerAzDistIn,
	            {|az = 0.78539816339745, elev = 0, gain = 0.1, i_out= 11, i_inBus = 0|
                 var pannedSig, in;
			     in = In.ar(20, 1);
			     // pannedSig = HOAEncoder.ar(1, in , az, elev, 0, 0);
				 pannedSig = FoaPanB.ar(in , az, elev);
				 // pannedSig = FoaEncode.ar(in, FoaEncoderMatrix.newDirection(az,elev) );
			     Out.ar(i_out, pannedSig * gain)
		         }).add;
				}
				,
				{
	            SynthDef(\pannerAzDistIn,
	            {|az = 0.78539816339745, elev = 0, gain = 0.1, i_out= 11, inBus = 0|
                var pannedSig, in;
			    in = SoundIn.ar(inBus + 2);
			    // pannedSig = HOAEncoder.ar(1, in , az, elev, 0, 0);
				 pannedSig = FoaPanB.ar(in , az, elev);
				// pannedSig = FoaEncode.ar(in, FoaEncoderMatrix.newDirection(az,elev) );
			    Out.ar(i_out, pannedSig * gain)
		        }).add;
				}
			);

		s.sync;

		~decoderGroup = Group.new();

		s.sync;

	    ~monitorAz1 = 0; ~monitorAz2 = 0; ~monitorElev1 = 0; ~monitorElev2 = 0;

		~decoder = {|monitorAz1 = 0, monitorElev1 = 0, monitorAz2 = 0, monitorElev2 = 0|
		           var sig, bFormatSN3D, adjust, rotatedFieldMonitor1, rotatedFieldMonitor2, binauralMonitor1, binauralMonitor2 ;
		           sig = In.ar(11,4) ;
				   adjust   = FoaRotate.ar(sig, -0.5pi) ;
				   bFormatSN3D = HOAConverterFuma2AcnSn3d.ar( 1, adjust ) ;
				rotatedFieldMonitor1 =  FoaRotate.ar( adjust, monitorAz1.neg ) ;
				rotatedFieldMonitor2 =  FoaRotate.ar( adjust, monitorAz2     ) ;
				binauralMonitor1     =  FoaDecode.ar( rotatedFieldMonitor1 , ~binauralDecoder)   ;
				binauralMonitor2     =  FoaDecode.ar( rotatedFieldMonitor2 ,  ~binauralDecoder ) ;
				//Out.ar(0,[binauralMonitor1, binauralMonitor2, bFormatSN3D,  SoundIn.ar( [0,1]) ].flatten );
				Out.ar(0,[SoundIn.ar( [0,1]), bFormatSN3D, binauralMonitor1].flatten );
			   }.play(~decoderGroup);
	    s.sync;

		~parPanners = Group.new();

		s.sync;
			if(testOnLaptop,{~testSine = { Out.ar(20, /*WhiteNoise.ar(0.1) */  SinOsc.ar(440, 0, 1) );}.play(~parPanners);});
	    s.sync;

	   ~sources = {|i| Synth(\pannerAzDistIn,
		 [\az, 2pi.rand,
	      \elev, 0,
		  \inBus, i,
		  \gain,0.015,
		] ,	~parPanners, \addToHead )}!~numVoices;
	    s.sync;



    } // close Routine run



		*/






	} ) // close doWhenBooted
};


~toMeters = {|pointLonLatElev|
	Cartesian((pointLonLatElev.x - ~longMid) * ~mPerDegLon,
		      (pointLonLatElev.y - ~latMid) * ~mPerDegLat.neg,
		       pointLonLatElev.z - ~elevMid);
             };

~absToRelAllSources = {~absSourcePositionsMeters.collect({|item,i|
		                             (item - ~listenerPositionMeters).rotate(~listenerOrientationAz.neg)
	                                   });};

~absToRelSource = {|cartAbsSourcePos| (cartAbsSourcePos - ~listenerPositionMeters).rotate(~listenerOrientationAz.neg) };

~positioningSetup=
{
// the values are calculated from this website:
// http://www.csgnetwork.com/degreelenllavcalc.html
~middlePlayground = ~lowerLimitPlayground + ((~upperLimitPlayground - ~lowerLimitPlayground) * 0.5);

~longMid = ~middlePlayground.x;
~latMid  = ~middlePlayground.y;
~elevMid = 0;

// here are the formulas
~latMidRad = ~latMid * (pi/180);
~mPerDegLat = 111132.954 - (559.822 * ( 2 * ~latMidRad ).cos) + (1.175 * ( 4 * ~latMidRad).cos);
~mPerDegLon =  111412.84  * ( ~latMidRad ).cos -  (93.5 * (3*~latMidRad).cos);


~absSourcePositionsLongLat = {Cartesian(0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
		                         0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
		                         0.0.rand)
	                   }!~numVoices;  // make an array of numVoices

~absSourcePositionsMeters = ~absSourcePositionsLongLat.collect({|item,i| ~toMeters.(item) });

~listenerPositionLongLat = Cartesian(0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
		                         0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
		                         0.0);
~listenerPositionMeters = ~toMeters.(~listenerPositionLongLat) ;

~listenerOrientationAz = 0.0;
~listenerOrientationEle = 0.0;

~relSourcePositionsMeters = ~absToRelAllSources.();

~relSourcePositionsSpherical = ~relSourcePositionsMeters.collect({|item,i| item.asSpherical });

~aCornerMeters = ~toMeters.(Cartesian(~upperLimitPlayground.x, ~upperLimitPlayground.y, 0.0));
~bCornerMeters = ~toMeters.(Cartesian(~lowerLimitPlayground.x, ~lowerLimitPlayground.y, 0.0));

~playGroundDiameter = ~aCornerMeters.dist(~bCornerMeters);

};





~loadOSCResponders =
{
OSCdef.freeAll;

{|i|
OSCdef.newMatching(("pos"++i).asSymbol, {|msg, time, addr, recvPort|
			// register Lat Long Elev
		~absSourcePositionsLongLat[i].x = msg[1];
		~absSourcePositionsLongLat[i].y = msg[2];
		~absSourcePositionsLongLat[i].z = msg[3];
            // convert to Meters
		~absSourcePositionsMeters[i] = ~toMeters.(~absSourcePositionsLongLat[i]);
			// convert to Relative Position
		~relSourcePositionsMeters[i] = ~absToRelSource.(~absSourcePositionsMeters[i]);
			// convert to Relative Spherical
		~relSourcePositionsSpherical[i] = ~relSourcePositionsMeters[i].asSpherical;
		~sources[i].set(\az, ~relSourcePositionsSpherical[i].theta,	 \elev, ~relSourcePositionsSpherical[i].phi );

		// ~sources.do( {|item, i| item.set(\az, ~relSourcePositionsSpherical[i].theta,	 \elev, ~relSourcePositionsSpherical[i].phi ) });

		if(~oscVerbose,{msg.postln});
	}, ("/source/"++i++"/pos").asSymbol, nil);
	}!~numVoices;


OSCdef.newMatching(("listener").asSymbol, {|msg, time, addr, recvPort|
				   // register Lat Long Elev
		~listenerPositionLongLat.x = msg[1];
		~listenerPositionLongLat.y = msg[2];
		~listenerPositionLongLat.z = msg[3];
			       // register Azimuth Orientation
	    ~listenerOrientationAz = msg[4];
	    ~listenerOrientationEle = msg[5];
                   // convert Listener Position To Meters
		~listenerPositionMeters = ~toMeters.(~listenerPositionLongLat) ;
		           // update all Sources to New realtive Positions
		~relSourcePositionsMeters = ~absToRelAllSources.();
                   // convert ALL to Relative Spherical
        ~relSourcePositionsSpherical = ~relSourcePositionsMeters.collect({|item,i| item.asSpherical });

		~sources.do( {|item, i| item.set(\az, ~relSourcePositionsSpherical[i].theta,	 \elev, ~relSourcePositionsSpherical[i].phi ) });
		if(~oscVerbose,{msg.postln});
	    },("/listener").asSymbol, nil);


OSCdef.newMatching(("monitor1").asSymbol, {|msg, time, addr, recvPort|
				   // register Lat Long Elev
		~monitorAz1 = msg[1];
		~monitorElev1 = msg[2];

		~decoder.set(\monitorAz1, msg[1], \monitorElev1, msg[2] );
		if(~oscVerbose,{msg.postln});
	    },("/monitor1").asSymbol, nil);


OSCdef.newMatching(("monitor2").asSymbol, {|msg, time, addr, recvPort|
				   // register Lat Long Elev
		~monitorAz2 = msg[1];
		~monitorElev2 = msg[2];

		if(~oscVerbose,{msg.postln});
	    },("/monitor2").asSymbol, nil);
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
~refreshTask = Task({inf.do({ if((w != nil) && ~visualize, {w.refresh} ); 0.3.wait; }); },AppClock).stop;
~canvasSize = 600;

~scaleDown = 0.4;

w = Window.new("HOA Scene Test", Rect(10,10,~canvasSize * 2,~canvasSize));
w.front;

m = NetAddr("127.0.0.1", 57120);

	~slider2D = Slider2D(w, Rect(~canvasSize * 0.17,
		                         ~canvasSize * 0.23,
		                         ~canvasSize * 0.66,
		                         ~canvasSize * 0.54)).y_(0.5).x_(0.5)
	            .background_(Color(1,1,1,0))
            .knobColor_(Color(1,1,1,0))
	            .action_({|sl| // [sl.x, sl.y].postln;

		m.sendMsg("/listener",  sl.x.linlin(0.0, 1.0, ~lowerLimitPlayground.x ,~upperLimitPlayground.x, nil ),
	                            sl.y.linlin(0.0, 1.0, ~lowerLimitPlayground.y ,~upperLimitPlayground.y, nil ),
	                    0.0,
			0;)

	});

/*
	~monitorSlider = EZSlider(w, Rect(~canvasSize * 0.17,
		                            ~canvasSize * 0.9,
		                            ~canvasSize * 0.66,
		                        20), "monitorAz", ControlSpec(-pi, pi ) )
	            .setColors(Color.grey,Color.white)
	            .action_({|sl| sl.value.postln;  m.sendMsg("/monitor1", sl.value.linlin(0,1, pi, -pi) ); });

	*/


w.drawFunc = {
    Pen.use {
		var dotSize, halfDotSize, xL, yL;
		dotSize = 8;
		halfDotSize = dotSize * 0.5;

		~absSourcePositionsMeters.do(
			{|item, i|var x, y;
				x = item.x.linlin( ~playGroundDiameter * -0.5, ~playGroundDiameter * 0.5, ~canvasSize * ~scaleDown.neg , ~canvasSize * ~scaleDown );
				y = item.y.linlin( ~playGroundDiameter * -0.5, ~playGroundDiameter * 0.5, ~canvasSize * ~scaleDown.neg , ~canvasSize * ~scaleDown );
		Pen.color = Color.hsv(~relSourcePositionsSpherical[i].theta.linlin(-pi,pi, 0.0, 1.0), 1 , 1 , 1);
		Pen.addArc((x + (~canvasSize * 0.5))@(y+(~canvasSize * 0.5)), dotSize, 2pi, 2pi);
        Pen.perform(\fill);
        i.asString.drawCenteredIn(Rect(x + (~canvasSize * 0.5) - halfDotSize,y + (~canvasSize * 0.5) - halfDotSize,dotSize,dotSize), Font("Times", 8), Color.grey);
		});
		// draw Listener:
		xL = ~listenerPositionMeters.x.linlin( ~playGroundDiameter * -0.5, ~playGroundDiameter * 0.5, ~canvasSize * ~scaleDown.neg , ~canvasSize * ~scaleDown );
	    yL = ~listenerPositionMeters.y.linlin( ~playGroundDiameter * -0.5, ~playGroundDiameter * 0.5, ~canvasSize * ~scaleDown.neg , ~canvasSize * ~scaleDown );
		~drawArrow.(~listenerOrientationAz, xL + (~canvasSize * 0.5), yL + (~canvasSize * 0.5), dotSize * 4);

		~relSourcePositionsMeters.do(
			{|item, i|var x, y;
				x = item.x.linlin( ~playGroundDiameter * -1.0, ~playGroundDiameter * 1.0, ~canvasSize * ~scaleDown.neg * 2, ~canvasSize * ~scaleDown * 2);
				y = item.y.linlin( ~playGroundDiameter * -1.0, ~playGroundDiameter * 1.0, ~canvasSize * ~scaleDown.neg * 2, ~canvasSize * ~scaleDown * 2);

	    Pen.color = Color.hsv(~relSourcePositionsSpherical[i].theta.linlin(-pi,pi, 0.0, 1.0), 1 , 1 , 1);
		Pen.addArc((x + (~canvasSize + (~canvasSize * 0.5)))@(y+(~canvasSize * 0.5)), dotSize, 2pi, 2pi);
        Pen.perform(\fill);
        i.asString.drawCenteredIn(Rect(x + (~canvasSize + (~canvasSize * 0.5)) - halfDotSize,y + (~canvasSize * 0.5) - halfDotSize,dotSize,dotSize), Font("Times", 8), Color.black);

			});
		// draw Listener:
		xL = (~canvasSize + (~canvasSize * 0.5));
	    yL = (~canvasSize * 0.5);
		~drawArrow.(0, xL, yL, dotSize * 4);
    };
};
w.refresh;
};



~bootTheServer.();
~configDSP.(false);


)

/*

(


~positioningSetup.();
~loadOSCResponders.();
~monitorWindow.();




)


*/







