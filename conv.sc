s.options.numBuffers = 16000;
s.boot;
s.scope;
s.freqscope;

(
x = { 
	arg mix=0.33, room=0.5, damp=0.5, mul=1.0, add=0, fs=512;
	var input, kernel;
	input=AudioIn.ar(2);	
	kernel = AudioIn.ar(1);
	
	//kernel= SinOsc.ar(freq: 440, mul: 0.1);
	//kernel= Mix.ar(LFSaw.ar([300,500,800,1000]*MouseX.kr(1.0,2.0),0,1.0));
	//must have power of two framesize
	Out.ar(0,Convolution.ar(input, FreeVerb.ar(kernel, mix, room, damp, mul,add)  , fs, 0.5));	
}.play;
)
x.set(\mix, 1.0)
x.set(\damp, 0.1)
x.set(\room, 0.8)


(

//must have power of two framesize- FFT size will be sorted by Convolution to be double this

//maximum is currently a=8192 for FFT of size 16384

a=2048;

s = Server.local; 

//kernel buffer

g = Buffer.alloc(s,a,1);

)


(

//random impulse response

g.set(0,1.0);

100.do({arg i; g.set(a.rand, sin(10*i))});
a.do({arg i; g.set(i,sin(10*i))})


{ var input, kernel;

input=AudioIn.ar(1);	

kernel= PlayBuf.ar(1,g.bufnum,BufRateScale.kr(g.bufnum),1,0,1);

Out.ar(0,Convolution.ar(input,kernel, 2*a, 0.5));

}.play;


)