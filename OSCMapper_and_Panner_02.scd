(

s.quit;

// execute this section to configure and boot the sound server
s = Server.internal; // Server.internal;
Server.supernova;
// Server.scsynth;
ServerOptions.devices;  // this line lists all available audio devices
Server.internal = Server.default; // set the launched server to be the default server to make sure the masseages go to the right place
o = Server.internal.options; // Get the local server's options

// check what is listed as output from ServerOptions.devices and set the device correctly
o.device = nil;  // o.device = "MADIface USB (23631679)";

//  o.device = "MADIface USB (23631679)"; // CIRMMT workshop

o.numInputBusChannels = 64; // Set nuber of input channels
o.numOutputBusChannels = 11; // Set nuber of output channels
// o.numInputBusChannels.postln; // Post the number of input channels
// o.numOutputBusChannels.postln; // Post the number of output channels

o.numAudioBusChannels = 2048 * 8; // these are the internal max number of audiobusses
o.blockSize = 2048 * 1; // the blocksize
o.numWireBufs = 1024 * 8; // number of wired buffers
o.memSize = 2.pow(18); // the memory of the server
o.sampleRate = 44100;
o.threads_(16); // the number of threads supernova is using

s.reboot; // reboot (kill existing server)


s.waitForBoot({


SynthDef(\panner,
	{|az = 0.78539816339745, elev = 0, dist =1, gain = 0, out= 2, freq = 880, delay = 0.5|
     var pannedSig, in;
			in = DelayN.ar( BPF.ar( Decay.ar(Impulse.ar(2), 0.05, PinkNoise.ar(1)), freq, 0.002, 10), 3.0, delay);
			pannedSig = HOAEncoder.ar(1, in , az.varlag(5), elev.varlag(5), 0, 1, dist.varlag(5));
			Out.ar(out, pannedSig * gain.varlag(5))
}).add;


SynthDef(\pannerAzDist,
	{|az = 0.78539816339745, dist =1, gain = 0, out= 6, freq = 880, delay = 0.5|
     var pannedSig, in;
			in = DelayN.ar( BPF.ar( Decay.ar(Impulse.ar(2), 0.05, PinkNoise.ar(1)), freq, 0.002, 10), 3.0, delay);
			pannedSig = HOAEncoder.ar(1, in , az.varlag(5), 0, 1, dist.varlag(5));
			Out.ar(out, pannedSig * gain)
}).add;


SynthDef(\pannerA,
	{|az = 0.78539816339745, gain = 0, out= 2, freq = 880, delay = 0.5|
     var pannedSig, in;
			in = DelayN.ar( BPF.ar( Decay.ar(Impulse.ar(2), 0.05, PinkNoise.ar(1)), freq, 0.002, 10), 3.0, delay);
			pannedSig = HOAEncoder.ar(1, in , az.varlag(5), 0, 0, 0);
			Out.ar(out, pannedSig * gain.varlag(5))
}).add;


SynthDef(\pannerB,
	{|az = 0.78539816339745, elev = 0, dist =1, gain = 0, out= 2, freq = 880, delay = 0.5|
     var pannedSig, in;
			in = DelayN.ar( BPF.ar( Decay.ar(Impulse.ar(2), 0.05, PinkNoise.ar(1)), freq, 0.002, 10), 3.0, delay);
			pannedSig = PanB.ar(in , az.varlag(5), elev.varlag(5), 1);
			Out.ar(out, HOAConverterFuma2AcnN3d.ar(1, pannedSig) * gain.varlag(5))
}).add;





SynthDef(\decoder,
	{| in = 2, out= 0, gain|
     var decoded, sig;
			sig = In.ar(6, 4);
			decoded = HOADecBinaural.ar(1, sig, 0, 0);
			Out.ar(out, decoded * gain.lag(3))
}).add;




s.makeWindow; // make a Window
s.scope(9, 0, 4096, 2); // make a scope with 9 channels starting at channel 0, window


	s.plotTree;

})

)





