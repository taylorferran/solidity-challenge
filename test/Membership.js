const { expect } = require("chai");

describe("Memberships contract ", function () {
  it("Deployment should increment memberCount correctly", async function () {
    const [owner] = await ethers.getSigners();

    const Memberships = await ethers.getContractFactory("Memberships");

    const hardhatToken = await Memberships.deploy();

    expect(await hardhatToken.memberCount()).to.equal(1);

    await hardhatToken.createMembership("taylor");

    expect(await hardhatToken.memberCount()).to.equal(2);

    await hardhatToken.createMembership("ferran");

    expect(await hardhatToken.memberCount()).to.equal(3);
  });
});