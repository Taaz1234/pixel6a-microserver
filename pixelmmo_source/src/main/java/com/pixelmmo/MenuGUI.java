package com.pixelmmo;

import org.bukkit.Bukkit;
import org.bukkit.Material;
import org.bukkit.Sound;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.inventory.InventoryClickEvent;
import org.bukkit.inventory.Inventory;
import org.bukkit.inventory.ItemStack;
import org.bukkit.inventory.meta.ItemMeta;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class MenuGUI implements Listener {
    private final PixelMMO plugin;

    public MenuGUI(PixelMMO plugin) {
        this.plugin = plugin;
    }

    // 1. MENÚ DE SELECCIÓN DE CLASES (Estilo WoW / Diablo)
    public static void openClassSelection(Player p, PixelMMO plugin) {
        Inventory inv = Bukkit.createInventory(null, 27, "§8⚔ §0Elige tu Clase MMORPG §8⚔");

        ItemStack glass = createItem(Material.GRAY_STAINED_GLASS_PANE, " ", null);
        for (int i = 0; i < 27; i++) inv.setItem(i, glass);

        inv.setItem(10, createItem(Material.NETHERITE_SWORD, "§c§l⚔ GUERRERO BERSERKER", Arrays.asList(
                "§7Rol: §cTanque & Daño Físico Brutal",
                "§7Vida Base: §c❤ 30 HP (15 Corazones)",
                "§7Maná: §b✦ 50",
                "",
                "§6Habilidades Activas:",
                " §e• Torbellino Sangriento §7(Clic Dcho): Gira dañando a todos.",
                " §e• Golpe Sísmico §7(Shift + Clic): Aturde en área.",
                "",
                "§a▶ ¡Haz Clic para Elegir esta Clase!"
        )));

        inv.setItem(12, createItem(Material.BLAZE_ROD, "§9§l🔮 ARCHIMAGO ELEMENTAL", Arrays.asList(
                "§7Rol: §9Daño Mágico a Distancia & Elementos",
                "§7Vida Base: §c❤ 20 HP (10 Corazones)",
                "§7Maná: §b✦ 150 (Alta Regeneración)",
                "",
                "§6Habilidades Activas:",
                " §e• Piroexplosión §7(Clic Dcho): Bola de fuego explosiva.",
                " §e• Cadena de Rayos §7(Shift + Clic): Rayos en cadena.",
                " §e• Blink / Teletransporte §7(Doble Shift): Salto espacial.",
                "",
                "§a▶ ¡Haz Clic para Elegir esta Clase!"
        )));

        inv.setItem(14, createItem(Material.IRON_SWORD, "§8§l🗡 ASESINO SOMBRÍO", Arrays.asList(
                "§7Rol: §8Sigilo, Velocidad & Críticos Mortales",
                "§7Vida Base: §c❤ 22 HP (11 Corazones)",
                "§7Maná: §b✦ 80",
                "",
                "§6Habilidades Activas:",
                " §e• Paso Sombrío §7(Clic Dcho): Invisibilidad (+300% Crítico).",
                " §e• Daga Envenenada §7(Shift + Clic): Veneno y lentitud.",
                "",
                "§a▶ ¡Haz Clic para Elegir esta Clase!"
        )));

        inv.setItem(16, createItem(Material.GOLDEN_AXE, "§e§l✨ PALADÍN SAGRADO", Arrays.asList(
                "§7Rol: §eDefensor Sagrado & Curación en Grupo",
                "§7Vida Base: §c❤ 28 HP (14 Corazones)",
                "§7Maná: §b✦ 100",
                "",
                "§6Habilidades Activas:",
                " §e• Aura de Santidad §7(Clic Dcho): Cura a todos los aliados.",
                " §e• Juicio Divino §7(Shift + Clic): Rayo sagrado del cielo.",
                "",
                "§a▶ ¡Haz Clic para Elegir esta Clase!"
        )));

        p.openInventory(inv);
    }

    // 2. MENÚ DE MISIONES DIARIAS Y SEMANALES
    public static void openQuestsMenu(Player p, PixelMMO plugin) {
        Inventory inv = Bukkit.createInventory(null, 27, "§8📜 §0Misiones & Desafíos");
        PlayerData data = plugin.getPlayerData(p);

        ItemStack glass = createItem(Material.BLACK_STAINED_GLASS_PANE, " ", null);
        for (int i = 0; i < 27; i++) inv.setItem(i, glass);

        // Misión Diaria 1: Cazador
        int mobs = Math.min(15, data.getDailyMobsKilled());
        inv.setItem(11, createItem(Material.ZOMBIE_HEAD, "§e§l⚔ Cazador de Monstruos §7(Diaria)", Arrays.asList(
                "§7Elimina 15 monstruos con tu clase.",
                "§7Progreso: " + getProgressBar(mobs, 15) + " §e" + mobs + "/15",
                "",
                "§6Recompensa: §a+150 EXP de Pase §8| §e+50 Oro",
                mobs >= 15 ? "§a✔ ¡MISIÓN COMPLETADA!" : "§c✖ En progreso..."
        )));

        // Misión Diaria 2: Maestro de Habilidades
        int skills = Math.min(20, data.getDailySkillsUsed());
        inv.setItem(13, createItem(Material.ENCHANTED_BOOK, "§b§l✦ Maestría Elemental §7(Diaria)", Arrays.asList(
                "§7Lanza 20 habilidades mágicas o de combate.",
                "§7Progreso: " + getProgressBar(skills, 20) + " §b" + skills + "/20",
                "",
                "§6Recompensa: §a+100 EXP de Pase §8| §b+30 Maná Máx Temporal",
                skills >= 20 ? "§a✔ ¡MISIÓN COMPLETADA!" : "§c✖ En progreso..."
        )));

        // Misión Diaria 3: Minería
        int ores = Math.min(30, data.getDailyMiningCount());
        inv.setItem(15, createItem(Material.DIAMOND_PICKAXE, "§6§l⛏ Minero del Reino §7(Diaria)", Arrays.asList(
                "§7Pica 30 bloques de minerales o piedra.",
                "§7Progreso: " + getProgressBar(ores, 30) + " §6" + ores + "/30",
                "",
                "§6Recompensa: §a+100 EXP de Pase §8| §6+3 Lingotes de Hierro",
                ores >= 30 ? "§a✔ ¡MISIÓN COMPLETADA!" : "§c✖ En progreso..."
        )));

        p.openInventory(inv);
    }

    // 3. MENÚ DEL PASE DE BATALLA (54 Slots)
    public static void openBattlePassMenu(Player p, PixelMMO plugin) {
        Inventory inv = Bukkit.createInventory(null, 54, "§8🎟 §0Pase de Batalla - Temporada 1");
        PlayerData data = plugin.getPlayerData(p);

        for (int lvl = 1; lvl <= 45; lvl++) {
            int slot = lvl - 1;
            boolean unlocked = data.getPassLevel() >= lvl;
            boolean claimed = data.hasClaimedReward(lvl);

            Material mat = claimed ? Material.MINECART : unlocked ? Material.CHEST_MINECART : Material.CHAIN;
            String status = claimed ? "§a✔ RECLAMADO" : unlocked ? "§e★ ¡LISTO PARA RECLAMAR! (Clic)" : "§c🔒 Bloqueado (Nv. " + lvl + ")";

            inv.setItem(slot, createItem(mat, "§6Nivel " + lvl + " §7del Pase", Arrays.asList(
                    "§7Recompensa: " + getRewardName(lvl),
                    "",
                    status
            )));
        }

        // Slot de Información del Pase
        inv.setItem(49, createItem(Material.NETHER_STAR, "§6§l🎟 TU PROGRESO DEL PASE", Arrays.asList(
                "§7Nivel Actual: §e" + data.getPassLevel() + "/50",
                "§7Progreso de EXP: §a" + data.getPassExp() + "/200 EXP",
                getProgressBar(data.getPassExp(), 200),
                "",
                "§7Completa §e/misiones §7para subir de nivel rápido."
        )));

        p.openInventory(inv);
    }

    private static String getRewardName(int level) {
        if (level % 10 == 0) return "§6👑 Cofre Legendario & Título Especial";
        if (level % 5 == 0) return "§d💎 Bolsa de 500 Monedas de Oro & Gema Rara";
        if (level % 2 == 0) return "§b🧪 Poción de Restauración de Maná & EXP";
        return "§e📦 Paquete de Materiales & Comida MMORPG";
    }

    private static String getProgressBar(int current, int max) {
        int totalBars = 10;
        int filled = (int) (((double) current / max) * totalBars);
        StringBuilder sb = new StringBuilder("§a");
        for (int i = 0; i < totalBars; i++) {
            if (i == filled) sb.append("§7");
            sb.append("■");
        }
        return sb.toString();
    }

    private static ItemStack createItem(Material mat, String name, List<String> lore) {
        ItemStack item = new ItemStack(mat);
        ItemMeta meta = item.getItemMeta();
        if (meta != null) {
            meta.setDisplayName(name);
            if (lore != null) meta.setLore(lore);
            item.setItemMeta(meta);
        }
        return item;
    }

    @EventHandler
    public void onClick(InventoryClickEvent event) {
        if (event.getView().getTitle().contains("Elige tu Clase MMORPG")) {
            event.setCancelled(true);
            if (event.getCurrentItem() == null) return;
            Player p = (Player) event.getWhoClicked();
            PlayerData data = plugin.getPlayerData(p);

            Material mat = event.getCurrentItem().getType();
            if (mat == Material.NETHERITE_SWORD) {
                data.setPlayerClass(PlayerClass.BERSERKER);
                giveClassWelcome(p, PlayerClass.BERSERKER);
            } else if (mat == Material.BLAZE_ROD) {
                data.setPlayerClass(PlayerClass.MAGE);
                giveClassWelcome(p, PlayerClass.MAGE);
            } else if (mat == Material.IRON_SWORD) {
                data.setPlayerClass(PlayerClass.ASSASSIN);
                giveClassWelcome(p, PlayerClass.ASSASSIN);
            } else if (mat == Material.GOLDEN_AXE) {
                data.setPlayerClass(PlayerClass.PALADIN);
                giveClassWelcome(p, PlayerClass.PALADIN);
            }
        } else if (event.getView().getTitle().contains("Pase de Batalla")) {
            event.setCancelled(true);
            if (event.getCurrentItem() == null) return;
            Player p = (Player) event.getWhoClicked();
            PlayerData data = plugin.getPlayerData(p);
            int slot = event.getSlot();
            int level = slot + 1;

            if (level >= 1 && level <= 45) {
                if (data.getPassLevel() >= level && !data.hasClaimedReward(level)) {
                    data.claimReward(level);
                    p.playSound(p.getLocation(), Sound.ENTITY_PLAYER_LEVELUP, 1.0f, 1.2f);
                    p.sendMessage("§a🎉 ¡Has reclamado la recompensa del Nivel " + level + " del Pase de Batalla!");
                    openBattlePassMenu(p, plugin);
                } else if (data.hasClaimedReward(level)) {
                    p.sendMessage("§cYa has reclamado esta recompensa.");
                } else {
                    p.sendMessage("§cTodavía no has alcanzado este nivel del Pase.");
                }
            }
        } else if (event.getView().getTitle().contains("Misiones & Desafíos")) {
            event.setCancelled(true);
        }
    }

    private void giveClassWelcome(Player p, PlayerClass pClass) {
        p.closeInventory();
        AbilityListener.updatePlayerAttributes(p, plugin.getPlayerData(p));
        p.playSound(p.getLocation(), Sound.UI_TOAST_CHALLENGE_COMPLETE, 1.0f, 1.0f);
        p.sendTitle("§6¡Has elegido tu Clase!", pClass.getDisplayName(), 10, 60, 20);
        p.sendMessage("§8§m------------------------------------------------");
        p.sendMessage("§6¡Felicidades, Héroe! Ahora eres un " + pClass.getDisplayName() + "§6.");
        p.sendMessage("§e• Usa §f/clase §epara ver tus habilidades.");
        p.sendMessage("§e• Usa §f/misiones §epara ver tus tareas diarias.");
        p.sendMessage("§e• Usa §f/pase §epara abrir el Pase de Batalla.");
        p.sendMessage("§8§m------------------------------------------------");
    }
}
