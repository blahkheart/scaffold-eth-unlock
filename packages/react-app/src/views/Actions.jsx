import { Button, Radio, Input, Select, List, Card } from "antd";
import React, { useState, useEffect } from "react";
import { Address, AddressInput } from "../components";
import { useContractReader } from "eth-hooks";
const ethers = require("ethers");
const { Option } = Select;
function Actions({ readContracts, writeContracts, tx, address }) {
  const [receivableActions, setReceivableActions] = useState([]);
  const [sendableActions, setSendableActions] = useState([]);
  const [contractData, setContractData] = useState({});
  const [selectedAction, setSelectedAction] = useState();
  const [fromTokenId, setFromTokenId] = useState();
  const [toTokenId, setToTokenId] = useState();
  const [actionCollectibles, setActionCollectibles] = useState();
  const [castType, setCastType] = useState();
  const [balance, setBalance] = useState();

  const balanceContract = useContractReader(readContracts, "ActionCollectible", "balanceOf", [address]);

  useEffect(() => {
    if (balanceContract) {
      setBalance(balanceContract);
    }
  }, [balanceContract]);

  useEffect(() => {
    let stateContractAddress, loogieContractAddress, castActionSelector, slapActionSelector, data;
    const readyContractData = async () => {
      try {
        stateContractAddress = await readContracts.ActionCollectibleState.address;
        loogieContractAddress = await readContracts.ActionCollectible.address;
        castActionSelector = await readContracts.ActionCollectible.CAST_SELECTOR();
        slapActionSelector = await readContracts.ActionCollectible.SLAP_SELECTOR();
        data = {
          stateContract: stateContractAddress,
          fromContract: loogieContractAddress,
          toContract: loogieContractAddress,
          castSelector: castActionSelector,
          slapSelector: slapActionSelector,
        };
        setContractData(data);
      } catch (e) {
        console.log(e);
      }
    };
    readyContractData();
  }, [readContracts]);

  useEffect(() => {
    const _actions = [];
    const readyReceivableActions = async () => {
      try {
        const contractReceivableActions = await readContracts.ActionCollectible.receivableActions();
        let myArr = [...contractReceivableActions];
        if (myArr && myArr.length) {
          for (let i = 0; i < myArr.length; i++) {
            _actions.push({ name: myArr[i], selector: ethers.utils.id(myArr[i]).substring(0, 10) });
          }
        }
      } catch (e) {
        console.log(e);
      }
    };
    readyReceivableActions();
    setReceivableActions(_actions);
  }, [readContracts]);

  useEffect(() => {
    const _actions = [];
    const readySendableActions = async () => {
      try {
        const contractSendableActions = await readContracts.ActionCollectible.sendableActions();
        let myArr = [...contractSendableActions];
        if (myArr && myArr.length) {
          for (let i = 0; i < myArr.length; i++) {
            _actions.push({ name: myArr[i], selector: ethers.utils.id(myArr[i]).substring(0, 10) });
          }
        }
      } catch (e) {
        console.log(e);
      }
    };
    readySendableActions();
    setSendableActions(_actions);
  }, [readContracts]);

  useEffect(() => {
    const updateActionCollectibles = async () => {
      const collectibleUpdate = [];
      for (let tokenIndex = 0; tokenIndex < balance; ++tokenIndex) {
        try {
          console.log("Getting token index " + tokenIndex);
          const tokenId = await readContracts.ActionCollectible.tokenOfOwnerByIndex(address, tokenIndex);
          console.log("tokenId: " + tokenId);
          const tokenURI = await readContracts.ActionCollectible.tokenURI(tokenId);
          const jsonManifestString = Buffer.from(tokenURI.substring(29), "base64").toString();
          console.log("jsonManifestString: " + jsonManifestString);

          try {
            const jsonManifest = JSON.parse(jsonManifestString);
            console.log("jsonManifest: " + jsonManifest);
            collectibleUpdate.push({ id: tokenId, uri: tokenURI, owner: address, ...jsonManifest });
          } catch (err) {
            console.log(err);
          }
        } catch (err) {
          console.log(err);
        }
      }
      setActionCollectibles(collectibleUpdate.reverse());
    };
    if (address && balance) updateActionCollectibles();
  }, [address, balance]);

  const handleActionSelect = e => {
    setSelectedAction(e);
  };

  const handleCastSelect = e => {
    const value = e.target.value;
    setCastType(value);
  };
  const capitalizeString = string => {
    return string.charAt(0).toUpperCase() + string.slice(1);
  };
  return (
    <div>
      <div style={{ maxWidth: 820, margin: "auto", marginTop: 32, paddingBottom: 32 }}>
        Lorem ipsum dolor sit amet, consectetur adipisicing elit. Exercitationem totam quidem quibusdam atque libero
        voluptates beatae vitae recusandae alias cupiditate. Expedita ad officiis odio est omnis itaque ex molestias
        fuga.
      </div>

      <div style={{ width: 820, margin: "auto", paddingBottom: 256 }}>
        <List
          bordered
          dataSource={actionCollectibles}
          renderItem={item => {
            const id = item.id.toNumber();

            console.log("IMAGE", item.image);

            return (
              <List.Item key={id + "_" + item.uri + "_" + item.owner}>
                <Card
                  title={
                    <div>
                      <span style={{ fontSize: 18, marginRight: 8 }}>{item.name}</span>
                    </div>
                  }
                >
                  {/* <a
                    href={
                      "https://opensea.io/assets/" +
                      (readContracts && readContracts.ActionCollectible && readContracts.ActionCollectible.address) +
                      "/" +
                      item.id
                    }
                    target="_blank"
                    rel="noreferrer"
                  > */}
                  <img src={item.image} />
                  {/* </a> */}
                  <div>{item.description}</div>
                </Card>
                <div className="action-controls" style={{ width: "100%", padding: 15 }}>
                  {sendableActions.length && receivableActions.length ? (
                    <div style={{ textAlign: "left" }}>
                      <h3 style={{ textAlign: "center" }}>Send Action</h3>
                      <div className="actions-form-group">
                        <span>Choose action: </span>
                        <Select
                          defaultValue={sendableActions[0].name}
                          style={{
                            width: 180,
                            textAlign: "left",
                          }}
                          onChange={handleActionSelect}
                        >
                          {sendableActions.map(item => (
                            <Option value={item.selector}>{capitalizeString(item.name)}</Option>
                          ))}
                        </Select>
                      </div>
                      {selectedAction && selectedAction === ethers.utils.id("cast").substring(0, 10) ? (
                        <div className="actions-form-group">
                          <Radio.Group onChange={handleCastSelect} value={castType}>
                            {receivableActions.map(item =>
                              item.name !== "slap" ? (
                                <Radio value={item.selector}>{capitalizeString(item.name)}</Radio>
                              ) : (
                                ""
                              ),
                            )}
                          </Radio.Group>
                        </div>
                      ) : null}

                      <div className="actions-form-group">
                        <span>From tokenID: </span>
                        <Input name="fromToken" disabled type="number" value={id} placeholder="Token ID" />
                      </div>
                      <div className="actions-form-group">
                        <span>To tokenID: </span>
                        <Input
                          name="fromToken"
                          type="number"
                          value={toTokenId}
                          onChange={e => {
                            const _tokenId = e.target.value;
                            setToTokenId(_tokenId);
                            setFromTokenId(id);
                          }}
                          placeholder="Token ID"
                        />
                      </div>
                      <div>
                        <Button
                          onClick={() => {
                            const sendAction = async () => {
                              try {
                                const sendParams = [
                                  selectedAction,
                                  address,
                                  [contractData.fromContract, fromTokenId],
                                  [contractData.toContract, toTokenId],
                                  contractData.stateContract,
                                  castType ? castType : selectedAction,
                                ];
                                console.log("send params", sendParams)
                                // const sendParams = []
                                const sendAction = tx(await writeContracts.ActionCollectible.sendAction(sendParams));
                                console.log("send action txn ", sendAction.hash);
                              } catch (e) {
                                console.log(e);
                              }
                            }
                            sendAction()
                          }}
                          type="primary"
                        >
                          Send action
                        </Button>
                      </div>
                    </div>
                  ) : (
                    ""
                  )}
                </div>
              </List.Item>
            );
          }}
        />
      </div>
    </div>
  );
}

export default Actions;
