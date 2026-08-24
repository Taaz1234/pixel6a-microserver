package com.pixelmmo;

import net.md_5.bungee.api.ChatMessageType;
import net.md_5.bungee.api.chat.TextComponent;
import org.bukkit.Bukkit;
import org.bukkit.command.Command;
import org.bukkit.command.CommandSender;
import org.bukkit.entity.Player;
import org.bukkit.plugin.java.JavaPlugin;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class PixelMMO extends JavaPlugin {
    private final Map<UUID, PlayerData> playerDataMap = new HashMap<>();

    @Override
    public void onEnable() {
        getLogger().info("========================================");
        getLogger().info("⚔ PixelMMO: Sistema MMORPG Inicializado ⚔");
        getLogger().info("Clases, Magias, Misiones y Pase de Batalla Activos");
        getLogger().info("========================================");

        // Registrar Eventos
        getServer().getPluginManager().registerEvents(new AbilityListener(this), this);
        getServer().getPluginManager().registerEvents(new MenuGUI(this), this);

        // Iniciar Tarea del HUD de Acción (HP, Maná, Nivel de Pase)
        startHUDTask();
    }

    @Override
    public void onDisable() {
        getLogger().info("PixelMMO desactivado.");
    }

    public PlayerData getPlayerData(Player p) {
        return playerDataMap.computeIfAbsent(p.getUniqueId(), PlayerData::new);
    }

    private void startHUDTask() {
        Bukkit.getScheduler().runTaskTimer(this, () -> {
            for (Player p : Bukkit.getOnlinePlayers()) {
                PlayerData data = getPlayerData(p);
                if (data.getPlayerClass() != PlayerClass.NONE) {
                    // Regeneración pasiva de maná
                    data.regenerateMana(4);

                    int hp = (int) p.getHealth();
                    int maxHp = (int) p.getMaxHealth();
                    int mana = data.getCurrentMana();
                    int maxMana = data.getMaxMana();
                    int passLvl = data.getPassLevel();
                    int mmoLvl = data.getLevel();

                    String hud = String.format(
                            "§c§l❤ §f%d/%d §8| §b§l✦ §f%d/%d §8| §e§l⭐ §fNv.%d §8| §6§l🎟 §fPase Nv.%d",
                            hp, maxHp, mana, maxMana, mmoLvl, passLvl
                    );

                    p.spigot().sendMessage(ChatMessageType.ACTION_BAR, TextComponent.fromLegacyText(hud));
                }
            }
        }, 20L, 20L); // Ejecutar cada 1 segundo (20 ticks)
    }

    @Override
    public boolean onCommand(CommandSender sender, Command command, String label, String[] args) {
        if (!(sender instanceof Player)) {
            sender.sendMessage("Solo jugadores pueden usar este comando.");
            return true;
        }

        Player p = (Player) sender;
        String cmd = command.getName().toLowerCase();

        if (cmd.equals("clase")) {
            MenuGUI.openClassSelection(p, this);
            return true;
        } else if (cmd.equals("misiones")) {
            MenuGUI.openQuestsMenu(p, this);
            return true;
        } else if (cmd.equals("pase")) {
            MenuGUI.openBattlePassMenu(p, this);
            return true;
        } else if (cmd.equals("stats")) {
            PlayerData data = getPlayerData(p);
            p.sendMessage("§8§m---------------- §6§lTUS ATRIBUTOS MMORPG §8§m----------------");
            p.sendMessage("§7Clase: " + data.getPlayerClass().getDisplayName());
            p.sendMessage("§7Nivel de Personaje: §e" + data.getLevel() + " §8(EXP: §a" + data.getExp() + "/" + (data.getLevel() * 200) + "§8)");
            p.sendMessage("§7Pase de Batalla: §6Nivel " + data.getPassLevel() + " §8(EXP: §a" + data.getPassExp() + "/200§8)");
            p.sendMessage("§7Vida Máxima: §c❤ " + (int) p.getMaxHealth() + " HP");
            p.sendMessage("§7Maná Máximo: §b✦ " + data.getMaxMana() + " Maná");
            p.sendMessage("§8§m--------------------------------------------------------");
            return true;
        }

        return false;
    }
}
