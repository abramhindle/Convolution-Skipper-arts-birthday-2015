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
		arg b, mix=0.33, room=0.5, damp=0.5, mul=1.0, add=0, fs=512, hop=100, dur=3.0, rate=30;
		var input, kernel, kernelV, convo, scratcher, counter;
		input=AudioIn.ar(2);	
		kernel = AudioIn.ar(1);
		kernelV = FreeVerb.ar(kernel, mix, room, damp, mul,add);
		//counter = Stepper.ar(kernelV,min: 0.0, max: 1.0, step: 0.0001);
		counter = Stepper.ar(Amplitude.ar(kernelV),0,0,BufFrames.ir(b),hop,-1); //,min: 0.0, max: 1.0, step: 0.0001);
		//scratcher = BufRd.ar(1, b, LFSaw.ar(1.0*BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b)));
		// only moved by sound
		//scratcher = BufRd.ar(1, b, counter.range(0, BufFrames.ir(b)));
		// repeats
		scratcher = BufRd.ar(1, b, Latch.ar(counter,Impulse.ar(rate))+LFSaw.ar(1.0/dur).range(0,dur*44100));
		Out.ar(16, kernelV);
		convo = Convolution.ar(DelayN.ar(scratcher, delayTime: 0.2), kernelV, fs, 0.5);
		Out.ar(0, [convo + scratcher, counter]);	
	}).add();

	s.sync;

	~convo = Synth.new(\convo,[\b,~harshb.bufnum]);
	~convo.set(\mix, 1.0);
	~convo.set(\damp, 0.1);
	~convo.set(\room, 0.8);
	~convo.autogui;

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
