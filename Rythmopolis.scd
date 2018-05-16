(
s = Server.local;
// s = Server.internal;
Server.supernova;
// Server.scsynth;
ServerOptions.devices;

Server.local = Server.default;
o = Server.local.options; // Get the local server's options
// o.device = "MADIface USB (23631679)"; // CIRMMT workshop
o.device = nil;

o.numInputBusChannels = 1; // Set Input to number of Mikes
// o.numInputBusChannels.postln; // Post the number of input channels
o.numOutputBusChannels = 2;
o.numAudioBusChannels = 2048 * 8;
o.blockSize = 2048 * 1;
o.numWireBufs = 1024 * 16;
o.memSize = 2.pow(18);
o.sampleRate = 48000;
o.threads_(8);
s.makeWindow;
s.scope(9);
s.reboot
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
p = ParGroup.new;
a = 200.do({|i| Synth.new(\encoder, [\azi, i.linlin(0, 30, 0, 2pi), \gain, -60], p ,\addToTail);});
)


