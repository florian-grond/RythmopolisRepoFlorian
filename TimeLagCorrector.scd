(
~plotwidth = 500;
~plotheight = 130;
~win = Window("plot panel", Rect(30, 30, (~plotwidth * 2) + 40, 600)).front;

~ratioSlider = Slider(~win, Rect(10, 10, 15, 520));

~dataView1 = CompositeView(~win, Rect(30, 10 + (~plotheight* 0), ~plotwidth, ~plotheight)).background_(Color.rand(0.7)).resize_(5);
~dataPlot1 = Plotter("plot", parent: ~dataView1).value_({0}!1 * 100);
~dataPlot1.plotMode = \points;

~meanView1 = CompositeView(~win, Rect(30, 10 + (~plotheight* 1), ~plotwidth, ~plotheight)).background_(Color.rand(0.7)).resize_(5);
~meanPlot1 = Plotter("plot", parent: ~meanView1).value_({0}!1 * 100);
~meanPlot1.plotMode = \points;

~medianView1 = CompositeView(~win, Rect(30, 10 + (~plotheight* 2), ~plotwidth, ~plotheight)).background_(Color.rand(0.7)).resize_(5);
~medianPlot1 = Plotter("plot", parent: ~medianView1).value_({0}!1 * 100);
~medianPlot1.plotMode = \points;

~medianSmoothView1 = CompositeView(~win, Rect(30, 10 + (~plotheight* 3), ~plotwidth, ~plotheight)).background_(Color.rand(0.7)).resize_(5);
~medianSmoothPlot1 = Plotter("plot", parent: ~medianSmoothView1).value_({0}!1 * 100);
~medianSmoothPlot1.plotMode = \points;



~dataView2 = CompositeView(~win, Rect(~plotwidth + 30, 10 + (~plotheight* 0), ~plotwidth, ~plotheight)).background_(Color.rand(0.7)).resize_(5);
~dataPlot2 = Plotter("plot", parent: ~dataView2).value_({0}!1 * 100);
~dataPlot2.plotMode = \points;

~meanView2 = CompositeView(~win, Rect(~plotwidth + 30, 10 + (~plotheight* 1), ~plotwidth, ~plotheight)).background_(Color.rand(0.7)).resize_(5);
~meanPlot2 = Plotter("plot", parent: ~meanView2).value_({0}!1 * 100);
~meanPlot2.plotMode = \points;

~medianView2 = CompositeView(~win, Rect(~plotwidth + 30, 10 + (~plotheight* 2), ~plotwidth, ~plotheight)).background_(Color.rand(0.7)).resize_(5);
~medianPlot2 = Plotter("plot", parent: ~medianView2).value_({0}!1 * 100);
~medianPlot2.plotMode = \points;

~medianSmoothView2 = CompositeView(~win, Rect(~plotwidth + 30, 10 + (~plotheight* 3), ~plotwidth, ~plotheight)).background_(Color.rand(0.7)).resize_(5);
~medianSmoothPlot2 = Plotter("plot", parent: ~medianSmoothView2).value_({0}!1 * 100);
~medianSmoothPlot2.plotMode = \points;


~timeStampArray1 = List.new;
~meanArray1 = List.new;
~medianArray1 = List.new;
~medianSmoothArray1 = List.new;

~timeStampArray2 = List.new;
~meanArray2 = List.new;
~medianArray2 = List.new;
~medianSmoothArray2 = List.new;


n = NetAddr("127.0.0.1", 57120); // local machine

OSCFunc.newMatching({|msg, time, addr, recvPort|

~timeWindow = 380;
	~alpha = 0.98;

//	time.postln;
//	msg[1].postln;
//	SystemClock.seconds.postln;

	~timeStampArray1.addFirst(time - SystemClock.seconds);
	if( ~timeStampArray1.size > ~timeWindow, {~timeStampArray1.pop; ~timeStampArray1[~timeStampArray1.size-1] = 0; });
    ~meanArray1.addFirst(~timeStampArray1.mean);
	if( ~meanArray1.size > ~timeWindow, {~meanArray1.pop;  ~meanArray1[~meanArray1.size-1] = 0;});
	~medianArray1.addFirst(~timeStampArray1.median);
	if( ~medianArray1.size > ~timeWindow, {~medianArray1.pop; /*~medianArray1[~medianArray1.size-1] = 0;*/});

	if(~medianSmoothArray1.size == 0,
		{~medianSmoothArray1.addFirst(~medianArray1[0])},
		{
			~smoothMedian1 = (~medianSmoothArray1[0] * ~alpha) +  (~medianArray1[0] * (1 - ~alpha));
			~medianSmoothArray1.addFirst(~smoothMedian1);
		}
	);

//	[~smoothMedian1, ~medianArray1[0]].postln;
	if( ~medianSmoothArray1.size > ~timeWindow, {~medianSmoothArray1.pop; /*~medianSmoothArray1[~medianSmoothArray1.size-1] = 0;*/});


	{
	~dataPlot1.value_(~timeStampArray1);
	~meanPlot1.value_(~meanArray1);
	~medianPlot1.value_(~medianArray1);
	~medianSmoothPlot1.value_(~medianSmoothArray1);
	~win.refresh;
	}.defer;

}, '/delay1', n);


OSCFunc.newMatching({|msg, time, addr, recvPort|


//	time.postln;
//	msg[1].postln;
//	SystemClock.seconds.postln;

	~smoothMedian2 = 0;
	~alpha = 0.9;

	~timeStampArray2.addFirst(time - SystemClock.seconds);
	if( ~timeStampArray2.size > ~timeWindow, {~timeStampArray2.pop; ~timeStampArray2[~timeStampArray2.size-1] = 0; });
    ~meanArray2.addFirst(~timeStampArray2.mean);
	if( ~meanArray2.size > ~timeWindow, {~meanArray2.pop;  ~meanArray2[~meanArray2.size-1] = 0;});
	~medianArray2.addFirst(~timeStampArray2.median);
	if( ~medianArray2.size > ~timeWindow, {~medianArray2.pop; /* ~medianArray2[~medianArray2.size-1] = 0; */});

		if(~medianSmoothArray2.size == 0,
		{~medianSmoothArray2.addFirst(~medianArray2[0])},
		{
			~smoothMedian2 = (~medianSmoothArray2[0] * ~alpha) +  (~medianArray2[0] * (1 - ~alpha));
			~medianSmoothArray2.addFirst(~smoothMedian2);
		}
	);
	if( ~medianSmoothArray2.size > ~timeWindow, {~medianSmoothArray2.pop; /*~medianSmoothArray2[~medianSmoothArray2.size-1] = 0;*/});


	{
	~dataPlot2.value_(~timeStampArray2);
	~meanPlot2.value_(~meanArray2);
	~medianPlot2.value_(~medianArray2);
	~medianSmoothPlot2.value_(~medianSmoothArray2);

		~ratioSlider.value_((~medianSmoothArray2[0] / ~medianSmoothArray1[0]).linlin(0.9, 1.10, 0.0, 1.0) );
	~win.refresh;
	}.defer;

}, '/delay2', n);

)


(
m = NetAddr("127.0.0.1", 57120); // loopback

~t1 = Task({
    inf.do({
       m.sendMsg("/delay1", SystemClock.seconds);
		        (30.reciprocal).wait;
    });
}).start;

~t2 = Task({
    inf.do({
       m.sendMsg("/delay2", SystemClock.seconds);
		        (30.reciprocal + 0.01).wait;
    });
}).start;
)




a = Date.getDate;
a.rawSeconds.postln;

