Scriptname sr_infDeflateAbility extends ReferenceAlias

import StorageUtil

sr_inflateConfig Property config auto
sr_inflateQuest Property inflater auto
Quest Property sr_inflateExternalEventManager Auto
bool keydown = false
bool bAnimController

Globalvariable Property sr_OnEventNoDeflation Auto
Globalvariable Property sr_ExpelFaliure Auto
Globalvariable Property sr_OnEventAbsorbSperm Auto
Globalvariable Property sr_Cumvariationingredients Auto

Ingredient Property FHUVomitCum Auto
Ingredient Property FHUHumanCum Auto
Ingredient Property FHUBeastCum Auto
Ingredient Property FHURottenCum Auto
Ingredient Property FHUSpiderEgg Auto
Ingredient Property FHUChaurusEggs Auto
Ingredient Property FHUAshHopperEggs Auto
Ingredient Property FHULarvae Auto
Ingredient Property FHUSlug Auto
Ingredient Property VoidSalts Auto
Ingredient Property SprigganSap Auto
Ingredient Property DLC2AshHopperJelly Auto

soulgem property SoulGemBlack auto
formlist property sr_InjectorFormlist auto

Event OnPlayerLoadGame()
	Maintenance()
EndEvent

Function Maintenance()
	UnregisterForAllKeys()
	If config.defKey >= 0
		RegisterForKey(config.defKey)
	EndIf
	inflater.BaboAnimsSet()
	(sr_inflateExternalEventManager as sr_inflateExternalEventController).RegisterModEvent()
EndFunction

Event OnKeyDown(int kc)
	If kc == config.defKey
		keydown = true
		Utility.Wait(0.4)
		If keydown
			Actor p = GetActorReference()
			
			If p.IsInFaction(inflater.inflaterAnimatingFaction)
				log("Already animating!")
				return
			EndIf
			
			If p.GetActorValuePercentage("Stamina") >= 0.3
				SendModEvent("dhlp-Suspend")
				int type = inflater.GetMostRecentInflationType(p);Important
				int err = 0
				log("Type: " + type)
				If type > 0 && type < 3
					int plugged = inflater.isPlugged(p)
					log("Plugged: " + plugged)
					If plugged < 3
						If type == plugged ; one plug and it's blocking
							If type == 1 ; determine which message to show
								err = 1;vaginal
							Else
								err = 2;anal
							EndIf
						EndIf
						
						If err == 1 && inflater.GetAnalCum(p) > 0	&& plugged != 2; switch pools if possible and clear the error
							type = 2
							err = 0
							log("Vaginal plug, switching to anal deflation")
						ElseIf err == 2 && inflater.GetVaginalCum(p) > 0 && plugged != 1
							type = 1
							err = 0
							log("Anal plug, switching to vaginal deflation")
						EndIf						
					Else
						err = 3 ; both plugs
					EndIf
				elseif type == 3; WIP
				;When it crosses the capacity limit, you vomit. If not, you feel like vomiting but vomit nothing.
					err = 0
				Else
					return ; no cum
				EndIf
				
				p.DamageActorValue("Stamina", ((p.GetActorValue("Stamina") / p.GetActorValuePercentage("Stamina")) * 0.4))				
				If p.HasSpell(inflater.sr_inflateBurstSpell)
					err = 5
					log("Bursting, can't deflate")
				EndIf
				
				If (Utility.RandomInt(0, 99) < sr_ExpelFaliure.getvalue() as int) && err == 0
					If type > 0 && type < 3
						err = 4
					elseif type == 3
						err = 6
					endif
				;	log("RandomErrorNotEnoughRandom")
				EndIf
				
				If err == 0
				;	log("Pushing: " + type)
					doPush(type)
				ElseIf err == 1
					inflater.notify("$FHU_DEF_BLOCK_V")
					inflater.DeflateFailMotion(p, 1)
				ElseIf err == 2
					inflater.notify("$FHU_DEF_BLOCK_A")
					inflater.DeflateFailMotion(p, 2)
				ElseIf err == 3
					inflater.notify("$FHU_DEF_BLOCK")
					inflater.DeflateFailMotion(p, 1)
				ElseIf err == 4
					inflater.notify("$FHU_DEF_FAIL")
					inflater.DeflateFailMotion(p, 1)
				ElseIf err == 5
					inflater.notify("$FHU_DEF_BURST_FAIL")
					inflater.DeflateFailMotion(p, 1)
				ElseIf err == 6
					inflater.notify("$FHU_DEF_ORAL_FAIL");Anal to Oral WIP
					inflater.DeflateFailMotion(p, 3)
				EndIf
				SendModEvent("dhlp-Resume")
			Else
				inflater.notify("$FHU_DEF_FIZZLE")
			EndIf		
		endIf 
	endIf
