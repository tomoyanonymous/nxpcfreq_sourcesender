adc => Faust fck =>dac;



fck.eval(`
bitcrush(freq,num,input) =((input+1)/2):*(num):rint:/(num):-(0.5):ba.downSample(freq);
fdelay(fb,dtime) = (+:de.fdelay(48000,dtime))~(*(fb));

impulse(freq) = os.oscp(freq,0) : (>(0));
diff = _ <:(_,mem):(!=);
hp = os.osc(0.1):*(8000):+(200);
hat = (impulse(2.1),impulse(3.5)):xor:diff:fi.resonhp(8000,2,0.1):fdelay(0.7,os.osc(0.1) *1000+20 );

kick = (impulse(2),impulse(0.3)):xor:diff <:*(0.9),fi.resonlp(80,5,12):>atan:atan:atan;


master = kick*5+hat;
process = master,master : dm.zita_light;
`);
245=>float freq;

while( true )
{

    fck.v("/Zita_Light/Dry/Wet_Mix",0);
    fck.v("/Zita_Light/Level",0);
    // advance time
    1000::ms => now;
}
