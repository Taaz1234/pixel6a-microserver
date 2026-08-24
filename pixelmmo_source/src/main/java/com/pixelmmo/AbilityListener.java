package com.pixelmmo;

import org.bukkit.Location;
import org.bukkit.Particle;
import org.bukkit.Sound;
import org.bukkit.attribute.Attribute;
import org.bukkit.entity.*;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.block.Action;
import org.bukkit.event.block.BlockBreakEvent;
import org.bukkit.event.entity.EntityDamageByEntityEvent;
import org.bukkit.event.entity.EntityDeathEvent;
import org.bukkit.event.player.PlayerInteractEvent;
import org.bukkit.event.player.PlayerJoinEvent;
import org.bukkit.event.player.PlayerToggleSneakEvent;
import org.bukkit.potion.PotionEffect;
import org.bukkit.potion.PotionEffectType;
import org.bukkit.util.Vector;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class AbilityListener implements Listener {
    private final PixelMMO plugin;

    public AbilityListener(PixelMMO plugin) {
        this.plugin = plugin;
    }

    @EventHandler
    public void onJoin(PlayerJoinEvent event) {
        Player p = event.getPlayer();
        PlayerData data = plugin.getPlayerData(p);

        if (data.getPlayerClass() == PlayerClass.NONE) {
            plugin.getServer().getScheduler().runTaskLater(plugin, () -> {
                p.sendTitle("§6⚔ §lPIXEL MMORPG §6⚔", "§eElige tu Clase de Héroe", 10, 70, 20);
                p.playSound(p.getLocation(), Sound.UI_TOAST_CHALLENGE_COMPLETE, 1.0f, 1.0f);
                MenuGUI.openClassSelection(p, plugin);
            }, 30L);
        } else {
            p.sendTitle("§6Bienvenido de vuelta", data.getPlayerClass().getDisplayName(), 10, 40, 10);
            updatePlayerAttributes(p, data);
        }
    }

    public static void updatePlayerAttributes(Player p, PlayerData data) {
        try {
            Attribute attr = Attribute.MAX_HEALTH;
            if (p.getAttribute(attr) != null) {
                p.getAttribute(attr).setBaseValue(data.getPlayerClass().getBaseHealth());
            }
        } catch (Throwable t) {
            // Fallback for older attributes
            try {
                Attribute attr = Attribute.valueOf("GENERIC_MAX_HEALTH");
                if (p.getAttribute(attr) != null) {
                    p.getAttribute(attr).setBaseValue(data.getPlayerClass().getBaseHealth());
                }
            } catch (Throwable ignored) {}
        }
    }

    @EventHandler
    public void onInteract(PlayerInteractEvent event) {
        Player p = event.getPlayer();
        PlayerData data = plugin.getPlayerData(p);
        PlayerClass pClass = data.getPlayerClass();

        if (pClass == PlayerClass.NONE) return;

        Action action = event.getAction();
        boolean isRight = (action == Action.RIGHT_CLICK_AIR || action == Action.RIGHT_CLICK_BLOCK);
        boolean isShift = p.isSneaking();

        // 1. BERSERKER ABILITIES
        if (pClass == PlayerClass.BERSERKER) {
            if (isRight && !isShift) {
                // Habilidad 1: Torbellino Sangriento
                if (data.isCooldown(1, 6000)) {
                    p.sendMessage("§c⏳ Torbellino en enfriamiento...");
                    return;
                }
                if (!data.useMana(15)) {
                    p.sendMessage("§c✦ ¡Maná insuficiente! (15 Maná)");
                    return;
                }
                data.setCooldown(1);
                data.incDailySkillsUsed();

                p.playSound(p.getLocation(), Sound.ENTITY_PLAYER_ATTACK_SWEEP, 1.2f, 0.8f);
                p.getWorld().spawnParticle(Particle.SWEEP_ATTACK, p.getLocation().add(0, 1, 0), 20, 1.5, 0.5, 1.5, 0.1);
                p.getWorld().spawnParticle(Particle.FLAME, p.getLocation().add(0, 1, 0), 30, 1.5, 0.5, 1.5, 0.05);

                for (Entity e : p.getNearbyEntities(4.5, 2.5, 4.5)) {
                    if (e instanceof LivingEntity && !(e instanceof Player)) {
                        ((LivingEntity) e).damage(9.0 + data.getLevel() * 0.5, p);
                        Vector dir = e.getLocation().toVector().subtract(p.getLocation().toVector()).normalize().multiply(0.8).setY(0.4);
                        e.setVelocity(dir);
                    }
                }
                p.sendMessage("§c⚔ ¡Has usado Torbellino Sangriento!");
            }
        }

        // 2. ARCHIMAGO ABILITIES
        else if (pClass == PlayerClass.MAGE) {
            if (isRight && !isShift) {
                // Habilidad 1: Piroexplosión
                if (data.isCooldown(1, 3000)) {
                    p.sendMessage("§c⏳ Piroexplosión en enfriamiento...");
                    return;
                }
                if (!data.useMana(25)) {
                    p.sendMessage("§c✦ ¡Maná insuficiente! (25 Maná)");
                    return;
                }
                data.setCooldown(1);
                data.incDailySkillsUsed();

                Fireball fireball = p.launchProjectile(Fireball.class);
                fireball.setIsIncendiary(true);
                fireball.setYield(1.5f);
                p.playSound(p.getLocation(), Sound.ENTITY_GHAST_SHOOT, 1.0f, 1.2f);
                p.getWorld().spawnParticle(Particle.LAVA, p.getLocation(), 15, 0.5, 0.5, 0.5);
                p.sendMessage("§9🔮 ¡Piroexplosión lanzada!");
            } else if (isRight && isShift) {
                // Habilidad 2: Cadena de Rayos
                if (data.isCooldown(2, 8000)) {
                    p.sendMessage("§c⏳ Cadena de Rayos en enfriamiento...");
                    return;
                }
                if (!data.useMana(40)) {
                    p.sendMessage("§c✦ ¡Maná insuficiente! (40 Maná)");
                    return;
                }
                data.setCooldown(2);
                data.incDailySkillsUsed();

                int struck = 0;
                for (Entity e : p.getNearbyEntities(12, 6, 12)) {
                    if (e instanceof LivingEntity && !(e instanceof Player)) {
                        p.getWorld().strikeLightningEffect(e.getLocation());
                        ((LivingEntity) e).damage(12.0 + data.getLevel(), p);
                        struck++;
                        if (struck >= 4) break;
                    }
                }
                p.playSound(p.getLocation(), Sound.ENTITY_LIGHTNING_BOLT_THUNDER, 1.0f, 1.4f);
                p.sendMessage("§9⚡ ¡Cadena de Rayos ha impactado a " + struck + " enemigos!");
            }
        }

        // 3. ASESINO ABILITIES
        else if (pClass == PlayerClass.ASSASSIN) {
            if (isRight && !isShift) {
                // Habilidad 1: Paso Sombrío (Invisibilidad + Velocidad)
                if (data.isCooldown(1, 10000)) {
                    p.sendMessage("§c⏳ Paso Sombrío en enfriamiento...");
                    return;
                }
                if (!data.useMana(20)) {
                    p.sendMessage("§c✦ ¡Maná insuficiente! (20 Maná)");
                    return;
                }
                data.setCooldown(1);
                data.incDailySkillsUsed();

                p.addPotionEffect(new PotionEffect(PotionEffectType.INVISIBILITY, 120, 1));
                p.addPotionEffect(new PotionEffect(PotionEffectType.SPEED, 120, 2));
                p.getWorld().spawnParticle(Particle.SQUID_INK, p.getLocation().add(0, 1, 0), 40, 0.5, 0.5, 0.5, 0.1);
                p.playSound(p.getLocation(), Sound.ENTITY_ENDERMAN_TELEPORT, 1.0f, 1.5f);
                p.sendMessage("§8🗡 ¡Te has desvanecido en las sombras! (Próximo golpe crítico)");
            }
        }

        // 4. PALADÍN ABILITIES
        else if (pClass == PlayerClass.PALADIN) {
            if (isRight && !isShift) {
                // Habilidad 1: Aura de Santidad (Curación en área)
                if (data.isCooldown(1, 8000)) {
                    p.sendMessage("§c⏳ Aura de Santidad en enfriamiento...");
                    return;
                }
                if (!data.useMana(30)) {
                    p.sendMessage("§c✦ ¡Maná insuficiente! (30 Maná)");
                    return;
                }
                data.setCooldown(1);
                data.incDailySkillsUsed();

                p.setHealth(Math.min(p.getMaxHealth(), p.getHealth() + 8.0));
                p.getWorld().spawnParticle(Particle.TOTEM_OF_UNDYING, p.getLocation().add(0, 1, 0), 40, 1.5, 1.0, 1.5, 0.2);
                p.getWorld().spawnParticle(Particle.HEART, p.getLocation().add(0, 1.5, 0), 10, 0.8, 0.8, 0.8);
                p.playSound(p.getLocation(), Sound.ITEM_TOTEM_USE, 0.8f, 1.4f);

                for (Entity e : p.getNearbyEntities(6, 4, 6)) {
                    if (e instanceof Player) {
                        Player ally = (Player) e;
                        ally.setHealth(Math.min(ally.getMaxHealth(), ally.getHealth() + 6.0));
                        ally.sendMessage("§e✨ ¡Has recibido la bendición curativa de " + p.getName() + "!");
                    }
                }
                p.sendMessage("§e✨ ¡Aura de Santidad activada!");
            }
        }

        // 5. NIGROMANTE ABILITIES
        else if (pClass == PlayerClass.NECROMANCER) {
            if (isRight && !isShift) {
                // Habilidad 1: Invocar Espectros
                if (data.isCooldown(1, 15000)) {
                    p.sendMessage("§c⏳ Invocación en enfriamiento...");
                    return;
                }
                if (!data.useMana(45)) {
                    p.sendMessage("§c✦ ¡Maná insuficiente! (45 Maná)");
                    return;
                }
                data.setCooldown(1);
                data.incDailySkillsUsed();

                Location loc = p.getLocation();
                for (int i = 0; i < 2; i++) {
                    Skeleton sk = (Skeleton) p.getWorld().spawnEntity(loc.clone().add(Math.sin(i * 3) * 2, 0, Math.cos(i * 3) * 2), EntityType.SKELETON);
                    sk.setCustomName("§5Espectro de " + p.getName());
                    sk.setCustomNameVisible(true);
                }
                p.getWorld().spawnParticle(Particle.SOUL_FIRE_FLAME, loc.add(0, 1, 0), 40, 1.0, 1.0, 1.0, 0.05);
                p.playSound(loc, Sound.ENTITY_WITHER_SPAWN, 0.6f, 1.5f);
                p.sendMessage("§5💀 ¡Has invocado sirvientes de las sombras!");
            }
        }
    }

    // Doble Shift / Sneak para Teletransporte del Mago
    private final Map<UUID, Long> lastSneak = new HashMap<>();

    @EventHandler
    public void onSneak(PlayerToggleSneakEvent event) {
        if (!event.isSneaking()) return;
        Player p = event.getPlayer();
        PlayerData data = plugin.getPlayerData(p);

        if (data.getPlayerClass() == PlayerClass.MAGE) {
            long now = System.currentTimeMillis();
            long last = lastSneak.getOrDefault(p.getUniqueId(), 0L);
            lastSneak.put(p.getUniqueId(), now);

            if (now - last < 400) { // Doble Shift rápido
                if (data.isCooldown(3, 5000)) {
                    p.sendMessage("§c⏳ Blink en enfriamiento...");
                    return;
                }
                if (!data.useMana(20)) {
                    p.sendMessage("§c✦ ¡Maná insuficiente! (20 Maná)");
                    return;
                }
                data.setCooldown(3);
                data.incDailySkillsUsed();

                Location start = p.getLocation();
                Vector dir = start.getDirection().normalize().multiply(8);
                Location dest = start.add(dir);
                dest.setY(p.getWorld().getHighestBlockYAt(dest) + 1);

                p.getWorld().spawnParticle(Particle.PORTAL, p.getLocation().add(0, 1, 0), 40, 0.5, 0.5, 0.5, 0.5);
                p.teleport(dest);
                p.getWorld().spawnParticle(Particle.REVERSE_PORTAL, dest.add(0, 1, 0), 40, 0.5, 0.5, 0.5, 0.5);
                p.playSound(dest, Sound.ENTITY_ENDERMAN_TELEPORT, 1.0f, 1.0f);
                p.sendMessage("§9🌀 ¡Blink teletransportado!");
            }
        }
    }

    // Misiones y EXP por matar Mobs
    @EventHandler
    public void onKill(EntityDeathEvent event) {
        if (event.getEntity().getKiller() != null) {
            Player p = event.getEntity().getKiller();
            PlayerData data = plugin.getPlayerData(p);
            data.addExp(25);
            data.addPassExp(15);
            data.incDailyMobsKilled();
        }
    }

    // Misión de Minería
    @EventHandler
    public void onMine(BlockBreakEvent event) {
        Player p = event.getPlayer();
        PlayerData data = plugin.getPlayerData(p);
        data.incDailyMiningCount();
        if (data.getDailyMiningCount() % 10 == 0) {
            data.addPassExp(5);
        }
    }
}
