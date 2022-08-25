const { expect } = require("chai");

describe("Memberships contract ", function () {
  it("Contract should increment memberCount correctly", async function () {

    const Memberships = await ethers.getContractFactory("Memberships");

    const hardhatToken = await Memberships.deploy();

    expect(await hardhatToken.getMemberCount()).to.equal(1);

    await hardhatToken.createMembership("sam");

    expect(await hardhatToken.getMemberCount()).to.equal(2);

    await hardhatToken.createMembership("eric");

    expect(await hardhatToken.getMemberCount()).to.equal(3);
  });

  it("Contract should return names correctly with getMemberNameByID function", async function () {

    const Memberships = await ethers.getContractFactory("Memberships");

    const hardhatToken = await Memberships.deploy();

    
    await hardhatToken.createMembership("taylor");
    
    expect(await hardhatToken.getMemberNameByID(1)).to.equal("taylor");

    await hardhatToken.createMembership("ferran");

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
});