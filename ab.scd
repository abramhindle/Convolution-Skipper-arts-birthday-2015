s.options.numBuffers = 16000;
s.boot;
s.scope;
s.freqscope;

/*
	mplayer --loop=0 --gapless-audio -ao jack:port=SuperCollider 07\ -\ Ennio\ Morricone\ -\ Man\ With\ A\ Harmonica.flac 

*/


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
        scratcher = GrainBuf.ar(numChannels:1, trigger:Impulse.kr(rate), dur:(0.001+dur), sndbuf: b1, rate:freq,
			pos:(counter+LFSaw.ar(1.0*freq/(dur+0.001)).range(0,(0.001+dur*44100)))/BufFrames.ir(b1), 
			//pos:(Latch.ar(counter,Impulse.ar(rate))+LFSaw.ar(1.0*freq/dur).range(0,dur*44100))/BufFrames.ir(b1), 
			maxGrains:50);

		convo = Convolution.ar(DelayN.ar(scratcher, delaytime: 0.2), kernelV, fs, 0.5);
		Out.ar(out, amp * (convo + scratcher));	
	}).add();

	s.sync;

	~c1 = Synth.new(\convo,[\b1,~birdb.bufnum,\hop, 10, \dur,3.3,\in,1,\out,0,\fs,128,\rate,10]);
	~c2 = Synth.new(\convo,[\b1,~happyb.bufnum,\hop,11,\dur,0.5,\in,2,\out,1,\fs,512,\rate,4]);
	~c3 = Synth.new(\convo,[\b1,~harshb.bufnum,\hop,12,\dur,0.5,\in,1,\out,1,\fs,512,\rate,5,\amp,0]);
	~c4 = Synth.new(\convo,[\b1,~excitedb.bufnum,\hop,13,\dur,0.5,\in,2,\out,1,\fs,512,\rate,5,\amp,0]);

	~c1.autogui;
	~c2.autogui;
	~c3.autogui;
	~c4.autogui;



	s.sync;

	~cb1 = Bus.control(s, numChannels: 1);
	~cb2 = Bus.control(s, numChannels: 1);
	~v1 = {Out.kr(~cb1, Amplitude.kr(SoundIn.ar(0))); }.play;
	~v2 = {Out.kr(~cb2, Amplitude.kr(SoundIn.ar(1))); }.play;


	~windowmaker = {
		var index = 0, n=16, width=1280,height=800,bright=0.5;
		~arr=0!n;
		~arr2=0!n;
		
		w = Window.new("gui", Rect(0, 0, width, height)).front;
		w.drawFunc = {
      		~arr.do {|item,i|
      			Pen.use {
      				//Pen.rotate(0.2pi);
      				Pen.color = Color.red(if(item > 0.01, {item+bright}, {0}), 1.0);
      				Pen.addRect(
      					Rect(width/n * (index + i) % width, 0, width/n+2, height);
      				);
      				Pen.fill;
      			};			
				
      		};
      		~arr2.do {|item,i|
      			Pen.use {
      				Pen.translate(width/4,-1*height*3/2);
      				Pen.scale(2.5,2.5);
      				Pen.rotate(0.2pi);
      				if(item > 0.01, {
      					Pen.color = Color.blue(item+bright, 1.0);
						
      					Pen.addRect(
      						Rect(0,height/n * (index + i) % height, width,height/n/2+2);
      					);
      					//~arr.size.do {|j|
      					//Pen.addWedge((width/10*j % width)@(height/10 * (index + i) % height), height/10, 0, 2pi/4.0);
      					//};
      					Pen.fill;
      				})
      			};			
      		};
      		index = index + 1;
		};
		w.refresh;
		~w = w;
	};

	~windowmaker.();

	r = Routine( {
      	var index = 0;
      	loop {
      		~cb1.get({|v|			
      			~arr[index % ~arr.size] = 3*v;
      		});
      		~cb2.get({|v|
      			~arr2[index % ~arr2.size] = 3*v;
      			index = index + 1;
      			AppClock.sched(0.0,{ w.refresh });
      		});
      		(1.0/60.0).wait;
      	}
	}).play;
      
	
	
});



