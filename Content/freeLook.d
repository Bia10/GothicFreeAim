/*
 * Manually rotate the hero
 */

/* Creates or returns the aim vob */
func int getAimVob(var int posPtr) {
    var int vobPtr; vobPtr = MEM_SearchVobByName("AIMVOB");
    if (!vobPtr) {
        vobPtr = MEM_Alloc(sizeof_zCVob);
        const int oCVob__oCVob = 7845536; //0x77B6A0
        CALL__thiscall(vobPtr, oCVob__oCVob);
        MEM_WriteString(vobPtr+16, "AIMVOB"); // _zCObject_objectName
        const int zCWorld__AddVobAsChild = 6440352; //0x6245A0
        CALL_PtrParam(_@(MEM_Vobtree));
        CALL_PtrParam(vobPtr);
        CALL__thiscall(_@(MEM_World), zCWorld__AddVobAsChild);
    };
    // Update aim vob position
    const int zCVob__SetPositionWorld = 6404976; //0x61BB70
    CALL_PtrParam(posPtr);
    CALL__thiscall(vobPtr, zCVob__SetPositionWorld);
    return vobPtr;
};

/* Turn hero (incl. camera if attached) by degrees (in float) */
func void turnHero(var int degreesf) {
    var oCNPC her; her = Hlp_GetNpc(hero);
    const int oCAniCtrl_Human__TurnDegrees = 7006992; //0x6AEB10
    CALL_IntParam(0); // 0 = disable turn animation
    CALL_FloatParam(degreesf);
    CALL__thiscall(her.anictrl, oCAniCtrl_Human__TurnDegrees);
};

/* Check if mouse moved along the x-/y-axis */
func int getMouseMoveDelta(var int xy) { // 0 = x, 1 = y
    var _Cursor c; c = _^(Cursor_Ptr); // As defined in LeGo
    if !xy {
        return mulf(mkf(c.relX), mulf(MEM_ReadInt(Cursor_sX), mkf(2)));
    } else {
        return mulf(mkf(c.relY), mulf(MEM_ReadInt(Cursor_sY), mkf(2)));
    };
};

/* Sine and cosine functions taken from LeGo\Misc.d (not included in Header.src)? */
func int sin(var int angle) {
    const int _sinf = 8123910; //0x7BF606
    const int call = 0;
    var int ret;
    if (Call_Begin(call)) {
        CALL_FloatParam(_@(angle));
        CALL_RetValisFloat();
        CALL_PutRetValTo(_@(ret));
        CALL__cdecl(_sinf);

        call = CALL_End();
    };
    return +ret;
};
func int cos(var int angle) {
    return +sin(subf(1070141312, angle)); //1070141312 = PI/2
};

/* Manually update the rotation of the hero including the camera */
func void updateHeroYrot(var int mod) { // Float multiplier (e.g. FLOATEINS)
    var int xChng; xChng = getMouseMoveDelta(0); // Get the change in x position
    // if (xChng == FLOATNULL) { return; }; // Do not return, because there is also Y aiming
    turnHero(mulf(xChng, mod));
};

