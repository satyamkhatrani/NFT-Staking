const { expect } = require("chai");
const { ethers, network } = require("hardhat");

describe("NFT-Staking Contract", function () {
  it("Should be stake & unstake NFT", async function () {

    const accounts = await ethers.getSigners();
    
    // deploy BTCToken
    const BTC = await ethers.getContractFactory("BTCToken");
    const btcToken = await BTC.deploy();
    await btcToken.deployed();

    // deploy NFT(ERC1155)
    const NFT = await ethers.getContractFactory("BitcoinERC1155");
    const nftToken = await NFT.deploy();
    await nftToken.deployed();

    // mint token from account[1] & account[2]
    await nftToken.connect(accounts[1]).mint(0x00);
    await nftToken.connect(accounts[2]).mint(0x01);

    // deploy Staking Contract
    const stakingContract = await ethers.getContractFactory("Staking");
    const Staking = await stakingContract.deploy(btcToken.address, nftToken.address);
    await Staking.deployed();
    
    // transfer token to Staking Contract
    await btcToken.transfer(Staking.address, 10000000000);

    expect(await btcToken.balanceOf(Staking.address)).to.equal(10000000000);

    await nftToken.connect(accounts[1]).setApprovalForAll(Staking.address, true);
    await nftToken.connect(accounts[2]).setApprovalForAll(Staking.address, true);

    // stake NFT
    await Staking.connect(accounts[1]).stake(1, 500, 0);
    await Staking.connect(accounts[2]).stake(2, 800, 0);

    let stakes_1 = await Staking.Stakes(accounts[1].address);
    expect(stakes_1.tokenId).to.equal(1);
    expect(stakes_1.price).to.equal(500);
    let stakes_2 = await Staking.Stakes(accounts[2].address);
    expect(stakes_2.tokenId).to.equal(2);
    expect(stakes_2.price).to.equal(800);

    let closeTime = 4 * 7 * 24 * 60 * 60;  // 4 weeks

    await network.provider.send('evm_increaseTime', [closeTime]);
    await network.provider.send('evm_mine');

    await nftToken.setApprovalForAll(Staking.address, true);

    // unstake NFT
    await Staking.connect(accounts[1]).unstake();
    await Staking.connect(accounts[2]).unstake();

    let reward_1 = await btcToken.balanceOf(accounts[1].address);
    expect(reward_1).to.equal(25);
    let reward_2 = await btcToken.balanceOf(accounts[2].address);
    expect(reward_2).to.equal(40);
  });
});
