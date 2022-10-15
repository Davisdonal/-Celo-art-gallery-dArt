
import './App.css';

import { NavigationBar } from './components/navigation';
import { Arts } from './components/arts';
import { AddArt } from './components/addart';


import { useState, useEffect, useCallback } from "react";


import Web3 from "web3";
import { newKitFromWeb3 } from "@celo/contractkit";
import BigNumber from "bignumber.js";


import tech from "./contracts/TechArt.abi.json";  
import IERC from "./contracts/IERC20Token.abi.json";


const ERC20_DECIMALS = 18;  //for wei or gwei



const contractAddress = "0x29ECF190606214F6B1B53D9a3591D49d25cb2F04";  // contract address for the Dart
const cUSDContractAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1"; // contract address for the cUSD Token




function App() {
  const [contract, setcontract] = useState(null);
  const [address, setAddress] = useState(null);
  const [kit, setKit] = useState(null);
  const [cUSDBalance, setcUSDBalance] = useState(0);
  const [arts, setArts] = useState([]);



/*************************** Prompt Celo Wallet To Allow User Connect **********************************************************/
  const connectToWallet = async () => {
    if (window.celo) {
      
      try {
        await window.celo.enable();
        const web3 = new Web3(window.celo);
        let kit = newKitFromWeb3(web3);

        const accounts = await kit.web3.eth.getAccounts();
        const user_address = accounts[0];
        kit.defaultAccount = user_address;

        await setAddress(user_address);
        await setKit(kit);
      } catch (error) {
        
      }
    } else {
      
    }
  };

  
  
/*************************** Retrieving Balance Of User From Their Celo Wallet    **********************************************************/
  const getBalance = useCallback(async () => {
    try {
      const balance = await kit.getTotalBalance(address);
      const USDBalance = balance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2);

      const contract = new kit.web3.eth.Contract(tech, contractAddress);
      setcontract(contract);
      setcUSDBalance(USDBalance);
    } catch (error) {
      console.log(error);
    }
  }, [address, kit]);



  /*************************** Renders The Art Array After Info Has Been Pushed Into It **********************************************************/
  const getArts = useCallback(async () => {
    const artsLength = await contract.methods.getArtsLength().call();
    const arts = [];
    for (let index = 0; index < artsLength; index++) {
      let _arts = new Promise(async (resolve, reject) => {
      let art = await contract.methods.getArt(index).call();

        resolve({
          index: index,
          owner: art[0],
          image: art[1],
          description: art[2],
          tip: art[3]  
        });
      });
      arts.push(_arts);
    }

    const _arts = await Promise.all(arts);
    setArts(_arts);
  }, [contract]);

/*************************** Add Arts Template  **********************************************************/

  const addArt = async (
    _image,
    _description,
    _tip
 
  ) => {
    let tip = new BigNumber(_tip).shiftedBy(ERC20_DECIMALS).toString();
    try {
      await contract.methods
        .addArt(_image, _description, tip,)
        .send({ from: address });
      getArts();
    } catch (error) {
      alert(error);
    }
  };

  
  
/*************************** Modify Art Tip **********************************************************/

  const modifyTip = async (_index, _tip) => { 
    const tip = new BigNumber(_tip).shiftedBy(ERC20_DECIMALS).toString();
    try {
      await contract.methods.modifyTip(_index, tip).send({ from: address });
      getArts();
      alert("you have successfully changed the tip");
     
    } catch (error) {
      alert(error);
    }};

  
/*************************** Buy Art **********************************************************/


  const tipArtist = async (_index) => {
    try {
      const cUSDContract = new kit.web3.eth.Contract(IERC, cUSDContractAddress);
      const cost = arts[_index].tip;
      await cUSDContract.methods
        .approve(contractAddress, cost)
        .send({ from: address });
      await contract.methods.tipArtist(_index).send({ from: address });
      getArts();
      getBalance();
      alert("you have successfully tip this artist");
    } catch (error) {
      alert(error);
    }};


  useEffect(() => {
    connectToWallet();
  }, []);

  useEffect(() => {
    if (kit && address) {
      getBalance();
    }
  }, [kit, address, getBalance]);

  useEffect(() => {
    if (contract) {
      getArts();
    }
  }, [contract, getArts]);
  
  return (
    <div className="App">
      <NavigationBar cUSDBalance={cUSDBalance} />
      <h1>Our Arts Gallery</h1>
      <Arts arts={arts}
       tipArtist={tipArtist}
       walletAddress={address} 
       modifyTip={modifyTip} />
    
      <AddArt addArt={addArt} />
    </div>
  );
}

export default App;