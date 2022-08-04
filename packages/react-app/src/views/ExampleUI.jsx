import { Button, Card, DatePicker, Divider, Input, Progress, Slider, Spin, Switch } from "antd";
import React, { useState } from "react";
import { utils } from "ethers";
import { SyncOutlined } from "@ant-design/icons";

import { CreateLock, UnlockVariables } from "../components";

export default function ExampleUI({
  address,
  price,
  publicLock,
  unlock,
  targetNetwork
}) {
  const [newPurpose, setNewPurpose] = useState("loading...");

  return (
    <div>
      {/*
        ⚙️ Here is an example UI that displays and sets the purpose in your smart contract:
      */}
      <div style={{ border: "1px solid #cccccc", padding: 16, width: 400, margin: "auto", marginTop: 64 }}>
        <h2>Settings UI:</h2>
        <Divider />
        <UnlockVariables
          targetNetwork={targetNetwork}
        />
        <Divider />
        <div style={{ margin: 8 }}>
          <CreateLock
            price={price}
            unlock={unlock}
          />
        </div>
        <Divider />
      </div>
    </div>
  );
}
