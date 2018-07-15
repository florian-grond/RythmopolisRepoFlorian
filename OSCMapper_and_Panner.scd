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


SynthDef(\decoder,
	{| in = 2, out= 0, gain|
     var decoded, sig;
			sig = In.ar(2, 4);
			decoded = HOADecBinaural.ar(1, sig, 0, 0);
			Out.ar(out, decoded * gain.lag(3))
}).add;




s.makeWindow; // make a Window
s.scope(9, 0, 4096, 2); // make a scope with 9 channels starting at channel 0, window


})

)





(
~numVoices = 128;

Routine.run
{

~decoder = {HOADecBinaural.ar(1, In.ar(2,4), 0, 0)}.play;
	s.sync;

~parPanners = ParGroup.new();
	s.sync;

OSCdef.freeAll;

	s.sync;

{|i|
// register a matching OSC Responder for the source to pan
// the responder listens to /source/i
n = NetAddr("127.0.0.1", 57120);
OSCdef.newMatching(("az"++i).asSymbol, {|msg, time, addr, recvPort|
		~sources[i].set(\az, msg[1]);
		msg.postln}, ("/source/"++i++"/az").asSymbol, n);
	}!~numVoices;

{|i|
OSCdef.newMatching(("dist"++i).asSymbol, {|msg, time, addr, recvPort|
		~sources[i].set(\dist, msg[1]);
		msg.postln}, ("/source/"++i++"/dist").asSymbol, n);
	}!~numVoices;

{|i|
OSCdef.newMatching(("elev"++i).asSymbol, {|msg, time, addr, recvPort|
		~sources[i].set(\elev, msg[1]);
		msg.postln}, ("/source/"++i++"/elev").asSymbol, n);
	}!~numVoices;

{|i|
OSCdef.newMatching(("gain"++i).asSymbol, {|msg, time, addr, recvPort|
		~sources[i].set(\gain, msg[1]);
		msg.postln}, ("/source/"++i++"/gain").asSymbol, n);
	}!~numVoices;

OSCdef.newMatching('recorder', {|msg, time, addr, recvPort|
		"RECORDER".postln;}, ("/source/*").asSymbol, n);

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
	s.sync;
}
)

{Out.ar(2, SinOsc.ar(400)!4)}.play

{Out.ar(0, In.ar(2,2))}.play





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
~numVoices.do( {|i| m.sendMsg("/source/"++i++"/gain", 1.0.rand) } );

~numVoices.do( {|i| m.sendMsg("/source/"++i++"/dist", 100.rand + 0.1) } );



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


