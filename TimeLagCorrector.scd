
(
~win = Window("plot panel", Rect(20, 30, 780, 600)).front;
~dataView1 = CompositeView(~win, Rect(10, 35, 350, 150)).background_(Color.rand(0.7)).resize_(5);
~dataPlot1 = Plotter("plot", parent: ~dataView1).value_({0}!1 * 100);
~dataPlot1.plotMode = \points;

~meanView1 = CompositeView(~win, Rect(10, 185, 350, 150)).background_(Color.rand(0.7)).resize_(5);
~meanPlot1 = Plotter("plot", parent: ~meanView1).value_({0}!1 * 100);
~meanPlot1.plotMode = \points;

~medianView1 = CompositeView(~win, Rect(10, 335, 350, 150)).background_(Color.rand(0.7)).resize_(5);
~medianPlot1 = Plotter("plot", parent: ~medianView1).value_({0}!1 * 100);
~medianPlot1.plotMode = \points;


~dataView2 = CompositeView(~win, Rect(360, 35, 350, 150)).background_(Color.rand(0.7)).resize_(5);
~dataPlot2 = Plotter("plot", parent: ~dataView2).value_({0}!1 * 100);
~dataPlot2.plotMode = \points;

~meanView2 = CompositeView(~win, Rect(360, 185, 350, 150)).background_(Color.rand(0.7)).resize_(5);
~meanPlot2 = Plotter("plot", parent: ~meanView2).value_({0}!1 * 100);
~meanPlot2.plotMode = \points;

~medianView2 = CompositeView(~win, Rect(360, 335, 350, 150)).background_(Color.rand(0.7)).resize_(5);
~medianPlot2 = Plotter("plot", parent: ~medianView2).value_({0}!1 * 100);
~medianPlot2.plotMode = \points;


~timeStampArray1 = List.new;
~meanArray1 = List.new;
~medianArray1 = List.new;

~timeStampArray2 = List.new;
~meanArray2 = List.new;
~medianArray2 = List.new;

n = NetAddr("127.0.0.1", 57120); // local machine

OSCFunc.newMatching({|msg, time, addr, recvPort|

~timeWindow = 90;

//	time.postln;
//	msg[1].postln;
//	SystemClock.seconds.postln;

	~timeStampArray1.addFirst(time - SystemClock.seconds);
	if( ~timeStampArray1.size > ~timeWindow, {~timeStampArray1.pop; ~timeStampArray1[~timeStampArray1.size-1] = 0; });
    ~meanArray1.addFirst(~timeStampArray1.mean);
	if( ~meanArray1.size > ~timeWindow, {~meanArray1.pop;  ~meanArray1[~meanArray1.size-1] = 0;});
	~medianArray1.addFirst(~timeStampArray1.median);
	if( ~medianArray1.size > ~timeWindow, {~medianArray1.pop; ~medianArray1[~medianArray1.size-1] = 0;});

	{
	~dataPlot1.value_(~timeStampArray1);
	~meanPlot1.value_(~meanArray1);
	~medianPlot1.value_(~medianArray1);	w.refresh;
	}.defer;

}, '/delay1', n);

)


(
m = NetAddr("127.0.0.1", 57120); // loopback

t = Task({
    inf.do({
       m.sendMsg("/delay1", SystemClock.seconds);
		        (30.reciprocal).wait;
    });
}).start;
)





a = Date.getDate;
a.rawSeconds.postln;

