//bass drone audio feedback


adc => Faust fck =>dac;

[ 1., 0.5, 2., 1., 1., 2. ,0.5,2.] @=> float timedarray[];
0=>int index;

fck.eval(`
bitcrush(freq,num,input) =((input+1)/2):*(num):rint:/(num):-(0.5):ba.downSample(freq);
fdelay(fb,dtime) = (+:de.fdelay(48000,dtime))~(*(fb));
att = hslider("attack",1,0.001,10,0.01);
rel = hslider("release",1,0.001,10,0.01);
env = an.amp_follower_ar(att,rel);
meter = hbargraph("meter",0,1);
gainmeter = hbargraph("gain",0,1);

impulse(freq) = os.oscp(freq,0) : (>(0));
diff = _ <:(_,mem):(!=);
hp = os.osc(0.1):*(8000):+(200);
hat = (impulse(2.1),impulse(3.5)):xor:diff:fi.resonhp(8000,2,0.1):fdelay(0.7,os.osc(0.1) *1000+20 );

osc = (impulse(0.5),impulse(0.3)):xor:diff <:*(0.9),fi.resonlp(125,5,5):>atan:atan:atan;

gain(thresh,input) = (input:env),  thresh : <;

myproc(thresh,input) = input * mgain with{
    mgain = gain(thresh,input):si.smooth(0.9);
};

comp(thresh,input) = input * gain with{
    loudness = input :abs:si.smooth(0.9999);
    logic = loudness , thresh : <;
    gain = select2(logic,(thresh/loudness),1);
};
gate(thresh,input) =   input * gain with{
    logic = (input:abs:si.smooth(0.999)) , thresh : <;
    gain = select2(logic,1,0.):si.smooth(0.01);
};

freq = hslider("freq",1000,20,20000,0.1):si.smooth(0.9);

bpf = fi.resonbp(freq,3,1);

fbdelay(fb,dtime) =  (+:*(7):atan:myproc(0.03):de.fdelay(96000,dtime))~*(fb);

dtime = hslider("delaytime",1000,10,47999,0.01):si.smooth(0.9);

//process1=*(1.2)<:((myproc(0.02):bpf:gate(0.003)),fbdelay(0.9,dtime)):>*(0.9999);
process1 = comp(0.01):bpf:bitcrush(8000,200):*(1);
master =_<: process1,fbdelay(1.1,dtime):>_;//:bitcrush(10,1000):*(os.oscp(2,0)*os.lf_sawpos(1.2)):gate(0.001):fbdelay(0.998,(os.lf_sawpos(0.2):<(0.5):*(10):+(10):si.smooth(0.9999)));
process = master,master;
`);
1000=>float freq;

while( true )
{
    fck.dump();

    fck.v("freq",freq);
    (freq*8.6)%200+40=>freq;
    
    (index+1)%8=>index;
    <<<index>>>;
    // advance time
    (timedarray[index]*1000)::ms => now;
}
