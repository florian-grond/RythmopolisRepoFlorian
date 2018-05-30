(
// ~ip = "169.254.130.74";
// ~ip = "127.0.0.1";
// ~ip = "10.0.1.12";
// ~ip = nil;


~inBus = 0;
~outBus = 0;

~outputGain = 0.1; // carefull this generatyes FEEDBACK

~percentile = 0.9;

~plotwidth = 500;
~plotheight = 120;
~win = Window("plot panel", Rect(30, 30, (~plotwidth * 2.1) + 40, 600)).front;

~ezSlider = EZSlider( ~win,         // parent
              Rect(50, 70 + (~plotheight* 4), 600, 20),    // bounds
              "delay",  // label
              ControlSpec(0, 10, \lin, 0.01, 5),     // controlSpec
              { |ez| (ez.value.asString ++" is the value of " ++ ez).postln;
		~changeDelay.(ez.value);
	} // action
).setColors(Color.grey,Color.white);



~counter = 0;

~delayMover = Task({
    inf.do({
		~counter = ~counter + 1; if(~counter >= 1000,{~counter = 0});
		// ~counter.postln;
		{~ezSlider.value_(~counter.linlin(0, 1000, 0, 2pi).sin.linlin(-1,1, 0,10));}.defer;
		0.1.wait;
    });
}).start;

~delayMover.stop;
~delayMover.start;

~percentileSlider = Slider(~win, Rect(10, 10, 25, 400));
~percentileSlider.action_({|sl| ~percentile = sl.value.linlin(0.0, 1.0, 0.0, 1.0); ~percentileNumber.value = sl.value.linlin(0.0, 1.0, 0.0, 1.0); });
~percentileNumber =     NumberBox(~win, Rect(10, 410, 35, 25)).value_(~percentile);

~percentileSlider.value_(~percentile);

~text1 = TextField(~win, Rect(50, 10, 300, 20)).background_(Color.gray).string_("OSC timestamp1 - local time");
~dataView1 = CompositeView(~win, Rect(50, 30 + (~plotheight* 0), ~plotwidth, ~plotheight));
~dataPlot1 = Plotter("plot", parent: ~dataView1).value_({0}!1 * 100);
~dataPlot1.plotMode = \points;

~text2 = TextField(~win, Rect(50, 30 + (~plotheight* 1), 300, 20)).background_(Color.gray).string_("filtered accroding to percentile");
~percentileView1 = CompositeView(~win, Rect(50, 50 + (~plotheight* 1), ~plotwidth, ~plotheight));
~percentilePlot1 = Plotter("plot", parent: ~percentileView1).value_({0}!1 * 100);
~percentilePlot1.plotMode = \points;

~text3 = TextField(~win, Rect(~plotwidth + 60, 10 + (~plotheight* 0), 300, 20)).background_(Color.gray).string_("OSC timestamp2 - local time");
~dataView2 = CompositeView(~win, Rect(~plotwidth + 60, 30 + (~plotheight* 0), ~plotwidth, ~plotheight));
~dataPlot2 = Plotter("plot", parent: ~dataView2).value_({0}!1 * 100);
~dataPlot2.plotMode = \points;

~text4 = TextField(~win, Rect(~plotwidth + 60, 30 + (~plotheight* 1), 300, 20)).background_(Color.gray).string_("filtered accroding to percentile");
~percentileView2 = CompositeView(~win, Rect(~plotwidth + 60, 50 + (~plotheight* 1), ~plotwidth, ~plotheight));
~percentilePlot2 = Plotter("plot", parent: ~percentileView2).value_({0}!1 * 100);
~percentilePlot2.plotMode = \points;

~text5 = TextField(~win, Rect(50, 70 + (~plotheight* 2), 300, 20)).background_(Color.gray).string_("Delt1 - Delta2");
~deltaDeltaView1 = CompositeView(~win, Rect(50, 90 + (~plotheight* 2), ~plotwidth, ~plotheight));
~deltaDeltaPlot1 = Plotter("plot", parent: ~deltaDeltaView1).value_({0}!1 * 100);
~deltaDeltaPlot1.plotMode = \points;

~timeStampArray1 = {0}!~timeWindow;
~filteredArray1 = {0}!~timeWindow;
~deltadeltaArray1 = {0}!~timeWindow;

~timeStampArray2 = {0}!~timeWindow;
~filteredArray2 = {0}!~timeWindow;

~lastTime1 = 0; ~lastTime2 = 0;

~sentTimeDeltaLocal_2 = 0; ~sentTimeDeltaLocal_1 = 0;

~percentile = 0.9;

n = NetAddr(~ip, 57120); // local machine

~timeWindow = 380;
~alpha = 0.98;


OSCFunc.newMatching({|msg, time, addr, recvPort|

	~sentTimeDeltaLocal_1 = time - SystemClock.seconds;
	~lastTime1 = time;

	~timeStampArray1.addFirst(	~sentTimeDeltaLocal_1  ); // add incoming value
	if( ~timeStampArray1.size > ~timeWindow, {~timeStampArray1.pop;  }); // pop the last when time window is reached

	if( ~sentTimeDeltaLocal_1.abs < ~timeStampArray1.abs.percentile(~percentile)

		// only if smaller set percentile
		,{~filteredArray1.addFirst( ~sentTimeDeltaLocal_1 ); // add to filtered array
	      if( ~filteredArray1.size > ~timeWindow, {~filteredArray1.pop;  }); // pop the last when time window is reached
			// [~sentTimeDeltaLocal_2 , ~sentTimeDeltaLocal_1, ~sentTimeDeltaLocal_2 - ~sentTimeDeltaLocal_1].postln;
			~deltadeltaArray1.addFirst(~filteredArray2[0] - ~filteredArray1[0]);
	      if( ~deltadeltaArray1.size > ~timeWindow, {~deltadeltaArray1.pop; });
	    }
	);

	{
	~dataPlot1.value_(~timeStampArray1);
	~percentilePlot1.value_(~filteredArray1);
	~deltaDeltaPlot1.value_(~deltadeltaArray1);
	~win.refresh;
	}.defer;

}, '/tc1', nil);


OSCFunc.newMatching({|msg, time, addr, recvPort|

	~sentTimeDeltaLocal_2 = time - SystemClock.seconds;
	~lastTime2 = time;

	~timeStampArray2.addFirst(	~sentTimeDeltaLocal_2  );
	if( ~timeStampArray2.size > ~timeWindow, {~timeStampArray2.pop;  });

	if( ~sentTimeDeltaLocal_2.abs < ~timeStampArray2.abs.percentile(~percentile)
		,{~filteredArray2.addFirst( ~sentTimeDeltaLocal_2 );
	     if( ~filteredArray2.size > ~timeWindow, {~filteredArray2.pop; });
	  }
	);

	{
	~dataPlot2.value_(~timeStampArray2);
	~percentilePlot2.value_(~filteredArray2);
	~win.refresh;
	}.defer;

}, '/tc2', nil);






/******************** LAUNCH AUDIO  ****************************/



s = Server.local; // Server.internal;
Server.scsynth;
ServerOptions.devices;  // this line lists all available audio devices
Server.local = Server.default; // set the launched server to be the default server to make sure the masseages go to the right place
o = Server.local.options; // Get the local server's options

// check what is listed as output from ServerOptions.devices and set the device correctly
// o.device = nil;  // o.device = "MADIface USB (23631679)";

// o.device = "MADIface USB (23631679)"; // evaluate the command ServerOptions.devices; some lines above to see what is available.

// o.numInputBusChannels = 1; // Set nuber of input channels
// o.numOutputBusChannels = 11; // Set nuber of output channels
// o.numInputBusChannels.postln; // Post the number of input channels
// o.numOutputBusChannels.postln; // Post the number of output channels

o.numAudioBusChannels = 2048 * 8; // these are the internal max number of audiobusses
o.blockSize = 512 ; // the blocksize
o.numWireBufs = 1024 * 16; // number of wired buffers
o.memSize = 2.pow(18); // the memory of the server
o.sampleRate = 48000;
o.threads_(16); // the number of threads supernova is using
s.makeWindow; // make a Window
s.scope(9, 0, 4096, 2); // make a scope with 9 channels starting at channel 0, window

s.waitForBoot({ // Boot the server, if you need to

	SynthDef(\help_PlayBuf, {| out = 0, bufnum = 0, delaybuf, delay1 = 0.1, delay2 = 0.1, mute1 = 1, mute2 = 0, pan = 1, level =1|
	var in, delayLine1, delayLine2, faded;
	// in = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), loop:1, doneAction:2);
		in = SoundIn.ar(~inBus);
	delayLine1 = BufDelayL.ar(delaybuf, in, delay1, mute1) ;
	delayLine2 = BufDelayL.ar(delaybuf, in, delay2, mute2);
		faded =	XFade2.ar(delayLine1, delayLine2, pan.lag(0.3));
		Out.ar(~outBus, HPF.ar(faded, 50 ))
}).add;
s.sync;

~delayBuffer = Buffer.alloc(s,44100 * 20,1);

~buffer = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav", action:
		{~delaySynth = Synth.new(\help_PlayBuf, [\bufnum, ~buffer.bufnum, \delaybuf, ~delayBuffer.bufnum, \delay1, 0.2]);}
	); // remember to free the buffer later.
s.sync;

~delaySynth.set(\delay1, 0.00);
~delaySynth.set(\delay2, 0.05);


~delaySynth.set(\mute1, ~outputGain, \mute2, 0, \pan, -1 )


}.fork;

);

