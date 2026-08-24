package com.pixelmmo;

import org.bukkit.Material;

public enum PlayerClass {
    NONE("Sin Clase", "§7Ninguna", Material.BARRIER, 20.0, 50, 0),
    BERSERKER("Guerrero Berserker", "§c⚔ Berserker", Material.NETHERITE_SWORD, 30.0, 50, 1),
    MAGE("Archimago Elemental", "§9🔮 Archimago", Material.BLAZE_ROD, 20.0, 150, 2),
    ASSASSIN("Asesino Sombrío", "§8🗡 Asesino", Material.NETHERITE_SWORD, 22.0, 80, 3),
    PALADIN("Paladín Sagrado", "§e✨ Paladín", Material.GOLDEN_AXE, 28.0, 100, 4),
    NECROMANCER("Nigromante Oscuro", "§5💀 Nigromante", Material.WITHER_SKELETON_SKULL, 22.0, 120, 5);

    private final String name;
    private final String displayName;
    private final Material icon;
    private final double baseHealth;
    private final int baseMana;
    private final int id;

    PlayerClass(String name, String displayName, Material icon, double baseHealth, int baseMana, int id) {
        this.name = name;
        this.displayName = displayName;
        this.icon = icon;
        this.baseHealth = baseHealth;
        this.baseMana = baseMana;
        this.id = id;
    }

    public String getName() { return name; }
    public String getDisplayName() { return displayName; }
    public Material getIcon() { return icon; }
    public double getBaseHealth() { return baseHealth; }
    public int getBaseMana() { return baseMana; }
    public int getId() { return id; }
}
