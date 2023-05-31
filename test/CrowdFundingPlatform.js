const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("CrowdFundingPlatformFactory", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
    const ONE_GWEI = 1_000_000_000;

    const lockedAmount = ONE_GWEI;
    const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;
    const beginTimestamp = 1685441612;
    const endTimestamp = 1688109212;

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Lock = await ethers.getContractFactory("CrowdFundingPlatform");
    const lock = await Lock.deploy();

    return { lock, beginTimestamp, endTimestamp, owner, otherAccount };
  }

  async function createEventWith(
    manager,
    identifier,
    value,
    beginTimestamp,
    endTimestamp
  ) {
    manager.createEvent(
      identifier,
      "test",
      "tes",
      ethers.utils.parseUnits(value, "ether"),
      beginTimestamp,
      endTimestamp
    );
  }

  async function createEvent(manager, identifier, value) {
    const beginTimestamp = 1685441612;
    const endTimestamp = 1688109212;

    manager.createEvent(
      identifier,
      "test",
      "tes",
      ethers.utils.parseUnits(value, "ether"),
      beginTimestamp,
      endTimestamp
    );
  }

  describe("Deployment", function () {
    it("Create Unique event", async function () {
      const { lock } = await loadFixture(deployOneYearLockFixture);

      await expect(createEvent(lock, 12, "3")).not.to.be.reverted;
    });

    it("Should revert with erorr already exists event with same Idetifier", async function () {
      const { lock, beginTimestamp, endTimestamp } = await loadFixture(
        deployOneYearLockFixture
      );

      await createEvent(lock, 12, "3");

      await expect( 
        lock.createEvent(
          12,
          "test",
          "tes",
          ethers.utils.parseUnits("3", "ether"),
          beginTimestamp,
          endTimestamp
        )
      ).to.be.revertedWith("Already exists event with Identifier");
    });
  });

  describe("Funding", function () {
    it("Should revert with error for to much fund ", async function () {
      const { lock, beginTimestamp, endTimestamp } = await loadFixture(
        deployOneYearLockFixture
      );

      await createEvent(lock, 12, "3");

      await expect(
        lock.fund(12, { value: ethers.utils.parseUnits("4", "ether") })
      ).to.be.revertedWith("To much");
    });

    it("Funds raising with success", async function () {
      const { lock, beginTimestamp, endTimestamp } = await loadFixture(
        deployOneYearLockFixture
      );

      await createEvent(lock, 12, "3");

      await expect(
        lock.fund(12, { value: ethers.utils.parseUnits("2", "ether") })
      ).not.to.be.reverted;
    });

    it("Funds raising should failed with not start event", async function () {
      const { lock, endTimestamp } = await loadFixture(
        deployOneYearLockFixture
      );
      const beginTimestamp = 1687522972;

      await createEventWith(lock, 12, "3", beginTimestamp, endTimestamp);

      await expect(
        lock.fund(12, { value: ethers.utils.parseUnits("2", "ether") })
      ).to.be.revertedWith("The funding not open yet.");
    });

  });

  describe("Refunding", function () {
    it("Succesfully refund", async function () {
      const { lock,  } = await loadFixture(
        deployOneYearLockFixture
      );
      const beginTimestamp = 1685513026;
      const endTimestamp = 1690081426;

      await createEventWith(lock, 12, "3", beginTimestamp, endTimestamp);
      lock.fund(12, { value: ethers.utils.parseUnits("3", "ether")});
      lock.fund(12, { value: ethers.utils.parseUnits("3", "ether")});

      await expect(
        lock.refund(12, { value: ethers.utils.parseUnits("6", "ether")})
      ).not.to.be.reverted;
    });

  });

  describe("Withdraw", function () {
    it("Event owner succesfully withdraws funds", async function () {
      const { lock,  } = await loadFixture(
        deployOneYearLockFixture
      );
      const beginTimestamp = 1685513026;
      const endTimestamp = 1690081426;

      await createEventWith(lock, 12, "3", beginTimestamp, endTimestamp);
      lock.fund(12, { value: ethers.utils.parseUnits("3", "ether")});
      lock.fund(12, { value: ethers.utils.parseUnits("3", "ether")});

      await expect(
        lock.withdrawFunds(12)
      ).not.to.be.reverted;
    });

  });
    
});
