
~testGain = 0.001;

{Out.ar(0,EnvGen.ar( Env.perc(0.01,1,1,-4),1,doneAction:2) * WhiteNoise.ar(~testGain))}.play;

{Out.ar(1,EnvGen.ar( Env.perc(0.01,1,1,-4),1,doneAction:2) * WhiteNoise.ar(~testGain))}.play;



(
// execute this section to configure and boot the sound server
s = Server.internal; // Server.internal;
// Server.supernova;
Server.scsynth;
ServerOptions.devices;  // this line lists all available audio devices
Server.internal = Server.default; // set the launched server to be the default server to make sure the masseages go to the right place
o = Server.internal.options; // Get the local server's options

// check what is listed as output from ServerOptions.devices and set the device correctly
o.device = nil;  // o.device = "MADIface USB (23631679)";

//  o.device = "MADIface USB (23631679)"; // CIRMMT workshop

o.numInputBusChannels = 1; // Set nuber of input channels
o.numOutputBusChannels = 11; // Set nuber of output channels
// o.numInputBusChannels.postln; // Post the number of input channels
// o.numOutputBusChannels.postln; // Post the number of output channels

o.numAudioBusChannels = 2048 * 8; // these are the internal max number of audiobusses
o.blockSize = 2048 * 2; // the blocksize
o.numWireBufs = 1024 * 16; // number of wired buffers
o.memSize = 2.pow(18); // the memory of the server
o.sampleRate = 48000;
o.threads_(16); // the number of threads supernova is using
s.makeWindow; // make a Window
s.scope(9, 0, 4096, 2); // make a scope with 9 channels starting at channel 0, window
s.reboot // reboot (kill existing server)

)

(
~numberOfSources = 10;
)





~sourceEncoder = NodeProxy.audio(s, 9);
~sourceEncoder[0] = { |azi = 0, rad = 1, freq = 880, gain = 0| var source, encoded;
	      source = SinOsc.ar(freq, 0.01);encoded = HOAEncoder.ar(2, source, SinOsc.ar(0.5,0,2pi), 0, gain, 1, rad); };

~sourceEncoder[1] = { |azi = 0, rad = 1, freq = 440, gain = 0| var source, encoded;
	      source = SinOsc.ar(freq, 0.01);encoded = HOAEncoder.ar(2, source, SinOsc.ar(0.2,0,2pi), 0, gain, 1, rad); };

~sourceEncoder[2] = { |azi = 0, rad = 1, freq = 220, gain = 0| var source, encoded;
	      source = SinOsc.ar(freq, 0.01);encoded = HOAEncoder.ar(2, source, SinOsc.ar(0.1,0,2pi), 0, gain, 1, rad); };

~sourceEncoder[3] = { |azi = 0, rad = 1, freq = 110, gain = 0| var source, encoded;
	      source = SinOsc.ar(freq, 0.01);encoded = HOAEncoder.ar(2, source, SinOsc.ar(0.3,0,2pi), 0, gain, 1, rad); };

~sourceEncoder[4] = { |azi = 0, rad = 1, freq = 330, gain = 0| var source, encoded;
	      source = SinOsc.ar(freq, 0.01);encoded = HOAEncoder.ar(2, source, SinOsc.ar(0.6,0,2pi), 0, gain, 1, rad); };

~sourceEncoder[5] = { |azi = 0, rad = 1, freq = 550, gain = 0| var source, encoded;
	      source = SinOsc.ar(freq, 0.01);encoded = HOAEncoder.ar(2, source, SinOsc.ar(0.6,0,2pi), 0, gain, 1, rad); };

~sourceEncoder[6] = { |azi = 0, rad = 1, freq = 660, gain = 0| var source, encoded;
	      source = SinOsc.ar(freq, 0.01);encoded = HOAEncoder.ar(2, source, SinOsc.ar(0.6,0,2pi), 0, gain, 1, rad); };

