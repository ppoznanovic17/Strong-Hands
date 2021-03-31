const { expect } = require("chai");

describe("Strong Hands ", function() {
    let StrongHands, strongHands, owner, addr1, addr2, addr3;
    beforeEach( async () => {
        StrongHands = await ethers.getContractFactory("StrongHands");
        strongHands = await StrongHands.deploy();
        await strongHands.deployed();
        [owner, addr1, addr2, addr3] = await ethers.getSigners();
    })

    it("Should deploye well", async function() {
        expect(await strongHands.getName()).to.equal("Strong Hands");
        expect(await strongHands.getOwner()).to.equal(owner.address);
    });


});