EndEvent

Event OnKeyUp(int kc, float time)
	if kc == config.defkey
		keydown = false
		inflater.EquiprandomTongue(GetActorReference(), false)
		MfgConsoleFunc.ResetPhonemeModifier(GetActorReference())
	endIf
EndEvent

Function doPushDeflate(String pool, Actor p, float currentInf)
	If currentInf <= 0
		currentInf = 0
	EndIf
	if config.BodyMorph && (pool == inflater.CUM_VAGINAL || pool == inflater.CUM_ANAL)
		;inflater.SetBellyMorphValue(p, currentInf, "PregnancyBelly")
		inflater.SetBellyMorphValue(p, currentInf, inflater.InflateMorph)
		if inflater.InflateMorph2 != ""
			inflater.SetBellyMorphValue(p, currentInf, inflater.InflateMorph2)
		endIf
		if inflater.InflateMorph3 != ""
			inflater.SetBellyMorphValue(p, currentInf, inflater.InflateMorph3)
		endif
	elseif config.BodyMorph && pool == inflater.CUM_ORAL
		if inflater.InflateMorph4 != ""
			inflater.SetBellyMorphValue(p, currentInf, inflater.InflateMorph4)
		endif
	else
		inflater.SetNodeScale(p, "NPC Belly", currentInf)
	endif
EndFunction

bool updateFHU = false
int updateCumType
int updateSpermType
Event OnUpdate()
	if inflater.UpdateFHUmoan(GetReference(), updateCumType, updateSpermType)
		RegisterForSingleUpdate(10.0)
	Else
		updateCumType = 0
		updateSpermType = 0
		updateFHU = false
	EndIf
EndEvent

Function RegisterFHUUpdate(int CumType, int SpermType)
	updateCumType = CumType
	updateFHU = true
	updateSpermType = SpermType
	RegisterForSingleUpdate(10.0)
EndFunction

Function doPush(int type)
	log("doPush")
	Actor p = GetActorReference()
	Game.DisablePlayerControls()
	Game.ForceThirdPerson()
	
	p.AddToFaction(inflater.inflaterAnimatingFaction)
	p.SetFactionRank(inflater.inflaterAnimatingFaction, 1)
	
	String pool = ""
	If type == 1
		pool = inflater.CUM_VAGINAL
	elseif type == 2
		pool = inflater.CUM_ANAL
	else
		pool = inflater.CUM_ORAL
	EndIf
	int spermtype = inflater.GetSpermLastActor(p)
	inflater.StartLeakage(p, type, 1, spermtype)
	RegisterFHUUpdate(type, spermtype)
	float dps = ((p.GetActorValue("Stamina") / p.GetActorValuePercentage("Stamina")) * 0.01)
	float currentInf
	float cum

	float vagCum = GetFloatValue(p, inflater.CUM_VAGINAL)
	float analCum = GetFloatValue(p, inflater.CUM_ANAL)
	float oralCum = GetFloatValue(p, inflater.CUM_ORAL)
	
	if type == 1
		currentInf = inflater.GetInflation(p)
		cum = vagCum
		log("doPush Vaginal = "+vagCum)
	elseif type == 2
		currentInf = inflater.GetInflation(p)
		cum = analCum
		log("doPush Anal = "+analCum)
	elseif type == 3
		currentInf = inflater.GetOralCum(p)
		cum = oralCum
		log("doPush Oral = "+oralCum)
	endif

	float originalCum = cum
	float originalInf = currentInf
	float deflationTick = inflater.config.BodyMorphApplyPeriod
	float tick = deflationTick