(
~numVoices = 128;

Routine.run
{
~decoderGroup = ParGroup.new();

		s.sync;

	~decoder = {|azi|
		var sig, rotated, decoded;

		sig = In.ar(6,4);
		rotated = HOATransRotateAz.ar(1, sig, azi);
		decoded = HOADecBinaural.ar(1, rotated, 0, 0);
		[decoded + sig].flatten
	            }.play(~decoderGroup);

	s.sync;

~parPanners = ParGroup.new();
	s.sync;

OSCdef.freeAll;

	s.sync;


// register a matching OSC Responder for the source to pan
// the responder listens to /source/i
n = NetAddr("127.0.0.1", 57120);

{|i|
OSCdef.newMatching(("pos"++i).asSymbol, {|msg, time, addr, recvPort|




		~sources[i].set(\az, msg[1], \dist,  msg[2]);
		msg.postln}, ("/source/"++i++"/pos").asSymbol, n);
	}!~numVoices;


{|i|
OSCdef.newMatching(("gain"++i).asSymbol, {|msg, time, addr, recvPort|
		~sources[i].set(\gain, msg[1]);
		msg.postln}, ("/source/"++i++"/gain").asSymbol, n);
	}!~numVoices;



	~sources = {|i| Synth(\pannerAzDist,
		 [\az, 2pi.rand,
	      \elev, (pi * 0.5).rand,
		  \dist, 0.1+ 30.rand,
		  \gain, 0.1,
		  \freq, i.linexp(0,~numVoices, 200, 2000),
		 // \delay, i.linlin(0,~numVoices, 0.0, 0.5)
		  \delay, 0.5.rand
		]
		,
		~parPanners, \addToHead )}!~numVoices;

	/*
	~sources = {|i| Synth(\panner,
		 [\az, 2pi.rand,
	      \elev, (pi * 0.5).rand,
		  \dist, 0.1+ 30.rand,
		  \gain, 0.1,
		  \freq, i.linexp(0,~numVoices, 200, 2000),
		 // \delay, i.linlin(0,~numVoices, 0.0, 0.5)
		  \delay, 0.5.rand
		]
		,
		~parPanners, \addToHead )}!~numVoices;

	~sources = {|i| Synth(\pannerA,
		 [\az, 2pi.rand,
		  \gain, 0.1,
		  \freq, i.linexp(0,~numVoices, 200, 2000),
		 // \delay, i.linlin(0,~numVoices, 0.0, 0.5)
		  \delay, 0.5.rand
		]
		,
		~parPanners, \addToHead )}!~numVoices;
*/

	s.sync;
}
)



{Out.ar(2, SinOsc.ar(400)!4)}.play

{Out.ar(0, In.ar(2,2))}.play


~sources


OSCdef.trace(true,true)

Synth(\panner, [\az, pi.rand, \elev, pi* 0.25, \dist, 10.rand, \gain, 1, \freq, 4000.rand] )


~sources.set(\gain, 1)


OSCdef.newMatching(\test1, {|msg, time, addr, recvPort| msg.postln}, '/source/1', n);
OSCdef.newMatching(\test2, {|msg, time, addr, recvPort| msg.postln}, '/source/2', n);


OSCdef.newMatching(\test3, {|msg, time, addr, recvPort| msg.postln}, '/source', n);


m = NetAddr("127.0.0.1", 57120); // loopback


~numVoices.do( {|i| m.sendMsg("/source/"++i++"/az", 2pi.rand) } );
~numVoices.do( {|i| m.sendMsg("/source/"++i++"/elev", (pi*0.5).rand2) } );
~numVoices.do( {|i| m.sendMsg("/source/"++i++"/dist", 60.rand + 0.1) } );
~numVoices.do( {|i| m.sendMsg("/source/"++i++"/gain", 1.0.rand.linexp(0,1.0, 0.01, 1.0)) } );

~numVoices.do( {|i| m.sendMsg("/source/"++i++"/dist", 100.rand + 0.1) } );

~decoder.set(\azi, pi * -0.5)

m.sendMsg("/source/*/az", 0);
m.sendMsg("/source/*/az", pi * 0.5);
m.sendMsg("/source/*/az", pi * -0.5);

m.sendMsg("/source/*/elev", 0);

m.sendMsg("/source/*/dist", 2);


m.sendMsg("/source/1/gain", 1);
m.sendMsg("/source/*/gain", 0);
m.sendMsg("/source/*/gain", 1);
m.sendMsg("/source/*/gain", 0.5);

