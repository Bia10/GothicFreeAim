/*
 * This file is part of the configuration for critical hits for bows and crossbows (see config\criticalHit.d). The
 * cricital hit zones can be defined for any bone of the character/monster models. To give an example, this file defines
 * head shots. For compatibility reasons between Gothic 1 and Gothic 2 these exemplary definitions are outsourced here
 * and split between Gothic 1 and Gothic 2, since there are different mosters in both games.
 */


/*
 * This function defines the dimensions of head shots for all Gothic 1 specific monsters.
 */
func void headshots(var C_Npc target, var int rtrnPtr) {
    // Get weak spot instance from call-by-reference argument
    var Weakspot weakspot; weakspot = _^(rtrnPtr);

    // In case this helps with differentiating:
    var zCPar_Symbol sym; sym = _^(MEM_GetSymbolByIndex(Hlp_GetInstanceID(target)));
    var string instName; instName = sym.name; // Exact instance name, e.g. "ORCWARRIOR_LOBART1"

    // Here, set the head to the default weak spot
    weakspot.node = "Bip01 Head"; // Upper/lower case is not important, but spelling and spaces are

    // Here, there are preliminary definitions for nearly all Gothic 1 creatures for headshots
    if (target.guild < GIL_SEPERATOR_HUM)
    || ((target.guild > GIL_SEPERATOR_ORC) && (target.guild <= GIL_ORCSLAVE))
    || ((target.guild == GIL_UNDEADORC) && (target.aivar[AIV_MM_REAL_ID] != ID_UNDEADORCWARRIOR)) // Has no head visual!
    || (target.guild == GIL_ZOMBIE) {
        // Here is also room for story-dependent exceptions (e.g. a specific NPC may have a different weak spot)

        weakspot.dimX = -1; // Retrieve the dimensions automatically from model. This works only on humanoids AND only
        weakspot.dimY = -1; // for head node! All other creatures need actual hard coded bounding box dimensions

    } else if (target.guild == GIL_BLOODFLY) // Bloodflys and meatbugs don't have a head node
    || (target.guild == GIL_MEATBUG)
    || (target.guild == GIL_GOLEM) // Golems have too large heads (head node is not centered)
    || (target.guild == GIL_SKELETON) { // Skeletons are only bones, there is no critical hit
        // Disable critical hits this way
        weakspot.node = "";
        weakspot.debugInfo = ConcatStrings(instName, " does not have a weak spot by design");

    } else if (target.aivar[AIV_MM_REAL_ID] == ID_UNDEADORCWARRIOR) {
        // Model has no separate head visual, that is why it is not up there with the other orcs for auto detection
        weakspot.dimX = 45;
        weakspot.dimY = 55;
    } else if (target.aivar[AIV_MM_REAL_ID] == ID_BLOODHOUND) {
        weakspot.dimX = 55;
        weakspot.dimY = 50;
    } else if (target.aivar[AIV_MM_REAL_ID] == ID_ORCBITER) {
        weakspot.dimX = 45;
        weakspot.dimY = 40;
    } else if (target.aivar[AIV_MM_REAL_ID] == ID_RAZOR) {
        weakspot.dimX = 40;
        weakspot.dimY = 40;
    } else if (target.aivar[AIV_MM_REAL_ID] == ID_SNAPPER) {
        weakspot.dimX = 40;
        weakspot.dimY = 35;
    } else if (target.aivar[AIV_MM_REAL_ID] == ID_TROLL) {
        weakspot.dimX = 90;
        weakspot.dimY = 100;
    } else if (target.aivar[AIV_MM_REAL_ID] == ID_HARPIE) {
        weakspot.dimX = 25;
        weakspot.dimY = 25;
    } else if (target.guild == GIL_SWAMPSHARK) {
        // Harder to hit
        weakspot.node = "ZS_MOUTH";
        weakspot.dimX = 30;
        weakspot.dimY = 30;
    } else if (target.guild == GIL_GOBBO) {
        weakspot.dimX = 25;
        weakspot.dimY = 25;
    } else if (target.guild == GIL_DEMON) {
        // Both demon and demon lord
        weakspot.dimX = 35;
        weakspot.dimY = 40;
    } else if (target.guild == GIL_WARAN) {
        weakspot.dimX = 50;
        weakspot.dimY = 50;
    } else if (target.guild == GIL_LURKER) {
        weakspot.dimX = 30;
        weakspot.dimY = 30;
    } else if (target.guild == GIL_MINECRAWLER) {
        weakspot.dimX = 50;
        weakspot.dimY = 50;
    } else if (target.guild == GIL_MOLERAT) {
        weakspot.dimX = 35;
        weakspot.dimY = 30;
    } else if (target.guild == GIL_SCAVENGER) {
        weakspot.dimX = 35;
        weakspot.dimY = 40;
    } else if (target.guild == GIL_SHADOWBEAST) {
        weakspot.dimX = 60;
        weakspot.dimY = 60;
    } else if (target.guild == GIL_WOLF) {
        weakspot.dimX = 25;
        weakspot.dimY = 40;

    } else {
        // Default size for any non-listed monster
        weakspot.dimX = 50; // 50x50cm size
        weakspot.dimY = 50;
        weakspot.debugInfo = ConcatStrings(instName, " has no weak spot definition, assumed default head dimensions");
    };
};
