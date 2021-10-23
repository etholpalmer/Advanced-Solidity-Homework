pragma solidity ^0.5.0;

import "./PupperCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";

// Inherit the crowdsale contracts
contract PupperCrowdCoinSale is Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, RefundablePostDeliveryCrowdsale {

    constructor(
        uint rate,              // Rate in Token bits
        address payable wallet, // Contract beneficiary
        PupperCoin Token,        // The Token to be created.
        uint256 cap,            // total capacity in wei (1 quintillion wei = 1 ether)
        uint256 openingTime,    // Opening time in UNIX epoch seconds
        uint256 closingTime     // Closing time in UNIX epoch seconds
    )
        PupperCrowdCoinSale(rate, wallet, Token, cap, openingTime, closingTime)
        // Pass the constructor parameters to the crowdsale contracts.
        // https://docs.openzeppelin.com/contracts/2.x/crowdsales
        MintedCrowdsale()
        // calculate rate: https://docs.openzeppelin.com/contracts/2.x/crowdsales#crowdsale-rate
        Crowdsale(rate, wallet, Token)
        CappedCrowdsale(cap)
        TimedCrowdsale(openingTime, closingTime)
        RefundablePostDeliveryCrowdsale()
        public
    {
        // constructor can stay empty
    }
}

contract PupperCoinSaleDeployer {

    address public token_sale_address;
    address public token_address;

    constructor(
        string memory name,
        string memory symbol,
        address payable wallet  // The beneficiary wallet
    )
        public
    {
        // Create the PupperCoin and keep its address handy
        PupperCoin token = new PupperCoin(name, symbol, 0);
        token_address = address(token);
        

        // Create the PupperCoinSale and tell it about the token, set the goal, and set the open and close times to now and now + 24 weeks.
        PupperCrowdCoinSale coin_sale = new PupperCrowdCoinSale(1, wallet, token, 1000, now, now + 10 days);
        token_sale_address = address(coin_sale);
        
        // make the PupperCoinSale contract a minter, then have the PupperCoinSaleDeployer renounce its minter role
        token.addMinter(token_sale_address);
        token.renounceMinter();
    }
}
