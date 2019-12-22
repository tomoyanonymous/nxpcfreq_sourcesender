adc => Faust fck =>dac;


fck.eval(`
comp(thresh,input) = input * gain*0.01 with{
    loudness = input :abs:si.smooth(0.9);
    logic = loudness , thresh : <;
    gain = select2(logic,(thresh/loudness),1);
};

master = de.fdelay(48000,48000-os.lf_sawpos(0.3)*45000)*(0.1);
process=  master,master;
`);


while(true){
    fck.dump();
    1::second =>now;
}