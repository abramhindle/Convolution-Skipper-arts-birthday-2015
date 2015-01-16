s.options.numBuffers = 16000;
s.boot;
s.scope;
s.freqscope;

/*
	mplayer --loop=0 --gapless-audio -ao jack:port=SuperCollider 07\ -\ Ennio\ Morricone\ -\ Man\ With\ A\ Harmonica.flac 

*/


SynthDef(\bbb, {
	|b,x=0,y=0,xvel=0,yvel=0,out=0,accel=100,amp=0.5,rate=1.0|
	Out.ar(out,
		amp * Mix.ar(
			BufRd.ar(1, b, LFSaw.ar(rate*(x/1000.0)*BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b))),
			BufRd.ar(1, b, LFSaw.ar(rate*(y/1000.0)*BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b))),
			BufRd.ar(1, b, LFSaw.ar(((yvel*xvel)/(50*50.0))*BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b))),
		))
}).add();


s.doWhenBooted({
	~path = "~/projects/single-celled-doubt/";
	~path + "what";
	~happyb = Buffer.read(s,"goldberg-aria-da-capo.wav");
	~harshb = Buffer.read(s,"peergynt5.wav");
	~excitedb = Buffer.read(s,"peergynt2.wav");
	~sadb = Buffer.read(s,"Gesualdo-O_vos_omnes-stretch.wav");
	~birdb = Buffer.read(s,"india-bird-reverb-clean.wav");
	s.sync;

	SynthDef(\reverb, {|out=0,in=0, mix=0.25, room=0.15, damp=0.5, amp=1.0|
		var signal = In.ar(in,2);
		ReplaceOut.ar(out,FreeVerb2.ar(signal[0],signal[1], mix, room, damp, amp))
	}).add;

	SynthDef(\convo, {
		arg b1, out=0,in=1, mix=0.33, room=0.5, damp=0.5, mul=1.0, add=0, fs=512, hop=100, dur=3.0, rate=30, amp=1.0, freq=1.0;
		var input, kernel, kernelV, convo, scratcher, counter;
		kernel = AudioIn.ar(in);
		kernelV = FreeVerb.ar(kernel, mix, room, damp, mul,add);
		//counter = Stepper.ar(kernelV,min: 0.0, max: 1.0, step: 0.0001);
		counter = Stepper.ar(kernelV,0,0,BufFrames.ir(b1),hop,-1); 

		//scratcher = BufRd.ar(1, b1, Latch.ar(counter,Impulse.ar(rate))+LFSaw.ar(1.0*freq/dur).range(0,dur*44100));
        scratcher = GrainBuf.ar(numChannels:1, trigger:Impulse.kr(rate), dur:dur, sndbuf: b1, rate:freq,
			pos:(counter+LFSaw.ar(1.0*freq/dur).range(0,dur*44100))/BufFrames.ir(b1), 
			//pos:(Latch.ar(counter,Impulse.ar(rate))+LFSaw.ar(1.0*freq/dur).range(0,dur*44100))/BufFrames.ir(b1), 
			maxGrains:50);

		convo = Convolution.ar(DelayN.ar(scratcher, delaytime: 0.2), kernelV, fs, 0.5);
		Out.ar(out, amp * (convo + scratcher));	
	}).add();

	s.sync;

	~c1 = Synth.new(\convo,[\b1,~birdb.bufnum, \dur,3.3,\in,1,\out,0,\fs,128,\rate,10,\hop,10]);
	~c2 = Synth.new(\convo,[\b2,~harshb.bufnum,\dur,0.5,\in,2,\out,1,\fs,512,\rate,10,\hop,100]);
	~c1.autogui;
	~c2.autogui;

});

{ Out.ar(4,AudioIn.ar(1).scope) }.play
{ Out.ar(4,AudioIn.ar(2).scope) }.play
{ Out.ar(4,Bus.audio(s,16).scope) }.play

Bus.new(rate: 'audio', index: 16, numChannels: 2, s).scope

b= ~happyb;
r = {
	Out.ar(0, BufRd.ar(1, b, 10*44100 + LFSaw.ar(1.0/3.0).range(0,3.0*44100)))
}.play;
SynthDef("help-Stepper",{ arg out=0;
    Out.ar(out,
        SinOsc.ar(
            Stepper.kr(Impulse.kr(10), 0, 1, 32, -3) * 100,
            0, 0.05
        )
    )
}).play;


{
		arg b, mix=0.33, room=0.5, damp=0.5, mul=1.0, add=0, fs=512, hop=100, dur=3.0, rate=30;
		var input, kernel, kernelV, convo, scratcher, counter;
		input=AudioIn.ar(2);	
		kernel = AudioIn.ar(1);
	    kernelV = FreeVerb.ar(kernel, mix, room, damp, mul,add);
	    Out.ar(0, kernelV)
}.play;
s.scope;


~c1 = Bus.control(s, numChannels: 1);
~c2 = Bus.control(s, numChannels: 1);
~v1 = {Out.kr(~c1, Amplitude.kr(SoundIn.ar(0))); }.play;
~v2 = {Out.kr(~c2, Amplitude.kr(SoundIn.ar(1))); }.play;

(
    var index = 0, n=20;
    ~arr=0!n;
    ~arr2=0!n;

    w = Window.new("gui", Rect(0, 0, 1024, 768)).front;
    w.drawFunc = {
		~arr.do {|item,i|
			Pen.use {
				//Pen.rotate(0.2pi);
				Pen.color = Color.red(if(item > 0.01, {item+0.3}, {0}), 1.0);
				Pen.addRect(
					Rect(1024/n * (index + i) % 1024, 0, 1024/n+2, 768);
				);
				Pen.fill;
			};			

		};
		~arr2.do {|item,i|
			Pen.use {
				Pen.translate(1024/4,-768*3/2);
				Pen.scale(2.5,2.5);
				Pen.rotate(0.2pi);
				if(item > 0.01, {
					Pen.color = Color.blue(item+0.3, 1.0);

					Pen.addRect(
						Rect(0,768/n * (index + i) % 768, 1024,768/n/2+2);
					);
					//~arr.size.do {|j|
					//Pen.addWedge((1024/10*j % 1024)@(768/10 * (index + i) % 768), 768/10, 0, 2pi/4.0);
					//};
					Pen.fill;
				})
			};			
		};
		index = index + 1;
    };
    w.refresh;
)

r = Routine( {
	var index = 0;
	loop {
		~c1.get({|v|			
			~arr[index % ~arr.size] = 3*v;
		});
		~c2.get({|v|
			~arr2[index % ~arr2.size] = 3*v;
			index = index + 1;
			AppClock.sched(0.0,{ w.refresh });
		});
		(1.0/30.0).wait;
	}
}).play;

r.free;