;	log("Starting: inf: " + currentInf +", cum: " +cum + ", pool: " + pool)
	While keydown && p.GetActorValuePercentage("Stamina") > 0.02 && cum > 0.02
		float deflateAmount = 0.05 * (1.0 / inflater.config.animMult)
		If deflateAmount > cum
			deflateAmount = cum
		EndIf
		currentInf -= 0.05*(1.0/inflater.config.animMult)
		cum -= 0.05*(1.0/inflater.config.animMult)
		tick -= 0.3
		if(tick <= 0) ;Prevents serious FPS drop due to heavy code stacks.
			doPushDeflate(pool, p, currentInf)
			tick = deflationTick
		EndIf
	;	log("current: inf: " + currentInf +", cum: " +cum)
		p.DamageActorValue("Stamina", dps)
		Utility.wait(0.3)
	endWhile

	If cum <= 0.02
		cum = 0.0
	EndIf
	
	; try to get around some rounding errors and match the values
	float diff = originalCum - cum
	currentInf = originalInf - diff
	
	log("Final cum: "+cum+", cum diff from original: " + diff + ", final inflation: " + currentInf)

	if type == 1
		vagCum = cum
		if vagCum < 0.1
			vagCum = 0.0
			UnsetFloatValue(p, inflater.LAST_TIME_VAG)
			UnsetFloatValue(p, inflater.CUM_VAGINAL)
			sr_InjectorFormlist.revert()
		Else
			SetFloatValue(p, inflater.CUM_VAGINAL, vagCum)
		EndIf
	Elseif type == 2
		analCum = cum
		if analCum < 0.1
			analCum = 0.0
			UnsetFloatValue(p, inflater.LAST_TIME_ANAL)
			UnsetFloatValue(p, inflater.CUM_ANAL)
		Else
			SetFloatValue(p, inflater.CUM_ANAL, analCum)
		EndIf
	elseif type == 3
		oralCum = cum
		if oralCum < 0.1
			oralCum = 0.0
			UnsetFloatValue(p, inflater.LAST_TIME_ORAL)
			UnsetFloatValue(p, inflater.CUM_ORAL)
		Else
			SetFloatValue(p, inflater.CUM_ORAL, oralCum)
		EndIf
	EndIf

	If type < 3
		if ( analCum <= 0.0 && vagCum <= 0.0 )
			UnsetFloatValue(p, inflater.INFLATION_AMOUNT)
		else
			currentInf = analCum + vagCum
			SetFloatValue(p, inflater.INFLATION_AMOUNT, currentInf)
		endif
	EndIf

	log("Cum amounts after doPush, v: "+ vagCum +", a: "+ analCum +", t: "+ (analCum+vagCum) + ", o: " + oralCum)

	doPushDeflate(pool, p, currentInf)
	
	Utility.Wait(0.1)
	inflater.StopLeakage(p, type, spermtype)
	inflater.UpdateFaction(p)
	inflater.UpdateOralFaction(p)
	inflater.SendPlayerCumUpdate(cum, type == 2)
	Game.EnablePlayerControls()
	p.RemoveFromFaction(inflater.inflaterAnimatingFaction)
	inflater.EncumberActor(p) ; Has a 2s wait in it, do it after returning controls to keep it responsive
	int cumcompare = Math.Ceiling(diff)
	
	if sr_Cumvariationingredients.getvalue() == 1 && cumcompare > 0
		if type < 3
			if spermtype == 0;human
				p.additem(FHUHumanCum, cumcompare)
			elseif spermtype == 1;beast
				p.additem(FHUBeastCum, cumcompare)
			elseif spermtype == 2;Draugr
				p.additem(FHURottenCum, cumcompare)
			elseif spermtype == 3;spider
				p.additem(FHUSpiderEgg, cumcompare)
			elseif spermtype == 4;chaurus
				if originalCum > 3.0
					p.additem(FHULarvae, 1)
				endif
				p.additem(FHUChaurusEggs, cumcompare)
			elseif spermtype == 5;spriggan
				p.additem(SprigganSap, cumcompare)
				if originalCum > 3.0
					p.additem(FHUSlug, 1)
				endif
			elseif spermtype == 6;Stone
				p.additem(VoidSalts, cumcompare)
				if originalCum > 3.0
					p.additem(SoulGemBlack, 1)
				endif
			elseif spermtype == 7;Ashhopper
				p.additem(DLC2AshHopperJelly, cumcompare)
				if originalCum > 3.0
					p.additem(FHUAshHopperEggs, 2)
				endif
			else
				p.additem(FHUHumanCum, cumcompare)
			endif
		elseif type == 3
			p.additem(FHUVomitCum, cumcompare)
		endif
	endif

	if analCum <= 0.0 && vagCum <= 0.0 && OralCum <= 0.0
		StorageUtil.FormListRemove(inflater, inflater.INFLATED_ACTORS, p, true)
		inflater.RemoveFaction(p)
		inflater.UnencumberActor(p)
		inflater.sr_plugged.setValueInt(0)
	endif
	
EndFunction

Function log(String msg)
	inflater.log("[DefAbility]: " + msg)
EndFunction
