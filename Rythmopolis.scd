

(
// execute this section to configure and boot the sound server
s = Server.local; // Server.internal;
Server.supernova; // Server.scsynth;
ServerOptions.devices;  // this line lists all available audio devices
Server.local = Server.default; // set the launched server to be the default server to make sure the masseages go to the right place
o = Server.local.options; // Get the local server's options

// check what is listed as output from ServerOptions.devices and set the device correctly
o.device = nil;  // o.device = "MADIface USB (23631679)";


o.numInputBusChannels = 1; // Set nuber of input channels
o.numOutputBusChannels = 2; // Set nuber of output channels
// o.numInputBusChannels.postln; // Post the number of input channels
// o.numOutputBusChannels.postln; // Post the number of output channels

o.numAudioBusChannels = 2048 * 8; // these are the internal max number of audiobusses
o.blockSize = 2048 * 1; // the blocksize
o.numWireBufs = 1024 * 16; // number of wired buffers
o.memSize = 2.pow(18); // the memory of the server
o.sampleRate = 48000;
o.threads_(8); // the number of threads supernova is using
s.makeWindow; // make a Window
s.scope(9, 0, 4096, 2); // make a scope with 9 channels starting at channel 0, window
s.reboot // reboot (kill existing server)

)

(
~numberOfSources = 5;
)

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
SynthDef(\binDecoder, {|in = 0, out = 0, azi = 0, rad = 1, gain = 0|
	var source, decoded;
	source = SoundIn.ar(0);
	decoded = HOADecBinaural.ar(2, In.ar(in, 9), 0, 0);
    Out.ar(out, decoded );
}).add;
)

(
p = ParGroup.new;
a = ~numberOfSources.do({|i| Synth.new(\encoder, [\azi, i.linlin(0, ~numberOfSources, 0, 2pi), \gain, -60], p ,\addToTail);});
Synth.new(\binDecoder, [\out, 0, \in, 0], p ,\addToTail)
)


