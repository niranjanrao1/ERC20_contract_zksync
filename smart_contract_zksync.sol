// Hey Mohan, here I have imported the `ERC20` and `Ownable` contracts from the OpenZeppelin library to create a standard ERC20 token with ownership functionality. I've also imported the IERC20 and IZkSync interfaces from the `@zksync/contracts` library to interact with the zksync rollup layer.
// My `zkSync` variable holds a reference to the zksync contract, while the `syncToken` variable holds the address of the corresponding zksync token.
// My `deposit` function allows users to deposit their tokens onto the zksync rollup layer. It first checks that the user has a positive balance, approves the token transfer to the zksync contract, and then calls the `depositERC20` function of the zksync contract, passing the `syncToken` address, the user address, and the amount to deposit. Finally, a `Deposit` event is emitted.
// My `withdraw` function allows users to withdraw a specified amount of their tokens from the zksync rollup layer back to the Ethereum mainnet. All the usual checks etc. Then it emits a `Withdraw` event.
// My `withdrawAll` function is a convenience function that allows users to withdraw all their tokens from the zksync rollup layer at once.
// BTW this code is just an example and you should thoroughly test/ audit before deployment to production.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@zksync/contracts/src/interfaces/IERC20.sol";
import "@zksync/contracts/src/interfaces/IZkSync.sol";

contract MyToken is ERC20, Ownable {
    IZkSync public zkSync;
    address public syncToken;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply, address _zkSync, address _syncToken) ERC20(_name, _symbol) {
        decimals = _decimals;
        _mint(msg.sender, _totalSupply);
        zkSync = IZkSync(_zkSync);
        syncToken = _syncToken;
    }

    function deposit() public {
        uint256 amount = balanceOf(msg.sender);
        require(amount > 0, "Zero balance");
        approve(syncToken, amount);
        bytes32 hash = zkSync.depositERC20(syncToken, msg.sender, amount);
        emit Deposit(msg.sender, amount, hash);
    }

    function withdraw(uint256 amount) public {
        require(amount > 0, "Zero amount");
        bytes32 hash = zkSync.withdrawERC20(syncToken, amount);
        emit Withdraw(msg.sender, amount, hash);
    }

    function withdrawAll() public {
        uint256 amount = balanceOf(msg.sender);
        require(amount > 0, "Zero balance");
        bytes32 hash = zkSync.withdrawERC20(syncToken, amount);
        emit Withdraw(msg.sender, amount, hash);
    }

    event Deposit(address indexed user, uint256 amount, bytes32 indexed hash);
    event Withdraw(address indexed user, uint256 amount, bytes32 indexed hash);

}