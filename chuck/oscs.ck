adc => Faust fck => dac;

fck.eval(`
att = hslider("attack",0.01,0.001,10,0.01);
rel = hslider("release",0.01,0.001,10,0.01);
env = an.amp_follower_ar(att,rel);

bitcrush(num,input) =((input+1)/2) :*(num):rint:/(num);

gain(thresh,input) = <((input:env),  thresh);

myproc(input) = gain(1,input);

fbpass(dtime) = *(2):atan:myproc:de.sdelay(48000,48000,dtime);

fbdelay(fb,dtime) = + ~ (fbpass(dtime):*(fb));
dtime = hslider("delaytime",30000,10,47999,0.01);


osc(f) = os.lf_sawpos(f);

siren = osc(0.05):*(20):+(0.2):osc:*(500):+(80):osc;
ff = os.lf_sawpos(0.12):*(4000):+(100);
master = siren *(0.05):fi.resonhp(ff,2,12);
process = master,master ;
//process = os.oscp(1000,0):ba.downSample(100):bitcrush(4);
`);

while( true )
{
    // set (will auto append /0x00/)
    // print snapshot
    fck.dump();

    // advance time
    2000::ms => now;
}