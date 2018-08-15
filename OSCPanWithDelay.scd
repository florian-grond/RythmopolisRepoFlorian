(

~oscVerbose = 0; // 1 == true;

~nrTimeCodeChannels = 0; // if you set this to zero goto Line 87 and change the out bus setting
~busOffset = ~nrTimeCodeChannels;

~binauralHead = 21; // 21 is Kemar large pinnae, set to 165 for Kemar small pinnae

~numVoices = 64 - ~busOffset;

~simulateInput = true;

~window = 1;  // 1  == true

~lowerLimitPlayground = (-73.568541)@(45.506792);
~upperLimitPlayground = (-73.566205)@(45.508117);

// here we initialize all the sources with respect to the limits of the Playground
//~initializeAllSources = [0.5,0.5];  // CENTER
 ~initializeAllSources = [0.5,1.0];  // NORTH top
// ~initializeAllSources = [0.0,0.5];  // WEST left
// ~initializeAllSources = [0.5,0.0];  // SOUTH bottom
// ~initializeAllSources = [1.0,0.5];  // EAST right

m = NetAddr("127.0.0.1", 57120); // to send message to the OSC responders from SC


~bootTheServer = {

Server.killAll;

Server.default = Server.local; // set the launched server to be the default server to make sure the masseages go to the right place
Server.scsynth;

s = Server.local; // Server.internal;

// ServerOptions.devices;  // this line lists all available audio devices works only on Mac

o = Server.local.options; // Get the local server's options
// check what is listed as output from ServerOptions.devices and set the device correctly
//o.device = nil;
o.device = "JackRouter";
o.numInputBusChannels = 64; // Set nuber of input channels
o.numOutputBusChannels = 16; // Set nuber of output channels

o.numAudioBusChannels = 2048 * 1; // these are the internal max number of audiobusses
o.blockSize = 128 * 2; // the blocksize
o.numWireBufs = 1024 * 4; // number of wired buffers
o.memSize = 8192 * 10; // the memory of the server
o.sampleRate = 48000;
// o.threads_(1); // the number of threads supernova is using

// s.reboot; // reboot (kill existing server, if running)

};


~configDSP =
{|testOnLaptop|
s.waitForBoot ({

Routine.run{

			~binauralDecoder = FoaDecoderKernel.newCIPIC(~binauralHead);
			// ~binauralDecoder = FoaDecoderKernel.newListen(~binauralHead);  // subjectID 1002 to 1059 (51 in total) WARNING: subjectIDs are not entirely contiguous.
            ~micAngle = (131/2).degrad; // at 131 deg
            ~micPattern = 0.5; // Cardioids
            // ~binauralDecoder = FoaDecoderMatrix.newStereo(~micAngle, ~micPattern);
            ~converterMatrix = FoaEncoderMatrix.newHoa1(\acn, \sn3d);

s.sync;

~decoder = {|monitorAz1 = 0, monitorElev1 = 0, monitorAz2 = 0, monitorElev2 = 0|
		           var sig, bFormatSN3D, adjust, rotatedFieldMonitor1, rotatedFieldMonitor2, binauralMonitor1, binauralMonitor2 ;
		           sig = In.ar(11,4) ;
				   adjust   = FoaRotate.ar(sig, -0.5pi) ;
				   // convert 2 SN3D here
				   bFormatSN3D = [adjust[0] * 2.sqrt, adjust[2], adjust[3], adjust[1]];
				   rotatedFieldMonitor1 =  FoaRTT.ar( adjust, monitorAz1, monitorElev1);
				   rotatedFieldMonitor2 =  FoaRTT.ar( adjust, monitorAz2, monitorElev2);
				   binauralMonitor1     =  FoaDecode.ar( rotatedFieldMonitor1 ,  ~binauralDecoder ) ;
				   binauralMonitor2     =  FoaDecode.ar( rotatedFieldMonitor2 ,  ~binauralDecoder ) ;

//-----------------------------------------
// CHANGE THE OUTPUT HERE

// Listen over headphones to monitor 1 on [0,1]
				   Out.ar(0,[binauralMonitor1, binauralMonitor2, bFormatSN3D ].flatten );

// send bformat first
//				   Out.ar(0,[bFormatSN3D,  binauralMonitor1, binauralMonitor2 ].flatten );

// send timecode first
//				   Out.ar(0,[SoundIn.ar( {|i|i}!~nrTimeCodeChannels), bFormatSN3D, binauralMonitor1, binauralMonitor2 ].flatten );
//-------------------------------------

			       }.play;

s.sync;

~sources = {}!~numVoices;


if(testOnLaptop,
				{
                  ~numVoices.do({|item, i |
	              ~sources[i] =
	              {|az = 0.0, elev = 0, dist = 0, gain = 0.1, i_out= 11, i_inBus = 0|
                  var pannedSig, in;
							in = DelayC.ar( In.ar(20, 1),  3.0, dist.varlag(1.0, -0.5)  );
		          pannedSig = FoaPanB.ar(in , az , elev);
	              Out.ar(i_out, pannedSig * gain)
                  }.play;
                  s.sync;
		          });
				 }
				,
				{
                  ~numVoices.do({|item, i |
	              ~sources[i] =
	              {|az = 0.0, elev = 0, dist = 0, gain = 0.1, i_out= 11, i_inBus = 0|
                  var pannedSig, in;
				  in = DelayC.ar( SoundIn.ar(i + ~busOffset), 3.0, dist.varlag(1.0, -0.5) );
		          pannedSig = FoaPanB.ar(in , az , elev);
	              Out.ar(i_out, pannedSig * gain)
                  }.play;
                  s.sync;
		          });
				 }
			);


if(testOnLaptop, {{ Out.ar(20, /* WhiteNoise.ar(0.1) */  SinOsc.ar(440, 0, 1) );  }.play});


		s.sync;

        ~lowerLimitPlayground = (-73.568541)@(45.506792);
        ~upperLimitPlayground = (-73.566205)@(45.508117);
        ~positioningSetup.();
        ~loadOSCResponders.();
		if(~window == 1, { {~monitorWindow.(); ~refreshTask.start;}.defer; });

}



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


~absSourcePositionsLongLat = {Cartesian(~initializeAllSources[0].linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
		                                ~initializeAllSources[1].linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
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
		~sources[i].set(\az, ~relSourcePositionsSpherical[i].theta,
				        \elev, ~relSourcePositionsSpherical[i].phi,
				        \dist, ~relSourcePositionsSpherical[i].rho  / 150.0
			);

			// ~relSourcePositionsSpherical[i].rho.postln;

		if(~oscVerbose == 1,{msg.postln});
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

		~sources.do( {|item, i| item.set(\az, ~relSourcePositionsSpherical[i].theta,
			                             \elev, ~relSourcePositionsSpherical[i].phi,
			                      	     \dist, ~relSourcePositionsSpherical[i].rho / 150.0
		) });
		if(~oscVerbose == 1,{msg.postln});
	    },("/listener").asSymbol, nil);


OSCdef.newMatching(("monitor1").asSymbol, {|msg, time, addr, recvPort|
		// register az and ele
		~monitorAz1 = msg[1];
		~monitorElev1 = msg[2];
		// [ msg[1], msg[2]].postln;

		if( ~w.isClosed != true , { "GUIalive".postln;  {~monitorSlider1.setXY(~monitorAz1.linlin(-pi,pi, 0, 1), ~monitorElev1.linlin(-0.5pi, 0.5pi, 0, 1) )}.defer; } );

		~decoder.set(\monitorAz1, msg[1], \monitorElev1, msg[2] );
		if(~oscVerbose == 1,{msg.postln});
	    },("/monitor1").asSymbol, nil);


OSCdef.newMatching(("monitor2").asSymbol, {|msg, time, addr, recvPort|
	    // register az and ele
		~monitorAz2 = msg[1];
		~monitorElev2 = msg[2];

		if( ~w.isClosed != true , { "GUIalive".postln; {~monitorSlider2.setXY(~monitorAz2.linlin(-pi,pi, 0, 1), ~monitorElev2.linlin(-0.5pi, 0.5pi, 0, 1) )}.defer; } );

		~decoder.set(\monitorAz2, msg[1], \monitorElev2, msg[2] );
		if(~oscVerbose == 1,{msg.postln});
	    },("/monitor2").asSymbol, nil);


OSCdef.newMatching(("window").asSymbol, {|msg, time, addr, recvPort|
	    // register az and ele
		~window = msg[1];

		case{~window == 1}
		        {{~monitorWindow.(); ~refreshTask.start;}.defer;}
            {~window == 0}
		{{~w.close; ~refreshTask.stop}.defer};
		if(~oscVerbose == 1,{msg.postln});
	    },("/window").asSymbol, nil);


OSCdef.newMatching(("oscVerbosity").asSymbol, {|msg, time, addr, recvPort|
	    // register az and ele
		~oscVerbose = msg[1];

		if(~oscVerbose == 1,{msg.postln});
	    },("/oscVerbosity").asSymbol, nil);




// initialize all sources
~numVoices.do( {|i| m.sendMsg("/source/"++i++"/pos",
	                     ~initializeAllSources[0].linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                     ~initializeAllSources[1].linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                     0
) } );


// initialize listener center looking NORTH
m.sendMsg("/listener",  0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.x,~upperLimitPlayground.x),
	                    0.5.linlin(0.0, 1.0, ~lowerLimitPlayground.y,~upperLimitPlayground.y),
	                    0.0,
	                    0
);

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
~refreshTask = Task({inf.do({ if((~w != nil) && ~visualize, {~w.refresh} ); 0.3.wait; }); },AppClock).stop;
~canvasSize = 600;

~scaleDown = 0.4;

~w = Window.new("HOA Scene Test", Rect(10,10,~canvasSize * 2,~canvasSize));
~w.front;

m = NetAddr("127.0.0.1", 57120);

	~slider2D = Slider2D(~w, Rect(~canvasSize * 0.17,
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




		~monitorSlider1 = Slider2D(~w, Rect(~canvasSize * 0.17,
		                              28,
		                              ~canvasSize * 0.66,
		                               100)).x_(0.5).y_(0.5)
	    .action_({|sl| var mappedX = sl.x.linlin(0.0,1.0, -pi, pi),
		                   mappedY = sl.y.linlin(0.0,1.0, -0.5pi, 0.5pi);
		// [mappedX,mappedY].postln;
		m.sendMsg("/monitor1", mappedX, mappedY) });


	    ~monitorSlider2 = Slider2D(~w, Rect(~canvasSize * 0.17,
		                              ~canvasSize * 0.78,
		                              ~canvasSize * 0.66,
		                               100)).x_(0.5).y_(0.5)
	    .action_({|sl| var mappedX = sl.x.linlin(0.0,1.0, -pi, pi),
		                   mappedY = sl.y.linlin(0.0,1.0, -0.5pi, 0.5pi);
		// [mappedX,mappedY].postln;
		m.sendMsg("/monitor2", mappedX, mappedY) });





~w.drawFunc = {
    Pen.use {
		var dotSize, halfDotSize, xL, yL;
		dotSize = 8;
		halfDotSize = dotSize * 0.5;

		// draw Sources:
		~absSourcePositionsMeters.do(
			{|item, i|var x, y;
				x = item.x.linlin( ~playGroundDiameter * -0.5, ~playGroundDiameter * 0.5, ~canvasSize * ~scaleDown.neg , ~canvasSize * ~scaleDown );
				y = item.y.linlin( ~playGroundDiameter * -0.5, ~playGroundDiameter * 0.5, ~canvasSize * ~scaleDown.neg , ~canvasSize * ~scaleDown );
		Pen.color = Color.hsv(~relSourcePositionsSpherical[i].theta.linlin(-pi,pi, 0.0, 0.999999999), 1 , 1 , 1);
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

	    Pen.color = Color.hsv(~relSourcePositionsSpherical[i].theta.linlin(-pi,pi, 0.0, 0.99999999), 1 , 1 , 1);
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
~w.refresh;
};

CmdPeriod.add({Window.closeAll}.defer);
{Window.closeAll}.defer;

~bootTheServer.();
~configDSP.(~simulateInput);

)




