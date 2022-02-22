// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BTCToken is ERC20 {
    constructor() ERC20("Bitcoin", "BTC") {
        _mint(msg.sender, 10000000 * 10**18);
    }
}