/* Hooks oCAniCtrl_Human::InterpolateCombineAni */
func void catchICAni() {
    var int ani; ani = MEM_ReadInt(ESP+12);
    var oCNpc her; her = Hlp_GetNpc(hero);
    if (!Npc_IsInFightMode(her, FMODE_FAR)) { return; };
    const int oCAniCtrl_Human__IsAiming = 7003456; //0x6ADD40
    CALL__thiscall(her.anictrl, oCAniCtrl_Human__IsAiming);
    if (!CALL_RetValAsInt()) { return; };

    MEM_InitGlobalInst(); // This is necessary here to find the camera vob, although it was called in init_global. Why?
    var zCVob cam; cam = _^(MEM_Camera.connectedVob);
    var int pos[6]; // Combined pos[3] + dir[3]
    pos[0] = her._zCVob_trafoObjToWorld[ 3];  pos[3] = mulf(cam.trafoObjToWorld[ 2], mkf(AIM_MAX_DIST));
    pos[1] = her._zCVob_trafoObjToWorld[ 7];  pos[4] = mulf(cam.trafoObjToWorld[ 6], mkf(AIM_MAX_DIST));
    pos[2] = her._zCVob_trafoObjToWorld[11];  pos[5] = mulf(cam.trafoObjToWorld[10], mkf(AIM_MAX_DIST));
    pos[3] = addf(pos[0], pos[3]);
    pos[4] = addf(pos[1], pos[4]);
    pos[5] = addf(pos[2], pos[5]);
    // Translate point back to origin
    pos[3] = subf(pos[3], pos[0]);
    pos[5] = subf(pos[5], pos[2]);
    var int deltaX; deltaX = getMouseMoveDelta(0); // Get mouse change in x
    var int c; c = cos(deltaX);
    var int s; s = sin(deltaX);
    // Rotate point
    var int xNew; xNew = subf(mulf(pos[3], c), mulf(pos[5], s));
    var int yNew; yNew = addf(mulf(pos[3], s), mulf(pos[5], c));
    // Translate point back:
    pos[3] = addf(xNew, pos[0]);
    pos[5] = addf(yNew, pos[2]);

    // A little help is necessary
    const int oCAniCtrl_Human__TurnDegrees = 7006992; //0x6AEB10
    CALL_IntParam(0); // 0 = disable turn animation
    CALL_FloatParam(divf(deltaX, mkf(10)));
    CALL__thiscall(her.anictrl, oCAniCtrl_Human__TurnDegrees);

    // Get aiming angles
    var int angleX; var int angleY;
    const int oCNpc__GetAngles = 6820528; //0x6812B0
    CALL_FloatParam(_@(angleY));
    CALL_FloatParam(_@(angleX));
    CALL_PtrParam(_@(pos)+12);
    CALL__thiscall(_@(her), oCNpc__GetAngles);
    var int deg90To1; deg90To1 = mulf(MEM_ReadInt(8586988), FLOATHALB); //0x8306EC // 0.0111111*0.5, 90 degrees => 0.5
    angleX = mulf(angleX, deg90To1);  // Scale X +-90 degrees to +-0.5
    angleX = addf(angleX, FLOATHALB); // Shift X +-0.5 to +-1
    angleY = mulf(angleY, deg90To1);  // Scale Y +-90 degrees to +-0.5
    angleY = addf(angleY, FLOATHALB); // Shift Y +-0.5 to +-1
    angleY = subf(FLOATEINS, angleY); // Inv   Y +-1 to -+1
    if (lef(angleX, FLOATNULL)) {
        angleX = FLOATNULL; // Maximum aim turn
    } else if (gef(angleX, 1065353216)) {
        angleX = 1065353216; //3F800000 // Minimum aim turn
    };
    if (lef(angleY, FLOATNULL)) {
        angleY = FLOATNULL; // Maximum aim height (straight up)
    } else if (gef(angleY, 1065353216)) {
        angleY = 1065353216; //3F800000 // Minimum aim height (down)
    };
    // New aiming coordinates
    MEM_WriteInt(ESP+4, angleX);
    MEM_WriteInt(ESP+8, angleY);
};

const int AIM_MAX_DIST    = 10000; // 100 meters. Enough?
const int AIM_OBJ_OFFSET  = 150;   // Cm to shift behind intersection
func void ShootTarget() {
    // Set trace ray (start from shooter and go along the outvector of the camera vob)
    MEM_InitGlobalInst(); // This is necessary here to find the camera vob, although it was called in init_global. Why?
    var zCVob cam; cam = _^(MEM_Camera.connectedVob);
    var zCVob her; her = Hlp_GetNpc(hero);
    var int pos[6]; // Combined pos[3] + dir[3]
    pos[0] = her.trafoObjToWorld[ 3];  pos[3] = mulf(cam.trafoObjToWorld[ 2], mkf(AIM_MAX_DIST));
    pos[1] = her.trafoObjToWorld[ 7];  pos[4] = mulf(cam.trafoObjToWorld[ 6], mkf(AIM_MAX_DIST));
    pos[2] = her.trafoObjToWorld[11];  pos[5] = mulf(cam.trafoObjToWorld[10], mkf(AIM_MAX_DIST));
    // Shoot trace ray
    if (TraceRay(_@(pos), _@(pos)+12, // From shooter to max distance
            (zTRACERAY_VOB_IGNORE_NO_CD_DYN
                | zTRACERAY_POLY_TEST_WATER
                | zTRACERAY_POLY_IGNORE_TRANSP
                | zTRACERAY_VOB_IGNORE_PROJECTILES))) {
        // Set new position to intersection (point where the trace ray made contact with a polygon)
        pos[0] = addf(MEM_World.foundIntersection[0], mulf(cam.trafoObjToWorld[ 2], mkf(AIM_OBJ_OFFSET)));
        pos[1] = addf(MEM_World.foundIntersection[1], mulf(cam.trafoObjToWorld[ 6], mkf(AIM_OBJ_OFFSET)));
        pos[2] = addf(MEM_World.foundIntersection[2], mulf(cam.trafoObjToWorld[10], mkf(AIM_OBJ_OFFSET)));
    } else {
        // If nothing is in the way, set new position to max distance
        pos[0] = addf(pos[0], pos[3]);
        pos[1] = addf(pos[1], pos[4]);
        pos[2] = addf(pos[2], pos[5]);
    };
    MEM_WriteInt(ESP+12, getAimVob(_@(pos)));
};

