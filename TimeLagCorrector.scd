
(
~win = Window("plot panel", Rect(20, 30, 780, 600)).front;
~dataView = CompositeView(~win, Rect(10, 35, 700, 150)).background_(Color.rand(0.7)).resize_(5);
~dataPlot = Plotter("plot", parent: ~dataView).value_({0}!1 * 100);
~dataPlot.plotMode = \points;

~meanView = CompositeView(~win, Rect(10, 185, 700, 150)).background_(Color.rand(0.7)).resize_(5);
~meanPlot = Plotter("plot", parent: ~meanView).value_({0}!1 * 100);
~meanPlot.plotMode = \points;

~medianView = CompositeView(~win, Rect(10, 335, 700, 150)).background_(Color.rand(0.7)).resize_(5);
~medianPlot = Plotter("plot", parent: ~medianView).value_({0}!1 * 100);
~medianPlot.plotMode = \points;

~timeStampArray = List.new;
~meanArray = List.new;
~medianArray = List.new;

n = NetAddr("127.0.0.1", 57120); // local machine

OSCFunc.newMatching({|msg, time, addr, recvPort|

~timeWindow = 100;

//	time.postln;
//	msg[1].postln;
//	SystemClock.seconds.postln;

	~timeStampArray.addFirst(time - SystemClock.seconds);
	if( ~timeStampArray.size > ~timeWindow, {~timeStampArray.pop; ~timeStampArray[~timeStampArray.size-1] = 0; });
    ~meanArray.addFirst(~timeStampArray.mean);
	if( ~meanArray.size > ~timeWindow, {~meanArray.pop;  ~meanArray[~meanArray.size-1] = 0;});
	~medianArray.addFirst(~timeStampArray.median);
	if( ~medianArray.size > ~timeWindow, {~medianArray.pop; ~medianArray[~medianArray.size-1] = 0;});

	{
	~dataPlot.value_(~timeStampArray);
	~meanPlot.value_(~meanArray);
	~medianPlot.value_(~medianArray);	w.refresh;
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

