//computer_only_loop

adc => Faust fck =>dac;

fck.eval(`
bitcrush(freq,num,input) =((input+1)/2):*(num):rint:/(num):-(0.5):ba.downSample(freq);

myproc(thresh,input) = input * gain with{
     loudness = input :abs:si.smooth(0.9);
    logic = loudness , thresh : <;
    gain = select2(logic,0,1);
};

loop(dtime) =  *(0.2): (+:de.fdelay(48000,dtime))~(*(1.4):myproc(0.01):bitcrush(10000,1000):*(os.lf_sawpos(0.05)<0.9));


process =loop(2000-os.lf_sawpos(1)*2000),loop(3000-os.lf_sawpos(1)*3000) : *(1.2),*(1.2):dm.zita_light;

`);




while( true )
{
    fck.v("/Zita_Light/Dry/Wet_Mix",0);
    fck.v("/Zita_Light/Level",0);
    fck.dump();
    1000::ms=> now;
}