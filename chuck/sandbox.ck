adc => Faust fck =>dac;


fck.eval(`
bitcrush(freq,num,input) =((input+1)/2):*(num):rint:/(num):-(0.5):ba.downSample(freq);
fdelay(fb,dtime) = (+:de.fdelay(48000,dtime))~(*(fb));

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

master = _;
process=  master,master;
`);


while(true){
    fck.dump();
    1::second =>now;
}