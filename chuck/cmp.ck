adc => Faust fck => NRev rev=>dac;
0.6 => rev.mix;
// evaluate FAUST code
// -- (use ` to avoid escaping " and ')
// -- (auto import libs: stdfaust)
fck.eval(`
bitcrush(num,input) =((input+1)/2) :*(num):rint:/(num);

att = hslider("attack",1,0.001,10,0.01);
rel = hslider("release",1,0.001,10,0.01);
env = an.amp_follower_ar(att,rel);
meter = hbargraph("meter",0,1);
gainmeter = hbargraph("gain",0,1);

impulse(freq) = os.oscp(freq,0) : (>(0));
diff = _ <:(_,mem):(!=);
hp = os.lf_sawpos(0.1):*(8000):+(200);
hat = (impulse(10.1),impulse(10.5)):xor:diff:fi.resonhp(hp,12,1);

osc = (impulse(1),impulse(1.2)):xor:diff :fi.resonlp(250,5,5);

gain(thresh,input) = <(attach(input:env,input:env:meter),  thresh);

myproc(input) = input * attach(mgain,mgain:gainmeter)with{
    mgain = gain(0.02,input);
};

freq = hslider("freq",1000,20,20000,0.1);

bpf = fi.resonlp(freq,2,1);

fbdelay(fb,dtime) = + ~ (*(3):atan:myproc:de.sdelay(48000,48000,dtime):*(fb));

dtime = hslider("delaytime",1000,10,47999,0.01);

process1=*(2)<:((myproc:bpf)):>*(0.5);
process = process1;
`);

// time loop
float attack;
1=>attack;
float freq;
1000=>freq;
float dtime;
1000=>dtime;
fun void dmod(){
    while(true){
        (dtime+68500)%48000=>dtime;
    fck.v("delaytime",dtime);
    2::second=>now;
}
    }

spork ~ dmod();

while( true )
{
    // set (will auto append /0x00/)
    // print snapshot
    (attack+5.72042)%2=>attack;
    fck.dump();
    fck.v("attack",attack);
    fck.v("release",attack);
    fck.v("freq",freq);
    (freq+5500)%8355=>freq;

    // advance time
    1000::ms => now;
}
