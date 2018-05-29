(


//~ip = "169.254.130.74";
// ~ip = "127.0.0.1";
~ip = "10.0.1.12";

~plotwidth = 500;
~plotheight = 120;
~win = Window("plot panel", Rect(30, 30, (~plotwidth * 2.1) + 40, 600)).front;

~ratioSlider = Slider(~win, Rect(10, 10, 15, 520));
~ratioSlider.action_({|sl| ~percentile = sl.value.linlin(0.0, 1.0, 0.0, 1.0) });

~dataView1 = CompositeView(~win, Rect(30, 10 + (~plotheight* 0), ~plotwidth, ~plotheight)).background_(Color.rand(0.7)).resize_(5);
~dataPlot1 = Plotter("plot", parent: ~dataView1).value_({0}!1 * 100);
~dataPlot1.plotMode = \points;

~meanView1 = CompositeView(~win, Rect(30, 30 + (~plotheight* 1), ~plotwidth, ~plotheight)).background_(Color.rand(0.7)).resize_(5);
~meanPlot1 = Plotter("plot", parent: ~meanView1).value_({0}!1 * 100);
~meanPlot1.plotMode = \points;

~medianView1 = CompositeView(~win, Rect(30, 40 + (~plotheight* 2), ~plotwidth, ~plotheight)).background_(Color.rand(0.7)).resize_(5);
~medianPlot1 = Plotter("plot", parent: ~medianView1).value_({0}!1 * 100);
~medianPlot1.plotMode = \points;

~medianSmoothView1 = CompositeView(~win, Rect(30, 50 + (~plotheight* 3), ~plotwidth, ~plotheight)).background_(Color.rand(0.7)).resize_(5);
~medianSmoothPlot1 = Plotter("plot", parent: ~medianSmoothView1).value_({0}!1 * 100);
~medianSmoothPlot1.plotMode = \points;


~dataView2 = CompositeView(~win, Rect(~plotwidth + 50, 10 + (~plotheight* 0), ~plotwidth, ~plotheight)).background_(Color.rand(0.7)).resize_(5);
~dataPlot2 = Plotter("plot", parent: ~dataView2).value_({0}!1 * 100);
~dataPlot2.plotMode = \points;

~meanView2 = CompositeView(~win, Rect(~plotwidth + 50, 30 + (~plotheight* 1), ~plotwidth, ~plotheight)).background_(Color.rand(0.7)).resize_(5);
~meanPlot2 = Plotter("plot", parent: ~meanView2).value_({0}!1 * 100);
~meanPlot2.plotMode = \points;

~medianView2 = CompositeView(~win, Rect(~plotwidth + 50, 40 + (~plotheight* 2), ~plotwidth, ~plotheight)).background_(Color.rand(0.7)).resize_(5);
~medianPlot2 = Plotter("plot", parent: ~medianView2).value_({0}!1 * 100);
~medianPlot2.plotMode = \points;

~medianSmoothView2 = CompositeView(~win, Rect(~plotwidth + 50, 50 + (~plotheight* 3), ~plotwidth, ~plotheight)).background_(Color.rand(0.7)).resize_(5);
~medianSmoothPlot2 = Plotter("plot", parent: ~medianSmoothView2).value_({0}!1 * 100);
~medianSmoothPlot2.plotMode = \points;


~timeStampArray1 = List.new;
~filteredArray1 = List.new;
~deltadeltaArray1 = List.new;
~medianSmoothArray1 = List.new;

~timeStampArray2 = List.new;
~filteredArray2 = List.new;
~deltadeltaArray2 = List.new;
~medianSmoothArray2 = List.new;


~lastTime1 = 0; ~lastTime2 = 0;

~sentTimeDeltaLocal_2 = 0;
~sentTimeDeltaLocal_1 = 0;


~percentile = 0.9;

n = NetAddr(~ip, 57120); // local machine

OSCFunc.newMatching({|msg, time, addr, recvPort|

~timeWindow = 380;
	~alpha = 0.98;

//	time.postln;
//	msg[1].postln;
//	SystemClock.seconds.postln;

	~sentTimeDeltaLocal_1 = time - SystemClock.seconds;

	~lastTime1 = time;

	~timeStampArray1.addFirst(	~sentTimeDeltaLocal_1  );
	if( ~timeStampArray1.size > ~timeWindow, {~timeStampArray1.pop;  });

	if( ~sentTimeDeltaLocal_1.abs < ~timeStampArray1.abs.percentile(~percentile)
		,{~filteredArray1.addFirst( ~sentTimeDeltaLocal_1 );

	if( ~filteredArray1.size > ~timeWindow, {~filteredArray1.pop;  });

			[~sentTimeDeltaLocal_2 , ~sentTimeDeltaLocal_1, ~sentTimeDeltaLocal_2 - ~sentTimeDeltaLocal_1].postln;

			~deltadeltaArray1.addFirst(~filteredArray2[0] - ~filteredArray1[0]);
	if( ~deltadeltaArray1.size > ~timeWindow, {~deltadeltaArray1.pop; /*~deltadeltaArray1[~deltadeltaArray1.size-1] = 0;*/});

	} );



	if(~medianSmoothArray1.size == 0,
		{~medianSmoothArray1.addFirst(1)},
		{
			~smoothMedian1 = (~medianSmoothArray1[0] * ~alpha) +  (~deltadeltaArray1[0] * (1 - ~alpha));
			~medianSmoothArray1.addFirst(~smoothMedian1);
		}
	);

//	[~smoothMedian1, ~deltadeltaArray1[0]].postln;
	if( ~medianSmoothArray1.size > ~timeWindow, {~medianSmoothArray1.pop; /*~medianSmoothArray1[~medianSmoothArray1.size-1] = 0;*/});


	{
	~dataPlot1.value_(~timeStampArray1);
	~meanPlot1.value_(~filteredArray1);
	~medianPlot1.value_(~deltadeltaArray1);
	~medianSmoothPlot1.value_(~medianSmoothArray1);
	~win.refresh;
	}.defer;

}, '/tc1', n);


OSCFunc.newMatching({|msg, time, addr, recvPort|

//	time.postln;
//	msg[1].postln;
//	SystemClock.seconds.postln;

	~smoothMedian2 = 0;
	~alpha = 0.9;

	~sentTimeDeltaLocal_2 = time - SystemClock.seconds - 0.02;

	~lastTime2 = time;

	~timeStampArray2.addFirst(	~sentTimeDeltaLocal_2  );
	if( ~timeStampArray2.size > ~timeWindow, {~timeStampArray2.pop;  });

		if( ~sentTimeDeltaLocal_2.abs < ~timeStampArray2.abs.percentile(~percentile)
		,{~filteredArray2.addFirst( ~sentTimeDeltaLocal_2 );

	if( ~filteredArray2.size > ~timeWindow, {~filteredArray2.pop; });

			[~sentTimeDeltaLocal_2 , ~sentTimeDeltaLocal_1, ~sentTimeDeltaLocal_2 - ~sentTimeDeltaLocal_1].postln;

			~deltadeltaArray2.addFirst(~filteredArray2[0] - ~filteredArray1[0]);
	if( ~deltadeltaArray2.size > ~timeWindow, {~deltadeltaArray2.pop; /*~deltadeltaArray1[~deltadeltaArray1.size-1] = 0;*/});

	} );


		if(~medianSmoothArray2.size == 0,
		{~medianSmoothArray2.addFirst(0)},
		{
			~smoothMedian2 = (~medianSmoothArray2[0] * ~alpha) +  (~deltadeltaArray2[0] * (1 - ~alpha));
			~medianSmoothArray2.addFirst(~smoothMedian2);
		}
	);
	if( ~medianSmoothArray2.size > ~timeWindow, {~medianSmoothArray2.pop; /*~medianSmoothArray2[~medianSmoothArray2.size-1] = 0;*/});


	{
	~dataPlot2.value_(~timeStampArray2);
	~meanPlot2.value_(~filteredArray2);
	~medianPlot2.value_(~deltadeltaArray2);
	~medianSmoothPlot2.value_(~medianSmoothArray2);

	~win.refresh;
	}.defer;

}, '/tc2', n);

)

(
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


a = Date.getDate;
a.rawSeconds.postln;

~deltadeltaArray2.minItem
~deltadeltaArray2.maxItem

~filteredArray2.minItem
