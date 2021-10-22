require('dotenv').config();
const Web3 = require('web3');

import { basicSolABI } from "../abis/L2HelloWorld-abi";

const web3 = new Web3(new Web3.providers.HttpProvider(process.env.L2Provider))

const ContractAdress = "0xd4d1978260de61Da8CC01EdEd31eeDf3bEaA0393"
const Contract = new web3.eth.Contract(basicSolABI, ContractAdress)

console.log(Contract.methods)

setTimeout(async () =>{

    const dataFromContract = await Contract.methods.get().call();

    console.log(dataFromContract);

}, 1)

