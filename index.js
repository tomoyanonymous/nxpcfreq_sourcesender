const fs = require('fs')
const process= require('process')
const path  = require('path')
const  osc = require('node-osc')
const commandLineArgs = require('command-line-args')

const cwd = process.cwd();


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

const client = new osc.Client(options.address, options.port);

console.log("OSC Address: " + options.address + ":" + options.port )

const filesender = (err, data) => {
    if (err) throw err;    // 例外発生時の処理
    client.send('/sourcecode',data)

  }
const filereader = (event,filename) =>{
    if(event == 'change'){
        console.log(event + ":" + filename)
    client.send('/filename',filename)
    fs.readFile(cwd + '/chuck/' + filename, 'utf-8', filesender)
    }
}

console.log("watching file under: '" + options.files + "'")


fs.watch(options.files,{'recursive':true },filereader)


