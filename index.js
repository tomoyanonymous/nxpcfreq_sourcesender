const fs = require('fs');
const path = require('path');
const osc = require('node-osc');
const commandLineArgs = require('command-line-args');
const chokidar = require('chokidar');

const optionDefinitions = [
    {
        name: 'files',
        type: String,
        defaultValue: "chuck"
    },
    {
        name: 'address',
        type: String,
        defaultValue: '127.0.0.1'
    },
    {
        name: 'port',
        type: Number,
        defaultValue: 8888
    }
];
const options = commandLineArgs(optionDefinitions);

/*
    create osc client
*/
const client = new osc.Client(options.address, options.port);
console.log("OSC Address: " + options.address + ":" + options.port);

/*
    define watcher's callback functions
*/
const onReady = () => {
    console.log("watching file under: '" + options.files + "'");
};
const onChange = (filepath) => {
    console.log('/onChange', filepath);

    const abspath = path.resolve('', filepath);
    const filename = path.basename(filepath);
    fs.readFile(abspath, 'utf-8', (err, data) => {
        if (err) throw err;
        client.send('/onChange', filename, data);
    });
}


/*
    start watching files
*/
const watcher = chokidar.watch(options.files, { persistent: true });
watcher
    .on('ready', onReady)
    .on('change', onChange);
