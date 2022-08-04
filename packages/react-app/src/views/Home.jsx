import React from "react";
import { useContractReader } from "eth-hooks";
// import { ethers } from "ethers";
// import { Link } from "react-router-dom";
import { Image } from 'antd';

/**
 * web3 props can be passed from '../App.jsx' into your local view component for use
 * @param {*} yourLocalBalance balance on current network
 * @param {*} readContracts contracts from current chain already pre-loaded using ethers contract module. More here https://docs.ethers.io/v5/api/contract/contract/
 * @returns react component
 **/
function Home({ yourLocalBalance, readContracts }) {
  // you can also use hooks locally in your component of choice
  // in this case, let's keep track of 'purpose' variable from our contract
  const purpose = useContractReader(readContracts, "YourContract", "purpose");

  return (
    <div>
      <div style={{ marginBottom: 50 }}>
        <h1 style={{ marginBottom: 10, marginTop: 20 }}>Welcome to 10 PointPunters</h1>
        <h2 style={{ marginBottom: 20 }}>Your one stop shop for professional sports betting tips, news and analysis.</h2>
        {/* <img src={"../../public/logo192.png"} alt="Sports and money" /> */}
        <Image width={500}  src="https://bafybeic5qstvmea6e7mm6ubzgwmo6ubu72ueyokmeuldr5i7c6sdvxew2y.ipfs.nftstorage.link/10pointp-cover.png" />
        <h2 style={{ marginTop: 15 }}>Head to the dashboard to see some of our upcoming releases 😉</h2>
        <p style={{  marginBottom: 50, maxWidth: 700, display: "inline-flex", alignSelf: "center"}}>
          Lorem ipsum dolor sit amet consectetur, adipisicing elit. Magnam officiis
          aliquam rem illo iure aliquid, pariatur iusto provident eligendi ducimus
          consequuntur, dicta fugit ut laudantium quisquam, aperiam incidunt. Deleniti, odio?
        </p>
      </div>
    </div>
  );
}

export default Home;
