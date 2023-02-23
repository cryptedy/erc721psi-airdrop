const {
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Mock Test", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployNFTFixture() {
    // Contracts are deployed using the first signer/account by default
    const [admin, ...users] = await ethers.getSigners();
    const NFTFactory = await ethers.getContractFactory("Mock");
    const NFT = await NFTFactory.deploy();

    return { NFT, admin, users};
  }

  describe("Easy test", function(){
    // Contents that loaded by fixture
    let bundle = {};
    let NFT, admin, users;
    let al = [];
    let holder = []
    const AMOUNT = 1500;
    // Load fixture for this test section
    before(async () => {
      bundle = await loadFixture(deployNFTFixture);
      NFT = bundle.NFT;
      admin = bundle.admin;
      users = bundle.users;
      // ホルダーリストとして100アドレスを作成
      for (let i = 0; i < 10; i++){
        holder.push(users[i].address);
      }
      for (let i = 0; i < 90; i++){
        holder.push((ethers.Wallet.createRandom(["1234"])).address);
      }
      // AirdropListを作成
      for (let i = 0; i < AMOUNT; i++){
        al.push(holder[getRandomInt(100)]);
      }
    });
    it("check airdrop amount", async function() {
      expect(await NFT.AIRDROP_AMOUNT()).to.be.equal(1500);
    })
    it(`append random ${AMOUNT} addresses`, async function () {
      console.log(al.length)
      const res = await NFT.encode(al);
      console.log(res.gas)
      let tx = await NFT.appendAirdropAddresses(al, {gasLimit: 25000000});
      tx = await tx.wait();
      console.log(tx.gasUsed);
      for (let i = 0; i < AMOUNT; i++){
        if (i % 100 == 0) console.log(i)
        expect(await NFT.getAirdropAddress(i)).to.be.equal(al[i]);
      }
    });
    it(`airdrop`, async function(){
      await expect(NFT.airdrop()).not.reverted;
      console.log(await NFT.totalSupply());
      for (let i = 0; i < AMOUNT; i++){
        if (i % 100 == 0) console.log(i)
        expect(await NFT.ownerOf(i)).to.be.equal(al[i]);
      }

    })

  })
});

function getRandomInt(max) {
  return Math.floor(Math.random() * max);
}