/*
 * Free "look" (hook framework).
 * This is not free aiming: Nothing regarding Y-Axis aiming is done here!
 * E.g. arrows will be shot according to the rotation, but still parallel to the ground irrespective of the up angle.
 */
var int crosshairHndl; // Hold the crosshair handle
var int aimModifier; // Modifies the mouse movement speed

/* Delete crosshair (hiding it is not sufficient, since it might change texture later) */
func void removeCrosshair_() {
    if (Hlp_IsValidHandle(crosshairHndl)) { View_Delete(crosshairHndl); };
};

/* "Light" version of removeCrosshair_ (hook into oCNpcFocus::SetFocusMode) */
func void removeCrosshair() {
    if (Npc_IsInFightMode(hero, FMODE_FAR)) || (Npc_IsInFightMode(hero, FMODE_MAGIC)) { return; };
    aimModifier = FLOATEINS; // Reset multiplier
    removeCrosshair_();
};

/* Function maintaining free look and crosshair  */
func void hookFreeLook(var int crosshairStyle) {
    // Only apply manual rotation when action button is held
    if (!MEM_KeyPressed(MEM_GetKey("keyAction")))
    && (!MEM_KeyPressed(MEM_GetSecondaryKey("keyAction"))) {
        removeCrosshair_();
        return;
    };
    // Set fancy crosshair
    if (crosshairStyle > 1) {
        if (!Hlp_IsValidHandle(crosshairHndl)) {
            Print_GetScreenSize();
            var int posX; posX = Print_Screen[PS_X] / 2;
            var int posY; posY = Print_Screen[PS_Y] / 2;
            crosshairHndl = View_CreatePxl(posX-32, posY-32, posX+32, posY+32);
            var String crosshairTex; crosshairTex = MEM_ReadStatStringArr(crosshair, crosshairStyle);
            View_SetTexture(crosshairHndl, crosshairTex);
            View_Open(crosshairHndl);
        } else {
            var zCView crsHr; crsHr = _^(getPtr(crosshairHndl));
            if (!crsHr.isOpen) { View_Open(crosshairHndl); };
        };
    } else { removeCrosshair_(); };
    // Manually enable rotation around y-axis
    if (!aimModifier) { aimModifier = FLOATEINS; };
    var int frameAdj; frameAdj = divf(MEM_Timer.frameTimeFloat, mkf(10)); // It adjusts speed to fps (~= frame lock)
    updateHeroYrot(aimModifier);
};

/* Hook function when ranged weapon is drawn (hook into oCAIHuman::BowMode) */
func void hookFreeLook_ranged() {
    Focus_Ranged.npc_prio = -1; // Disable focus collection
    aimModifier = FLOATEINS; // TODO: Adjust aimModifier like in Spell_Blink.d: slower in distance, faster in proximity
    hookFreeLook(NORMAL_CROSSHAIR);
};

/* Hook function when spell is drawn (hook into oCAIHuman::MagicMode) */
func void hookFreeLook_magic() {
    // Get spell-specific crosshair (Constants.d)
    var int activeSpell; activeSpell = Npc_GetActiveSpell(hero);
    if (!MEM_ReadStatArr(spellTurnable, activeSpell)) {
        removeCrosshair_();
        return;
    };
    hookFreeLook(MEM_ReadStatArr(spellTurnable, activeSpell));
};


// void __thiscall zCVob::RotateLocal(zVEC3 const & float) 0x0061B610
