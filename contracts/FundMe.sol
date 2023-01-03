// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    // converted to eth
    // uint256 public minUsd = 50 * 1e18;

    // constant keyword helps to save gas expense
    uint256 public constant MIN_USD = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    // address public owner;
    address public immutable i_owner;

    AggregatorV3Interface priceFeed;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    /* 
    receive and fallback are used to direct the user back to the original fund function
    
    if by mistake they have taken wrong path to send ether.
    receive() external payable {
         fund();
    }

    fallback() external payable {
        fund();
    }
    
    */
    modifier onlyOwner() {
        require(msg.sender == i_owner, "Sender is not owner!");
        _;
    }

    // payable gives us the red button.
    function fund() public payable {
        // msg.value is in wei. 1e18 means 1 eth or 1e18 wei
        require(
            // Here we are using getConversionRate from the library PriceConverter so msg.value is treated as first parameter in the function.
            msg.value.getConversionRate(priceFeed) > MIN_USD,
            "Didn't send enough"
        );

        // msg.sender will be the address of the address which will be calling the fund function.
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    // onlyOwner modifier used.
    function withdraw() public onlyOwner {
        // require(msg.sender == owner, "Sender is not owner!");
        // Instead of the above condition we used the modifier.

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);

        // msg.sender = address
        // payable(msg.sender) = payable address

        // transfer
        payable(msg.sender).transfer(address(this).balance);

        // send
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Send Failed");

        // call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return priceFeed;
    }

    function getFunder(uint256 index) public view returns (address) {
        return funders[index];
    }
}
