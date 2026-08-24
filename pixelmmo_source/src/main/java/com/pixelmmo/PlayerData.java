package com.pixelmmo;

import org.bukkit.entity.Player;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

public class PlayerData {
    private final UUID uuid;
    private PlayerClass playerClass = PlayerClass.NONE;
    private int level = 1;
    private int exp = 0;
    private int currentMana = 50;
    private int maxMana = 50;
    
    // Battle Pass & Quests
    private int passLevel = 1;
    private int passExp = 0;
    private final Set<Integer> claimedPassRewards = new HashSet<>();
    
    // Daily Quest counters
    private int dailyMobsKilled = 0;
    private int dailySkillsUsed = 0;
    private int dailyMiningCount = 0;

    // Cooldown timestamps
    private long lastSkill1 = 0;
    private long lastSkill2 = 0;
    private long lastSkill3 = 0;

    public PlayerData(UUID uuid) {
        this.uuid = uuid;
    }

    public UUID getUuid() { return uuid; }
    public PlayerClass getPlayerClass() { return playerClass; }
    public void setPlayerClass(PlayerClass playerClass) {
        this.playerClass = playerClass;
        this.maxMana = playerClass.getBaseMana();
        this.currentMana = this.maxMana;
    }

    public int getLevel() { return level; }
    public void setLevel(int level) { this.level = level; }

    public int getExp() { return exp; }
    public void addExp(int amount) {
        this.exp += amount;
        if (this.exp >= level * 200) {
            this.exp -= level * 200;
            this.level++;
        }
    }

    public int getCurrentMana() { return currentMana; }
    public void setCurrentMana(int currentMana) {
        this.currentMana = Math.max(0, Math.min(currentMana, maxMana));
    }
    public int getMaxMana() { return maxMana; }
    public void setMaxMana(int maxMana) { this.maxMana = maxMana; }

    public boolean useMana(int amount) {
        if (currentMana >= amount) {
            currentMana -= amount;
            return true;
        }
        return false;
    }

    public void regenerateMana(int amount) {
        this.currentMana = Math.min(maxMana, currentMana + amount);
    }

    public int getPassLevel() { return passLevel; }
    public int getPassExp() { return passExp; }
    public void addPassExp(int amount) {
        this.passExp += amount;
        while (this.passExp >= 200 && this.passLevel < 50) {
            this.passExp -= 200;
            this.passLevel++;
        }
    }

    public boolean hasClaimedReward(int level) {
        return claimedPassRewards.contains(level);
    }

    public void claimReward(int level) {
        claimedPassRewards.add(level);
    }

    public int getDailyMobsKilled() { return dailyMobsKilled; }
    public void incDailyMobsKilled() { this.dailyMobsKilled++; }

    public int getDailySkillsUsed() { return dailySkillsUsed; }
    public void incDailySkillsUsed() { this.dailySkillsUsed++; }

    public int getDailyMiningCount() { return dailyMiningCount; }
    public void incDailyMiningCount() { this.dailyMiningCount++; }

    public boolean isCooldown(int skillNum, long cooldownMillis) {
        long now = System.currentTimeMillis();
        long last = skillNum == 1 ? lastSkill1 : skillNum == 2 ? lastSkill2 : lastSkill3;
        return (now - last) < cooldownMillis;
    }

    public void setCooldown(int skillNum) {
        long now = System.currentTimeMillis();
        if (skillNum == 1) lastSkill1 = now;
        else if (skillNum == 2) lastSkill2 = now;
        else if (skillNum == 3) lastSkill3 = now;
    }
}