m.sendMsg("/source/*/gain", 0.1);














(
~visualize = true;
~numVoices = 10;
~absSourcePositions = {Cartesian(1.0.rand2,1.0.rand2,0)}!~numVoices;
~listenerPositions = Cartesian(1.0.rand2,1.0.rand2,0);
~listenerOrientation = pi.rand2;
~relSourcePositions = ~absSourcePositions.collect({|item,i| (item - ~listenerPositions).rotate(~listenerOrientation.neg) });
if((w != nil) && ~visualize, {w.refresh} );


OSCdef.freeAll;

n = NetAddr("127.0.0.1", 57120);

{|i|
OSCdef.newMatching(("pos"++i).asSymbol, {|msg, time, addr, recvPort|
		~absSourcePositions[i].x = msg[1];
		~absSourcePositions[i].y = msg[2];
		// ~sources[i].set(\az, msg[1], \dist,  msg[2]);
		// msg.postln
	}, ("/source/"++i++"/pos").asSymbol, n);
	}!~numVoices;


OSCdef.newMatching(("listener").asSymbol, {|msg, time, addr, recvPort|
		~listenerPositions.x = msg[1];
		~listenerPositions.y = msg[2];
	    ~listenerOrientation = msg[3];
	    ~relSourcePositions = ~absSourcePositions.collect({|item,i| (item - ~listenerPositions).rotate(~listenerOrientation.neg) });
		// ~sources[i].set(\az, msg[1], \dist,  msg[2]);
		// msg.postln
        },("/listener").asSymbol, n);


m = NetAddr("127.0.0.1", 57120); // loopback
~numVoices.do( {|i| m.sendMsg("/source/"++i++"/pos", 1.0.rand2, 1.0.rand2) } );

m.sendMsg("/source/0/pos", 1.0.rand2, 1.0.rand2);
m.sendMsg("/source/1/pos", 1.0.rand2, 1.0.rand2);
m.sendMsg("/source/3/pos", 1.0.rand2, 1.0.rand2);

m.sendMsg("/listener", 1.0.rand2, 1.0.rand2, pi.rand2);
)

(
t = Task({
	~counter = 0;
    inf.do({
		~counter = ~counter + 0.02;
		if (~counter > 2pi,{~counter = 0});
		m.sendMsg("/listener", ~counter.cos *0.5, ~counter.sin, (~counter * 4).sin);
        // ~listenerPositions = Cartesian(~counter.cos *0.5,~counter.sin,0);
		// ~listenerOrientation = (~counter * 4).sin;

        if((w != nil) && ~visualize, {w.refresh}.defer );
        0.1.wait;
    });
},AppClock).start;
)

t.start;
t.pause;
t.resume;
t.reset;
t.stop;


(
w = Window.new("Transparency Layer test", Rect(200,200,900,450)).front;


~drawArrow ={|rotation = 0, x = 200, y = 200, scale = 0.1|
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


w.drawFunc = {
    Pen.use {
		var dotSize, xL, yL, scale;
		dotSize = 10;
		scale = 50;
		~absSourcePositions.do(
			{|item, i|var x, y;
				x = item.x.linlin(-1,1, scale.neg, scale);
				y = item.y.linlin(-1,1, scale.neg, scale);
        //Pen.translate(0, 0);
        Pen.addOval(Rect(x + 200,y + 200,dotSize,dotSize));
		Pen.fillAxialGradient(w.view.bounds.leftTop, w.view.bounds.rightBottom, Color.blue, Color.blue);
        i.asString.drawCenteredIn(Rect(x + 200,y + 200,dotSize,dotSize), Font("Monaco", 8), Color.white);
		});
		// draw Listener:
		xL = ~listenerPositions.x.linlin(-1,1, scale.neg, scale);
	    yL = ~listenerPositions.y.linlin(-1,1, scale.neg, scale);
		~drawArrow.(~listenerOrientation, xL + 200, yL + 200);

		~relSourcePositions.do(
			{|item, i|var x, y;
				x = item.x.linlin(-2,2, scale.neg * 2, scale * 2);
				y = item.y.linlin(-2,2, scale.neg * 2, scale * 2);
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


