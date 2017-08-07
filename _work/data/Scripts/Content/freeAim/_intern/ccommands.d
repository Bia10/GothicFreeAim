/*
 * Definition of all console commands
 *
 * G2 Free Aim v1.0.0-alpha - Free aiming for the video games Gothic 1 and Gothic 2 by Piranha Bytes
 * Copyright (C) 2016-2017  mud-freak (@szapp)
 *
 * This file is part of G2 Free Aim.
 * <http://github.com/szapp/g2freeAim>
 *
 * G2 Free Aim is free software: you can redistribute it and/or modify
 * it under the terms of the MIT License.
 * On redistribution this notice must remain intact and all copies must
 * identify the original author.
 *
 * G2 Free Aim is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * MIT License for more details.
 *
 * You should have received a copy of the MIT License
 * along with G2 Free Aim.  If not, see <http://opensource.org/licenses/MIT>.
 */


/*
 * Console function to enable/disable weak spot debug output. This function is registered as console command.
 * When enabled, the trajectory of the projectile and the defined weak spot of the last shot NPC is visualized with
 * bounding boxes and lines.
 */
func string freeAimDebugWeakspot(var string command) {
    GFA_DEBUG_WEAKSPOT = !GFA_DEBUG_WEAKSPOT;
    if (GFA_DEBUG_WEAKSPOT) {
        return "Debug weak spot on.";
    } else {
        return "Debug weak spot off.";
    };
};


/*
 * Console function to enable/disable trace ray debug output. This function is registered as console command.
 * When enabled, the trace ray is continuously drawn, as well as the intersection of it.
 */
func string freeAimDebugTraceRay(var string command) {
    GFA_DEBUG_TRACERAY = !GFA_DEBUG_TRACERAY;
    if (GFA_DEBUG_TRACERAY) {
        return "Debug trace ray on.";
    } else {
        return "Debug trace ray off.";
    };
};


/*
 * Console function to show freeAim version. This function is registered as console command.
 * When entered in the console, the current g2freeAim version is displayed as the console output.
 */
func string freeAimVersion(var string command) {
    return GFA_VERSION;
};


/*
 * Console function to show freeAim license. This function is registered as console command.
 * When entered in the console, the g2freeAim license information is displayed as the console output.
 */
func string freeAimLicense(var string command) {
    var int s; s = SB_New();
    SB(GFA_VERSION);
    SB(", Copyright ");
    SBc(169 /* (C) */);
    SB(" 2016-2017  mud-freak (@szapp)");
    SBc(13); SBc(10);

    SB("<http://github.com/szapp/g2freeAim>");
    SBc(13); SBc(10);

    SB("Released under the MIT License.");
    SBc(13); SBc(10);

    SB("For more details see <http://opensource.org/licenses/MIT>.");
    SBc(13); SBc(10);

    var string ret; ret = SB_ToString();
    SB_Destroy();

    return ret;
};


/*
 * Console function to show freeAim info. This function is registered as console command.
 * When entered in the console, the g2freeAim config is displayed as the console output.
 */
func string freeAimInfo(var string command) {
    const string onOff[2] = {"OFF", "ON"};

    var int s; s = SB_New();
    SB(GFA_VERSION);
    SBc(13); SBc(10);

    SB("Free aiming: ");
    SB(MEM_ReadStatStringArr(onOff, GFA_ACTIVE));
    if (GFA_ACTIVE) {
        SB(" for");
        if (GFA_RANGED) {
            SB(" (ranged)");
        };
        if (GFA_SPELLS) {
            SB(" (spells)");
        };

        SB(". Focus update every ");
        SBi(GFA_AimRayInterval);
        SB(" ms");
    };
    SBc(13); SBc(10);

    SB("Reusable projectiles: ");
    SB(MEM_ReadStatStringArr(onOff, GFA_REUSE_PROJECTILES));
    SBc(13); SBc(10);

    SB("Custom collision behaviors: ");
    SB(MEM_ReadStatStringArr(onOff, GFA_CUSTOM_COLLISIONS));
    SBc(13); SBc(10);

    SB("Criticial hit detection: ");
    SB(MEM_ReadStatStringArr(onOff, GFA_CRITICALHITS));
    SBc(13); SBc(10);

    var string ret; ret = SB_ToString();
    SB_Destroy();

    return ret;
};
