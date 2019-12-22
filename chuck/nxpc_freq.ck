//main

adc => Faust fck => dac;

[ 1., 0.5, 2., 1., 1., 2. ,0.5,2.] @=> float timedarray[];
0=>int index;

fck.eval(`
bitcrush(freq,num,input) =((input+1)/2):*(num):rint:/(num):-(0.5):ba.downSample(freq);

att = hslider("attack",1,0.001,10,0.01);
rel = hslider("release",1,0.001,10,0.01);
env = an.amp_follower_ar(att,rel);
meter = hbargraph("meter",0,1);
gainmeter = hbargraph("gain",0,1);

myproc(thresh,input) = input * gain with{
    loudness = input :env;
    logic = loudness , thresh : <;
    gain = select2(logic,0,1);
};
comp(thresh,input) = input * gain*0.01 with{
    loudness = input :abs:si.smooth(0.9);
    logic = loudness , thresh : <;
    gain = select2(logic,(thresh/loudness),1);
};

gate(thresh,input) =   input * gain with{
    logic = (input:abs:si.smooth(0.92)) , thresh : <;
    gain = select2(logic,1,0.):si.smooth(0.01);
    };

freq = hslider("freq",1000,20,20000,0.1):si.smooth(0.1);

bpf = fi.resonbp(freq,12,1);

fbdelay(fb,dtime) =  (+:*(2):atan:myproc(0.02):bitcrush(201,11):de.fdelay(96000,dtime))~*(fb);

dtime = hslider("delaytime",1000,10,96000,0.01):si.smooth(0.99);

process1=*(0.7)<:((myproc(0.01):bpf:bitcrush(0.1,3))):>*(0.9999);
//process1 = *(0.1)<:((myproc(0.02):bpf):>*(0.999):_;
master = process1;
process = master,master ;
`);



// time loop
float attack;
1=>attack;
float freq;
1000=>freq;
float dtime;
1234=>dtime;
fun void dmod(){
    while(true){
        (dtime+72985)%96000=>dtime;
    fck.v("delaytime",dtime);
    0.5::second=>now;
}
    }

spork ~ dmod();


while( true )
{
    // set (will auto append /0x00/)
    // print snapshot
    (attack+0.736)%0.01=>attack;
    //fck.dump();
    fck.v("attack",attack);
    fck.v("release",attack);
    fck.v("freq",freq);
    (freq*8.6)%4096+120=>freq;

    (index+1)%8=>index;
    <<<index>>>;
    // advance time
    (timedarray[index]*100)::ms => now;
  }
