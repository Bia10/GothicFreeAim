/*
 * This file contains all configurations for reticles. For a list of reticle textures, see config\reticleTextures.d.
 *
 * Supported: Gothic 1 and Gothic 2
 */


/*
 * This function is called continuously while aiming with a ranged weapon (bows and crossbows). It allows defining the
 * reticle texture, size and color at any point in time while aiming, based on a variety of properties. Reticle size is
 * represented as a percentage (100 is biggest size, 0 is smallest).
 *
 * Here, the size is scaled by aiming distance. As indicated by the in-line comments basing the size (or color) on the
 * functions freeAimGetDrawForce() and freeAimGetAccuracy() is also possible.
 */
func void freeAimGetReticleRanged(var C_Npc target, var C_Item weapon, var int talent, var int dist, var int rtrnPtr) {
    // Get reticle instance from call-by-reference argument
    var Reticle reticle; reticle = _^(rtrnPtr);

    // Color (do not set the color to preserve the original texture color)
    if (Hlp_IsValidNpc(target)) {
        // The argument 'target' might be empty!

        var int att; att = Npc_GetAttitude(target, hero);
        if (att == ATT_HOSTILE) {
            reticle.color = Focusnames_Color_Hostile();
        };
        /*
        // For now, do not color friendly NPCs green (reticle stays white)
        if (att == ATT_FRIENDLY) {
            reticle.color = Focusnames_Color_Friendly();
        }; */

    } else {
        // If no NPC is in focus color it slightly gray
        reticle.color = RGBA(175, 175, 175, 255);
    };

    // Size (scale between [0, 100]: 0 is smallest, 100 is biggest)
    reticle.size = -dist + 100; // Inverse aim distance: bigger for closer range: 100 for closest, 0 for most distance
    //  reticle.size = -freeAimGetDrawForce(weapon, talent) + 100; // Or inverse draw force: bigger for less draw force
    //  reticle.size = -freeAimGetAccuracy(weapon, talent) + 100; // Or inverse accuracy: bigger with lower accuracy

    // More sophisticated customization is also possible: change the texture by draw force, the size by accuracy, ...
    if (weapon.flags & ITEM_BOW) {
        // Change reticle texture by drawforce (irrespective of the reticle size set above)

        // Get draw force from the function above. Already scaled to [0, 100]
        var int drawForce; drawForce = freeAimGetDrawForce(weapon, talent);

        // Animate reticle by draw force
        reticle.texture = freeAimAnimateReticleByPercent(RETICLE_NOTCH, drawForce, 17);

    } else if (weapon.flags & ITEM_CROSSBOW) {
        // Reticle is fixed, but resized with distance
        reticle.texture = RETICLE_PEAK;

        /*
        // Alternatively, change the reticle texture with distance
        reticle.size = 75; // Keep the size fixed here
        reticle.texture = freeAimAnimateReticleByPercent(RETICLE_DROP, dist, 8); // Animate reticle with distance */
    };
};


/*
 * This function is called continuously while aiming with a spells. It allows defining the reticle texture, size and
 * color at any point in time while aiming, based on a variety of spell properties. Reticle size is represented as a
 * percentage (100 is biggest size, 0 is smallest).
 * To hide the reticle (might be of interest for certain spells), set the texture to an empty string.
 *
 * Here, the size is scaled by aiming distance. As indicated by the in-line comments basing the size (or color) on the
 * any provided spell property is easily possible.
 *
 * Examples are written below and commented out and serve as inspiration of what is possible.
 */
func void freeAimGetReticleSpell(var C_Npc target, var int spellID, var C_Spell spellInst, var int spellLevel,
        var int isScroll, var int manaInvested, var int dist, var int rtrnPtr) {
    // Get reticle instance from call-by-reference argument
    var Reticle reticle; reticle = _^(rtrnPtr);

    /*
    // Different reticles by spell type
    if (spellInst.spellType == SPELL_GOOD) {
        reticle.texture = RETICLE_CIRCLECROSS;
    } else if (spellInst.spellType == SPELL_NEUTRAL) {
        reticle.texture = RETICLE_CIRCLECROSS;
    } else if (spellInst.spellType == SPELL_BAD) {
        reticle.texture = RETICLE_CIRCLECROSS;
    }; */

    // The color (do not set the color to preserve the original texture color)
    if (Hlp_IsValidNpc(target)) {
        // The argument 'target' might be empty!

        var int att; att = Npc_GetAttitude(target, hero);
        if (att == ATT_HOSTILE) {
            reticle.color = Focusnames_Color_Hostile();
        };
        /*
        // For now, do not color friendly NPCs green (reticle stays white)
        if (att == ATT_FRIENDLY) {
            reticle.color = Focusnames_Color_Friendly();
        }; */

    } else {
        // If no NPC is in focus color it slightly gray
        reticle.color = RGBA(175, 175, 175, 255);
    };

    // The size (scale between [0, 100]: 0 is smallest, 100 is biggest)
    reticle.size = -dist + 100; // Inverse aim distance: bigger for closer range: 100 for closest, 0 for most distance


    // More sophisticated customization is also possible: change the texture by spellID, the size by spellLevel, ...

    /*
    // Size by spell level for invest spells (e.g. increase size by invest level)
    if (spellLevel < 2) {
        reticle.size = 75;
    } else if (spellLevel >= 2) {
        reticle.size = 100;
    }; */

    /*
    if (isScroll) {
        // Different reticle for scrolls
        reticle.color = RGBA(125, 200, 250, 255); // Light blue
    }; */

    /*
    // Scale size by the amount of mana invested
    reticle.size = manaInvested; // This should be scaled between [0, 100] */

    // For examples for reticle textures based on spellID, see this function in config\reticleBySpellID_G1.d or
    // config\reticleBySpellID_G2.d
    reticle.texture = reticleBySpellID(spellID);
};