~switcherState = 1;

~changeDelay = {|delay|

	case{~switcherState == 1}
	{
		~switcherState.postln;
		~delaySynth.set(\delay1, delay);
		~delaySynth.set(\mute1, 1, \mute2, 0, \pan, -1 );
	}
	{~switcherState == -1}
	{
		~switcherState.postln;
		~delaySynth.set(\delay2, delay);
		~delaySynth.set(\mute1, 0, \mute2, 1, \pan, 1 );

	};

	~switcherState = ~switcherState * -1;

}




)

~changeDelay.(2);
~changeDelay.(1);
~changeDelay.(0.1);


/******************** LAUNCH AUDIO  ****************************/

~delaySynth.set(\mute1, 0)
~delaySynth.set(\mute2, 0)

~delaySynth.set(\mute1, 1)
~delaySynth.set(\mute2, 1)

~delaySynth.set(\mute1, 1, \mute2, 0, \pan, -1 )
~delaySynth.set(\mute1, 0, \mute2, 1, \pan, 1)


~delaySynth.set(\delay1, 2);
~delaySynth.set(\delay2, 0.1);


~delaySynth.set(\delay1, 0.00);
~delaySynth.set(\delay2, 0.05);

(
~switcher = Task({
    inf.do({
		~delaySynth.set(\mute1, 1, \mute2, 0, \pan, -1 );
		"now".postln;
		0.1.wait;
		~delaySynth.set(\mute1, 0, \mute2, 1, \pan, 1);
		"now".postln;
		0.1.wait;
    });
}).start;
)

~switcher.stop
s.scope

(
// Stuff for testing:

~delaySynth.set(\delay, 0.5.rand);


m = NetAddr( ~ip, 57120); // loopback

~t1 = Task({
    inf.do({
       m.sendMsg("/tc1", SystemClock.seconds);
		        (30.reciprocal).wait;
    });
}).start;

~t2 = Task({
    inf.do({
       m.sendMsg("/tc2", SystemClock.seconds);
		        (30.reciprocal + 0.001).wait;
    });
}).start;
)

~t1.stop;
~t2.stop;







/*
a = Date.getDate;
a.rawSeconds.postln;

~deltadeltaArray2.minItem
~deltadeltaArray2.maxItem

~filteredArray2.minItem

*/
