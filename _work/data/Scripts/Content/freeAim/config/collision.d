/*
 * This file contains all configurations for collision and hit registration of projectiles.
 */


/*
 * This function is called every time an NPC is hit by a projectile (arrows and bolts). It can be used to define the
 * collision behavior (or disabling hit registration) on NPCs based on different criteria.
 * The argument 'material' holds the material of the armor (of the target), -1 for no armor equipped. For armors of NPCs
 * the materials are defined as in Constants.d (MAT_METAL, MAT_WOOD, ...).
 *
 * Ideas: 'ineffective' ranged weapons, armor materials immune to arrows, disable friendly-fire, maximum range. Examples
 * are written below and commented out and serve as inspiration of what is possible
 */
func int freeAimHitRegNpc(var C_Npc target, var C_Item weapon, var int material) {
    // Valid return values are:
    const int DESTROY = 0; // No hit registration (no damage), projectile is destroyed
    const int COLLIDE = 1; // Hit registration (damage), projectile is put into inventory
    const int DEFLECT = 2; // No hit registration (no damage), projectile is repelled

    if (target.aivar[AIV_PARTYMEMBER]) && (target.aivar[AIV_LASTTARGET] != Hlp_GetInstanceID(hero)) {
        // Disable friendly-fire
        return DESTROY;
    };

    /*
    if (material == MAT_METAL) && (Hlp_Random(100) < 20) {
        // Metal armors may be more durable
        return DEFLECT;
    }; */

    if (Npc_GetDistToPlayer(target) > FIGHT_DIST_CANCEL) {
        // If player is too far away, do nothing. This is important, because of a limitation in the AI. NPCs do not
        // react to damage if they are shot from outside of the ranged combat distance. This check fixes the problem
        return DESTROY;
    };

    /*
    if (Hlp_IsValidItem(weapon)) {
        // The weapon can also be considered (e.g. ineffective weapons). Make use of 'weapon' for that
        // Caution: Weapon may have been unequipped already at this time (unlikely)! Use Hlp_IsValidItem(weapon)

        if (weapon.ineffective) {
            // Special case for weapon property
            return DEFLECT;
        };
    }; */

    // Usually all shots on NPCs should be registered. For defining the hit chances see freeAimGetAccuracy()
    return COLLIDE;
};


/*
 * This function is called every time the world (static or vobs) is hit by a projectile (arrows and bolts). It can be
 * used to define the collision behavior for different materials or surface textures.
 * Note: Unlike freeAimHitRegNpc() and all other config functions, this function is also called for NPC shooters!
 *
 * The parameter 'materials' is a bit field for all materials attached to the hit object.
 * The parameter 'textures' is a string containing all texture names, delimiter: |
 *
 * CAUTION: Unfortunately, all vobs in Gothic 1 belong to the UNDEF material group. With descriptive texture names,
 * however, the material can be retrieved, e.g. (STR_IndexOf(textures, "WOOD") != 1).
 *
 * Examples are written below and commented out and serve as inspiration of what is possible.
 */
func int freeAimHitRegWld(var C_Npc shooter, var C_Item weapon, var int materials, var string textures) {
    // Valid return values are:
    const int DESTROY = 0; // Projectile is destroyed on impact
    const int STUCK   = 1; // Projectile gets stuck in the surface
    const int DEFLECT = 2; // Projectile is repelled

    // Several materials may be present
    const int UNDEF = 1<<0;
    const int METAL = 1<<1;
    const int STONE = 1<<2;
    const int WOOD  = 1<<3;
    const int EARTH = 1<<4;
    const int WATER = 1<<5;
    const int SNOW  = 1<<6;

    if (materials & WOOD) || (STR_IndexOf(textures, "WOOD") != -1) {
        // Projectiles stay stuck in wood (default in Gothic 2)
        return STUCK;
    };

    // Examples by texture name
    if (STR_IndexOf(textures, "|MOWOBOWMARK01.TGA") != -1) // Bullseye/shooting range texture (mind the delimiter '|')
    || (STR_IndexOf(textures, "|OCODWAWEHRGANGDA.TGA") != -1) { // Ore crate texture
        return STUCK;
    };

    /*
    if (Npc_IsPlayer(shooter)) {
        // Keep in mind that this function is also called for NPC shooters
        // ...
    }; */

    if ((materials & STONE) || (STR_IndexOf(textures, "STONE") != -1))
    && (Hlp_Random(100) < 20) {
        // The projectile might break on impact with stone (20% of the shots)
        return DESTROY;
    };

    // Since Gothic 1 is a bit weak on the material properties, here is a list of textures name key words, that fix that
    // deficit. This part can safely be deleted when using Gothic 2
    if (STR_IndexOf(textures, "BAUM") != -1)
    || (STR_IndexOf(textures, "TREE") != -1)
    || (STR_IndexOf(textures, "RANKEN") != -1)
    || (STR_IndexOf(textures, "RINDE") != -1)
    || (STR_IndexOf(textures, "BARK") != -1)
    || (STR_IndexOf(textures, "BUSH") != -1)
    || (STR_IndexOf(textures, "PLANT") != -1)
    || (STR_IndexOf(textures, "ROOT") != -1)
    || (STR_IndexOf(textures, "FOREST") != -1)
    || (STR_IndexOf(textures, "PLANK") != -1)
    || (STR_IndexOf(textures, "BRETT") != -1)
    || (STR_IndexOf(textures, "LATTE") != -1)
    || (STR_IndexOf(textures, "HOLZ") != -1)
    || (STR_IndexOf(textures, "BOOK") != -1)
    || (STR_IndexOf(textures, "SKULL") != -1)
    || (STR_IndexOf(textures, "BEAM") != -1)
    || (STR_IndexOf(textures, "CRATE") != -1)
    || (STR_IndexOf(textures, "CHEST") != -1)
    || (STR_IndexOf(textures, "SHELF") != -1)
    || (STR_IndexOf(textures, "TABLE") != -1)
    || (STR_IndexOf(textures, "LOG") != -1)
    || (STR_IndexOf(textures, "BED") != -1)
    || (STR_IndexOf(textures, "BARREL") != -1)
    || (STR_IndexOf(textures, "FASS") != -1)
    || (STR_IndexOf(textures, "HUETTE") != -1) {
        return STUCK;
    };

    // Projectiles deflect off of all of other surfaces (default behavior of Gothic 2)
    return DEFLECT;
};
