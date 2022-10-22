// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/******************************************************************************\
* Author: hypervisor <chitch@alxi.nl> (https://twitter.com/0xalxi)
* EIP-5050 Token Interaction Standard: https://eips.ethereum.org/EIPS/eip-5050
*
* Implementation of an interactive token protocol.
/******************************************************************************/
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import "./interfaces/IActionsNFTState.sol";
import {Object, IERC5050Sender, IERC5050Receiver, Action} from "./interfaces/IERC5050.sol";
import "./libraries/ActionsSet.sol";
import "base64-sol/base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// import {ERC5050ProxyRegistry} from "./ERC5050ProxyRegistry.sol";

abstract contract ActionCollectibleContract {
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        returns (string memory);

    function renderTokenById(uint256 id)
        external
        view
        virtual
        returns (string memory);
}

contract ActionCollectibleState is IERC5050Receiver, IActionsNFTState, Ownable {
    using Address for address;
    using ActionsSet for ActionsSet.Set;

    ActionsSet.Set private _receivableActions;
    using Address for address;
    ActionCollectibleContract actionLoogies;
    mapping(address => mapping(uint256 => TokenStats)) stats;
    mapping(address => mapping(uint256 => string)) chillState;

    bytes4 public constant SLAP_SELECTOR = bytes4(keccak256("slap"));
    bytes4 public constant CAST_SELECTOR = bytes4(keccak256("cast"));

    uint256 constant deadLoogie = 0;
    uint256 constant slappedLoogie = 718;
    uint256 constant lustLoogie = 696969;
    uint256 constant rageLoogie = 100000;
    uint256 constant winningLoogie = 777;

    constructor(ActionCollectibleContract _actionLoogies) {
        _registerReceivable("slap");
        actionLoogies = _actionLoogies;
    }

    modifier onlyReceivableAction(Action calldata action, uint256 nonce) {
        require(
            _receivableActions.contains(action.selector),
            "ERC5050State: invalid action"
        );
        require(action.state == address(this), "ERC5050State: invalid state");
        require(
            action.user == address(0) || action.user == tx.origin,
            "ERC5050State: invalid user"
        );

        // State contracts must validate the action with the `from` contract in
        // the case of a 3-contract chain (`from`, `to` and `state`) all set to
        // valid contract addresses.
        if (
            action.to._address.isContract() && action.from._address.isContract()
        ) {
            bytes32 actionHash = bytes32(
                keccak256(
                    abi.encodePacked(
                        action.selector,
                        action.user,
                        action.from._address,
                        action.from._tokenId,
                        action.to._address,
                        action.to._tokenId,
                        action.state,
                        action.data,
                        nonce
                    )
                )
            );
            try
                IERC5050Sender(action.from._address).isValid(actionHash, nonce)
            returns (bool ok) {
                require(ok, "ERC5050State: action not validated");
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC5050State: call to non ERC5050Sender");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
        _;
    }

    function getTokenStats(address _contract, uint256 tokenId)
        external
        view
        returns (TokenStats memory)
    {
        return stats[_contract][tokenId];
    }

    function registerToken(address _contract, uint256 tokenId) external {
        string memory _chillState;
        require(
            stats[_contract][tokenId].strength == 0,
            "State: already registered"
        );
        stats[_contract][tokenId] = TokenStats(
            (_random(_contract, tokenId) % 20) + 4,
            TokenSlapState.DEFAULT,
            TokenCastState.CHILL
        );
        _chillState = actionLoogies.tokenURI(tokenId);
        chillState[_contract][tokenId] = _chillState;
    }

    function getStrength(address _contract, uint256 tokenId)
        external
        view
        returns (uint256)
    {
        return stats[_contract][tokenId].strength;
    }

    function getState(address _contract, uint256 tokenId)
        external
        view
        returns (TokenSlapState)
    {
        return stats[_contract][tokenId].state;
    }

    // function tokenURI(uint256 id, Action action)
    //     public
    //     view
    //     override
    //     returns (string memory)
    // {
    //     string memory name = string(
    //         abi.encodePacked("Loogie #", action.to._tokenId.toString())
    //     );
    //     //   string memory description = string(abi.encodePacked('This Loogie is the color #',color[id].toColor(),' with a chubbiness of ',chubbiness[id].toString(),'!!!'));
    //     string memory image = Base64.encode(
    //         bytes(actionLoogies.generateSVGofTokenById(id))
    //     );

    //     return
    //         string(
    //             abi.encodePacked(
    //                 "data:application/json;base64,",
    //                 Base64.encode(
    //                     bytes(
    //                         abi.encodePacked(
    //                             '{"name":"',
    //                             name,
    //                             //   '", "description":"',
    //                             //   description,
    //                             '", "external_url":"https://burnyboys.com/token/',
    //                             id.toString(),
    //                             '", "attributes": [{"trait_type": "color", "value": "#',
    //                             lustLoogie.toColor(),
    //                             '"},{"trait_type": "chubbiness", "value": ',
    //                             lustLoogie.toString(),
    //                             '}], "owner":"',
    //                             (uint160(ownerOf(action.to._tokenId)))
    //                                 .toHexString(20),
    //                             '", "image": "',
    //                             "data:image/svg+xml;base64,",
    //                             image,
    //                             '"}'
    //                         )
    //                     )
    //                 )
    //             )
    //         );
    // }

    function onActionReceived(Action calldata action, uint256 _nonce)
        external
        payable
        override
        onlyReceivableAction(action, _nonce)
    {
        require(
            action.from._address.isContract() &&
                action.to._address.isContract(),
            "State: invalid to and from"
        );
        // EFFECT OF ACTION HAPPENS HERE
        // check type of action
        // call appropriate action handler
        // handle changes token stats
        // stats change tokenURI

        TokenStats memory fromStats = _getTokenStats(action.from);
        TokenStats memory toStats = _getTokenStats(action.to);
        require(
            fromStats.strength > 0 && toStats.strength > 0,
            "0 strength token"
        );

        uint256 val = (_random(action.from._address, action.from._tokenId) %
            (fromStats.strength + toStats.strength)) + 1;

        // Relative strength determines likelihood of a win.
        if (val == fromStats.strength) {
            // tie
            stats[action.from._address][action.from._tokenId]
                .state = TokenSlapState.DEFAULT;
            stats[action.to._address][action.to._tokenId].state = TokenSlapState
                .DEFAULT;
        } else if (val < fromStats.strength) {
            // sender wins!
            uint256 delta = fromStats.strength - val;
            fromStats.strength += delta;
            fromStats.state = TokenSlapState.WINNER;
            _setTokenStats(action.from, fromStats);
            if (delta >= toStats.strength) {
                toStats.strength = 0;
                toStats.state = TokenSlapState.DEAD;
            } else {
                toStats.strength -= delta;
                toStats.state = TokenSlapState.SLAPPED;
            }
            _setTokenStats(action.to, toStats);
        } else {
            // receiver wins!
            uint256 delta = val - fromStats.strength;
            toStats.strength += delta;
            toStats.state = TokenSlapState.WINNER;
            _setTokenStats(action.to, toStats);

            if (delta >= toStats.strength) {
                fromStats.strength = 0;
                fromStats.state = TokenSlapState.DEAD;
            } else {
                fromStats.strength -= delta;
                fromStats.state = TokenSlapState.SLAPPED;
            }
            _setTokenStats(action.from, fromStats);
        }
    }

    function _getTokenStats(Object memory obj)
        internal
        view
        returns (TokenStats memory)
    {
        return stats[obj._address][obj._tokenId];
    }

    function _setTokenStats(Object memory obj, TokenStats memory _stats)
        internal
    {
        stats[obj._address][obj._tokenId] = _stats;
    }

    function _random(address _contract, uint256 tokenId)
        internal
        view
        returns (uint256)
    {
        return
            uint256(
                keccak256(abi.encodePacked(block.coinbase, _contract, tokenId))
            );
    }

    // function setProxyRegistry(address registry) external virtual onlyOwner {
    //     _setProxyRegistry(registry);
    // }

    function receivableActions() external view returns (string[] memory) {
        return _receivableActions.names();
    }

    function _registerReceivable(string memory action) internal {
        _receivableActions.add(action);
    }
}