~sourceEncoder[7] = { |azi = 0, rad = 1, freq = 770, gain = 0| var source, encoded;
	      source = SinOsc.ar(freq, 0.01);encoded = HOAEncoder.ar(2, source, SinOsc.ar(0.9,0,2pi), 0, gain, 1, rad); };


~numberOfSources.do({|item,i|
	~sourceEncoder[i] = { |azi = 0, rad = 1, freq = 0 , gain = 0| var source, encoded;
		source = SinOsc.ar(i.linlin( 0, ~numberOfSources, 45, 45 + (~numberOfSources * 2) ).midicps, 0.01);
		encoded = HOAEncoder.ar(2, source, SinOsc.ar(i.linlin( 0, ~numberOfSources, 0.1, 1 ),0,2pi), 0, gain, 1, rad); };
});


~decoder = NodeProxy.audio(s, 17);
~decoder.source = { |gain = 0|
	HOADecCIRMMT17D3odown1SN3D.ar(2, HOAConvert.ar(2, \in.ar(0!9),\ACN_N3D, \ACN_SN3D ), gain: gain, lf_hf: 1, xover: 600);
};

~decoder.play(9, 17, vol: 0.001, fadeTime: 2)


~sourceEncoder <>> ~decoder

(
SynthDef(\encoder, {|in = 0, out = 0, azi = 0, rad = 1, gain = 0|
	var source, encoded;
	source = SoundIn.ar(0);
	// source = Mix(SinOsc.ar(200, 0, 0.1));
	encoded = HOAEncoder.ar(2, source, azi, 0, gain, 1, rad);
    Out.ar(out,encoded );
}).add;
)


(
SynthDef(\encoder, {|in = 0, out = 0, azi = 0, rad = 1, freq = 440, gain = 0|
	var source, encoded;
	source = Decay.ar(Pulse.ar(0.5), 1, 0.001) * Ringz.ar(WhiteNoise.ar(0.01),  freq, 0.5, 1 );
	encoded = HOAEncoder.ar(1, source, azi , 0, SinOsc.ar(2.5.rand, 1.0.rand, 2pi, pi), 1, rad);
    Out.ar(out, encoded * 0.1);
}).add;
)


(
SynthDef(\binDecoder, {|in = 0, out = 0|
	var source, decoded;
	source = SoundIn.ar(in);
	decoded = HOADecBinaural.ar(1, In.ar(in, 4), 0, 0);
    Out.ar(out, decoded );
}).add;
)


(
SynthDef(\decoder, {|in = 0, out = 9, azi = 0, rad = 1, gain = -30|
	var source, decoded;
	source = In.ar(0);
	decoded = HOADecCIRMMT17D3odown1SN3D.ar(2, HOAConvert.ar(2, In.ar(in, 9),\N3D, \SN3D ), gain: gain, lf_hf: 1, xover: 600);
    Out.ar(out, decoded * 0.000000001);
}).add;
)


//
(
p = ParGroup.new;
a = ~numberOfSources.do({|i|
	  Synth.new(\encoder, [\azi, i.linlin(0, ~numberOfSources, 0, 2pi),
		                   \gain, -20,
			               \freq, i.linlin(0, ~numberOfSources, 220, 1660) ], p ,
	\addToTail);});
Synth.new(\binDecoder, [\in, 0], p ,\addToTail)
)


{ Decay.ar(Pulse.ar(0.5), 1, 0.001) * Ringz.ar(WhiteNoise.ar(0.01),  220, 0.5, 1 )  }.play


{ WhiteNoise.ar(0.01)  }.play


{ Saw.ar(2).linlin(0,1, 0, 2pi)  }.play

(
{  HOADecBinaural.ar(1,
	  HOAEncoder.ar(1,
		         Decay.ar(Pulse.ar(0.5), 1, 0.001) * Ringz.ar(WhiteNoise.ar(0.01),  440, 0.5, 1 ),
		Mouse.ar(), 0, 0.1 , 1, 1),
	        0, 0);
       }.play
)

s.scope

