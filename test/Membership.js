const { expect } = require("chai");

describe("Memberships contract ", function () {
  it("Contract should create multiple memberships and increment memberCount correctly", async function () {

    const [addr1, addr2] = await ethers.getSigners();

    const Memberships = await ethers.getContractFactory("Memberships");

    const hardhatToken = await Memberships.deploy();

    expect(await hardhatToken.connect(addr1).getMemberCount()).to.equal(0);

    await hardhatToken.connect(addr1).createMembership("sam");

    expect(await hardhatToken.connect(addr1).getMemberCount()).to.equal(1);

    await hardhatToken.connect(addr2).createMembership("eric");

    expect(await hardhatToken.connect(addr2).getMemberCount()).to.equal(2);
  });

  it("Contract should return names correctly with getMemberNameByID function", async function () {

    const [addr1, addr2] = await ethers.getSigners();

    const Memberships = await ethers.getContractFactory("Memberships");

    const hardhatToken = await Memberships.deploy();

    
    await hardhatToken.connect(addr1).createMembership("taylor");
    
    expect(await hardhatToken.getMemberNameByID(1)).to.equal("taylor");

    await hardhatToken.connect(addr2).createMembership("ferran");

    expect(await hardhatToken.getMemberNameByID(2)).to.equal("ferran");
  });

  it("Contract should update username correctly with updateMembership function", async function () {

    const Memberships = await ethers.getContractFactory("Memberships");

    const hardhatToken = await Memberships.deploy();

    
    await hardhatToken.createMembership("connie gray");
    
    expect(await hardhatToken.getMemberNameByID(1)).to.equal("connie gray");

    await hardhatToken.updateMembership(1, "connie ferran");

    expect(await hardhatToken.getMemberNameByID(1)).to.equal("connie ferran");
  });

  it("Contract should delete membership correctly based on id", async function () {

    const Memberships = await ethers.getContractFactory("Memberships");

    const hardhatToken = await Memberships.deploy();

    await hardhatToken.createMembership("roshan");

    expect(await hardhatToken.getMemberNameByID(1)).to.equal("roshan");

    await hardhatToken.deleteMembership(1);

    await expect(
      hardhatToken.getMemberNameByID(1)
    ).to.be.revertedWith("Membership inactive.");

  });

  it("Contract should not let users modify memberships they do not own", async function () {
    const [addr1, addr2] = await ethers.getSigners();

    const Memberships = await ethers.getContractFactory("Memberships");

    const hardhatToken = await Memberships.deploy();

    await hardhatToken.connect(addr1).createMembership("roshan");

    await expect(
    hardhatToken.connect(addr2).updateMembership(1,"ALLOOO")
    ).to.be.revertedWith("ID not accessible with this address.");

  });


  it("Contract should not let two memberships have the same username", async function () {

    const [addr1, addr2, addr3] = await ethers.getSigners();

    const Memberships = await ethers.getContractFactory("Memberships");

    const hardhatToken = await Memberships.deploy();

    await hardhatToken.connect(addr1).createMembership("Roshan");

    await hardhatToken.connect(addr2).createMembership("roshan");


    await expect(
      hardhatToken.connect(addr3).createMembership("Roshan")
    ).to.be.revertedWith("Username taken.");

  });

  it("Contract should expire a membership after 30 days", async function() {

    const[addr1] = await ethers.getSigners();

    const Memberships = await ethers.getContractFactory("Memberships");

    const membershipContract = await Memberships.deploy();

    await membershipContract.connect(addr1).createMembership("Taylor");

    expect(await membershipContract.connect(addr1).checkMembershipValidity(1)).to.equal(true);

    // 15 days
    await network.provider.send("evm_increaseTime", [1296000]);
    await network.provider.send("evm_mine");

    expect(await membershipContract.connect(addr1).checkMembershipValidity(1)).to.equal(true);


    // 15 days
    await network.provider.send("evm_increaseTime", [1296001]);
    await network.provider.send("evm_mine");

    expect(await membershipContract.connect(addr1).checkMembershipValidity(1)).to.equal(false);


  });

});