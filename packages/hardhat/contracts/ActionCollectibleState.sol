// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/******************************************************************************\
* Author: hypervisor <chitch@alxi.nl> (https://twitter.com/0xalxi)
* EIP-5050 Token Interaction Standard: https://eips.ethereum.org/EIPS/eip-5050
*
* Implementation of an interactive token protocol State Contract.
/******************************************************************************/

/******************************************
 * TODO
 * Check that token exists on source contract during token registration
 * If token does not survive slap set token properties and URI to dead token
 * ************************************/

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import "./interfaces/IActionsNFTState.sol";
import {Object, IERC5050Sender, IERC5050Receiver, Action} from "./interfaces/IERC5050.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/ActionsSet.sol";
import "base64-sol/base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ToColor.sol";

// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// import {ERC5050ProxyRegistry} from "./ERC5050ProxyRegistry.sol";

abstract contract ActionCollectibleContract {
    function ownerOf(uint256 tokenId)
        external
        view
        virtual
        returns (address owner);
}

contract ActionCollectibleState is IERC5050Receiver, IActionsNFTState, Ownable {
    using Address for address;
    using Strings for uint256;
    using Strings for uint160;
    using ActionsSet for ActionsSet.Set;
    using ToColor for bytes3;

    ActionsSet.Set private _receivableActions;
    ActionCollectibleContract actionLoogies;
    mapping(address => mapping(uint256 => TokenStats)) stats;
    mapping(uint256 => string) public color;
    mapping(uint256 => uint256) public chubbiness;
    mapping(uint256 => string) actionURI;
    mapping(uint256 => uint256) lastActionBlock;

    bytes4 constant CAST_SELECTOR = bytes4(keccak256("cast"));
    // Receivable actions
    bytes4 constant SLAP_SELECTOR = bytes4(keccak256("slap"));
    bytes4 constant CAST_IMMUNE_SELECTOR = bytes4(keccak256("immune"));
    bytes4 constant CAST_LUST_SELECTOR = bytes4(keccak256("lust"));
    bytes4 constant CAST_RAGE_SELECTOR = bytes4(keccak256("rage"));

    ActionProperty actionProperties =
        ActionProperty(
            Property({actionId: 7474, color: "75010f"}),
            Property({actionId: 6969, color: "0f33a0"}),
            Property({actionId: 9999, color: "f5070b"}),
            Property({actionId: 0, color: "fffff"})
        );

    constructor(ActionCollectibleContract _actionLoogies) {
        _registerReceivable("slap");
        _registerReceivable("immune");
        _registerReceivable("rage");
        _registerReceivable("lust");
        actionLoogies = _actionLoogies;
    }

    modifier onlyReceivableAction(Action calldata action, uint256 nonce) {
        require(
            _receivableActions.contains(action.selector) ||
                _receivableActions.contains(action.data),
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

    function getActionStateURI(uint _tokenId)
        external
        view
        returns (string memory uri)
    {
        if (block.number - lastActionBlock[_tokenId] <= 10000) {
            uri = actionURI[_tokenId];
        } else {
            if (
                stats[address(actionLoogies)][_tokenId].state !=
                TokenSlapState.DEAD
            ) {
                return uri = "";
            }
            uri = actionURI[_tokenId];
        }
    }

    function registerToken(address _contract, uint256 tokenId) external {
        require(
            stats[_contract][tokenId].strength == 0,
            "State: already registered"
        );
        stats[_contract][tokenId] = TokenStats(
            (_random(_contract, tokenId) % 20) + 4,
            TokenSlapState.DEFAULT,
            TokenCastState.CHILL
        );
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

    function renderTokenById(uint256 id) public view returns (string memory) {
        string memory render = string(
            abi.encodePacked(
                '<g id="eye1">',
                '<ellipse stroke-width="3" ry="29.5" rx="29.5" id="svg_1" cy="154.5" cx="181.5" stroke="#000" fill="#fff"/>',
                '<ellipse ry="3.5" rx="2.5" id="svg_3" cy="154.5" cx="173.5" stroke-width="3" stroke="#000" fill="#000000"/>',
                "</g>",
                '<g id="head">',
                '<ellipse fill="#',
                color[id],
                '" stroke-width="3" cx="204.5" cy="211.80065" id="svg_5" rx="',
                chubbiness[id].toString(),
                '" ry="51.80065" stroke="#000"/>',
                "</g>",
                '<g id="eye2">',
                '<ellipse stroke-width="3" ry="29.5" rx="29.5" id="svg_2" cy="168.5" cx="209.5" stroke="#000" fill="#fff"/>',
                '<ellipse ry="3.5" rx="3" id="svg_4" cy="169.5" cx="208" stroke-width="3" fill="#000000" stroke="#000"/>',
                "</g>"
            )
        );

        return render;
    }

    function _generateSVGofTokenById(uint256 id)
        internal
        view
        returns (string memory)
    {
        string memory svg = string(
            abi.encodePacked(
                '<svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">',
                renderTokenById(id),
                "</svg>"
            )
        );

        return svg;
    }

    function tokenURI(uint256 id, Action calldata action)
        internal
        view
        returns (string memory)
    {
        string memory name = string(
            abi.encodePacked("Loogie #", action.to._tokenId.toString())
        );
        string memory description = string(
            abi.encodePacked("Loogies in action...")
        );
        string memory image = Base64.encode(bytes(_generateSVGofTokenById(id)));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name,
                                '", "description":"',
                                description,
                                '", "external_url":"https://burnyboys.com/token/',
                                id.toString(),
                                '", "attributes": [{"trait_type": "color", "value": "#',
                                color[id],
                                '"},{"trait_type": "chubbiness", "value": ',
                                chubbiness[id].toString(),
                                '}], "owner":"',
                                (
                                    uint160(
                                        actionLoogies.ownerOf(
                                            action.to._tokenId
                                        )
                                    )
                                ).toHexString(20),
                                '", "image": "',
                                "data:image/svg+xml;base64,",
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function onActionReceived(Action calldata _action, uint256 _nonce)
        external
        payable
        override
        onlyReceivableAction(_action, _nonce)
    {
        require(
            _action.from._address.isContract() &&
                _action.to._address.isContract(),
            "State: invalid to and from"
        );
        // call appropriate action handler
        if (_action.selector == CAST_SELECTOR) {
            _onCastReceived(_action);
        } else {
            _onSlapReceived(_action);
        }
    }

    function _setTokenProperties(
        uint256 _tokenId,
        uint256 _actionId,
        string memory _color
    ) internal {
        bytes32 predictableRandom = keccak256(
            abi.encodePacked(
                blockhash(block.number - 1),
                msg.sender,
                address(this),
                _actionId
            )
        );
        color[_tokenId] = _color;
        chubbiness[_tokenId] =
            35 +
            ((55 * uint256(uint8(predictableRandom[3]))) / 255);
    }

    function _setEnchantedTokenProperties(
        uint256 _toTokenId,
        bytes4 _actionSelector
    ) internal {
        uint256 _actionId;
        string memory _color;
        if (_actionSelector == CAST_RAGE_SELECTOR) {
            _actionId = actionProperties.rageLoogie.actionId;
            _color = actionProperties.rageLoogie.color;
        }
        if (_actionSelector == CAST_LUST_SELECTOR) {
            _actionId = actionProperties.lustLoogie.actionId;
            _color = actionProperties.lustLoogie.color;
        }
        _setTokenProperties(_toTokenId, _actionId, _color);
    }

    function _setSlappedTokenProperties(uint256 _tokenId) internal {
        uint256 _actionId;
        string memory _color;
        _actionId = actionProperties.slappedLoogie.actionId;
        _color = actionProperties.slappedLoogie.color;
        _setTokenProperties(_tokenId, _actionId, _color);
    }

    function _onCastReceived(Action calldata _action) internal {
        bytes4 castSelector = _action.data;
        if (castSelector == 0x00000000) {
            castSelector = CAST_RAGE_SELECTOR;
        }

        TokenStats memory fromStats = _getTokenStats(_action.from);
        TokenStats memory toStats = _getTokenStats(_action.to);
        require(
            fromStats.strength > 0 && toStats.strength > 0,
            "'from/to' 0 strength token"
        );
        require(toStats.vibes != TokenCastState.IMMUNE, "Immune token");

        if (castSelector == CAST_IMMUNE_SELECTOR) {
            require(fromStats.strength > 10, "Not enough strength, < 10");
            toStats.vibes = TokenCastState.IMMUNE;
            fromStats.strength =
                fromStats.strength +
                (fromStats.strength % toStats.strength);
            actionURI[_action.to._tokenId] = "";
        } else {
            _setEnchantedTokenProperties(_action.to._tokenId, castSelector);
            fromStats.strength =
                fromStats.strength -
                (fromStats.strength % toStats.strength);
            if (castSelector == CAST_LUST_SELECTOR) {
                // set 'to' token to lust vibes
                toStats.vibes = TokenCastState.LUST;
            }
            if (castSelector == CAST_RAGE_SELECTOR) {
                // set 'to' token to rage vibes
                toStats.vibes = TokenCastState.RAGE;
            }
            // change token URI
            string memory uri = tokenURI(_action.to._tokenId, _action);
            actionURI[_action.to._tokenId] = uri;
        }
    }

    function _onSlapReceived(Action calldata action) internal {
        TokenStats memory fromStats = _getTokenStats(action.from);
        TokenStats memory toStats = _getTokenStats(action.to);
        require(
            fromStats.strength > 0 && toStats.strength > 0,
            "0 strength token"
        );
        require(toStats.vibes != TokenCastState.IMMUNE, "Immune token");

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
            //set 'from' token state to winner
            fromStats.state = TokenSlapState.WINNER;
            // update 'from' token stats
            _setTokenStats(action.from, fromStats);
            // check to see if 'to' token survives slap
            if (delta >= toStats.strength) {
                toStats.strength = 0;
                toStats.state = TokenSlapState.DEAD;
            } else {
                toStats.strength -= delta;
                toStats.state = TokenSlapState.SLAPPED;
            }
            _setTokenStats(action.to, toStats);
            _setSlappedTokenProperties(action.to._tokenId);
            string memory uri = tokenURI(action.to._tokenId, action);
            actionURI[action.to._tokenId] = uri;
        } else {
            // receiver wins!
            uint256 delta = val - fromStats.strength;
            toStats.strength += delta;
            toStats.state = TokenSlapState.WINNER;
            _setTokenStats(action.to, toStats);

            if (delta >= fromStats.strength) {
                fromStats.strength = 0;
                fromStats.state = TokenSlapState.DEAD;
            } else {
                fromStats.strength -= delta;
                fromStats.state = TokenSlapState.SLAPPED;
            }
            _setTokenStats(action.from, fromStats);
            _setSlappedTokenProperties(action.from._tokenId);
            string memory uri = tokenURI(action.from._tokenId, action);
            actionURI[action.from._tokenId] = uri;
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

    function receivableActions() external view returns (string[] memory) {
        return _receivableActions.names();
    }

    function _registerReceivable(string memory action) internal {
        _receivableActions.add(action);
    }
}
