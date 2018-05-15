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

o.numInputBusChannels = 30; // Set Input to number of Mikes
// o.numInputBusChannels.postln; // Post the number of input channels
o.numOutputBusChannels = 4;
o.numAudioBusChannels = 2048 * 8;
o.blockSize = 2048 * 1.5;
o.numWireBufs = 1024 * 16;
o.memSize = 2.pow(18);
o.sampleRate = 48000;
o.threads_(6);
s.makeWindow;
s.scope(9);
s.reboot
)



{ Resonz.ar(WhiteNoise.ar(1), [440, 880], 0.001, 10)}.play

