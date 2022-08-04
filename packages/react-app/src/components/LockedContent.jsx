import { Button, Card, Col, Image , Row, Carousel } from "antd";
import React, { useState, useEffect } from "react";
// import { useHistory } from "react-router-dom";
import UnlockPaywall from "./UnlockPaywall";
// import { CreateLock, UnlockVariables } from ".";
import  {useUnlockState} from "../hooks";



/*
  ~ What it does? ~
  Displays a UI that reveals content based on whether a user is a member or not.
  ~ How can I use? ~
  <LockedContent
    address={address}
    publicLock={publicLock}
    targetNetwork={targetNetwork}
  />

  ~ Features ~
  - address={address} passes active user's address to the component to check whether they are members or not
  - publicLock={publicLock} passes the specific lock to check for the user's membership
  - targetNetwork={targetNetwork} passes the current app network to the <UnlockPaywall /> to determine the network to connect to
*/
// import eplLogo from "../img/english-premier-league-logo.jpg";
import {eplLogo, laLigaLogo, bundesLigaLogo, ligue1Logo} from "../img/index";
const contentStyle: React.CSSProperties = {
  height: '160px',
  color: '#fff',
  lineHeight: '160px',
  textAlign: 'center',
  background: '#364d79',
};

const LockedContent = ({ publicLock, price, unlock, address, targetNetwork }) => {
  const hasValidKey = useUnlockState(publicLock, address);

  const previewContent = (
    <>
      <div style={{ padding: 8, marginTop: 32, maxWidth: 592, margin: "auto" }}>
        <Card title="Preview Content">
          <h3>Crystal Palace vs Arsenal</h3>
          <div style={{ padding: 8, marginBottom: 8 }}>
            There’s optimism aplenty at Selhurst Park with Crystal Palace hoping a busy summer’s recruitment can help them build on last season’s 12th place finish in the Premier League (PL). There’s a literal building job also on the horizon with the club committed to redeveloping their ground, and fans are eager to see if manager Patrick Vieira can guide them to a first top-half finish since 2014/15.
            Coincidentally, they opened that season against Arsenal too, losing 2-1, so even another H2H...
          </div>
            <UnlockPaywall
              shape={"round"}
              size={"large"}
              displayText={"Become a member for full access"}
              targetNetwork={targetNetwork}
              publicLock={publicLock}
            />
        </Card>
      </div>
    </>
  );

  const lockedContent = (
    <>
      <div style={{ padding: 8, marginTop: 32, maxWidth: 592, margin: "auto" }}>
          <Card title="Locked Content">
            <div style={{ padding: 8, marginBottom: 15 }}>
              YOU NOW HAVE ACCESS TO THE LOCKED CONTENT
            </div>

            <Carousel autoplay>
              <div>
                <Image width={400} height={250} src={eplLogo} />
                <h3 style={{marginBottom: 15}}>English Premier League</h3>
              {/* <p>
                There’s optimism aplenty at Selhurst Park with Crystal Palace hoping a busy summer’s recruitment can help them build on last season’s 12th place finish in the Premier League (PL). There’s a literal building job also on the horizon with the club committed to redeveloping their ground, and fans are eager to see if manager Patrick Vieira can guide them to a first top-half finish since 2014/15.
                Coincidentally, they opened that season against Arsenal too, losing 2-1, so even another H2H loss isn’t necessarily a bad omen – not that ex-Gunner Vieira will see it that way! Eagles fans will obviously hope for a repeat of the 3-0 win in this corresponding fixture last term, part of an ongoing six-match unbeaten run at home in the league (W3, D3).
                Although Arsenal’s fifth-place finish last term represented progress and justified the faith shown in manager Mikel Arteta, for much of the season they seemed on course for a top-four place, so that will be the minimum target for the North Londoners this term. With that in mind, Arteta has refreshed his still-youthful squad in the summer including signing Gabriel Jesus, Fábio Vieira and Oleksandr Zinchenko.
                This London derby offers an early test of how those new players have settled following a positive pre-season including a 4-0 win over Chelsea and a 6-0 thrashing of Sevilla! Improving their away form could be key to Arsenal’s season however, particularly as they conceded a joint league-high 65% of their PL goals last term on the road.
                <br/>(src: <a href="https://www.flashscore.com/match/QZqX1icF/#/match-summary" target="_blank">flashscore.com</a>)
              </p> */}
              </div>
              
              <div>
                 <Image width={400} src={ligue1Logo} />
                <h3>League One</h3>
              </div>
              <div>
                 <Image width={400} src={laLigaLogo} />
                <h3>La Liga</h3>
              </div>
              <div>
                <Image width={400} src={bundesLigaLogo} />
                <h3>BundesLiga</h3>
              </div>
            </Carousel>
          </Card>
      </div>
    </>
  );

  return (
    <>
      <Row>
        <Col span={24}>
          { hasValidKey && hasValidKey !== false
            ? lockedContent
            : previewContent
          }
        </Col>
      </Row>
    </>
  );
};

export default LockedContent;
