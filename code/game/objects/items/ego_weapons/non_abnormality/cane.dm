//Like this so we can add a charge mechanic to one of them and have it carry down.
//All of these weapons are grade 4.
/obj/item/ego_weapon/city/cane
	name = "cane office template"
	desc = "This is a template and should not be seen."
	force = 18
	damtype = WHITE_DAMAGE
	armortype = WHITE_DAMAGE
	attack_verb_continuous = list("bashes", "crushes")
	attack_verb_simple = list("bash", "crush")
	var/release_message = "You release your charge, damaging your opponent!"
	var/charge_effect = "deal an extra attack in damage."
	var/charge_cost = 2
	var/charge
	var/activated
	attribute_requirements = list(
							FORTITUDE_ATTRIBUTE = 80,
							PRUDENCE_ATTRIBUTE = 100,
							TEMPERANCE_ATTRIBUTE = 60,
							JUSTICE_ATTRIBUTE = 80
							)

/obj/item/ego_weapon/city/cane/attack_self(mob/user)
	..()
	if(charge>=charge_cost)
		charge -= charge_cost
		release_charge(user)
	else
		to_chat(user, "<span class='notice'>You don't have enough charge.</span>")

/obj/item/ego_weapon/city/cane/examine(mob/user)
	. = ..()
	. += "Spend [charge]/[charge_cost] charge to [charge_effect]"

/obj/item/ego_weapon/city/cane/attack(mob/living/target, mob/living/user)
	..()
	if(charge<20 && target.stat != DEAD)
		charge+=1

/obj/item/ego_weapon/city/cane/proc/release_charge(mob/living/user)
	to_chat(user, "<span class='notice'>[release_message].</span>")
	sleep(2)
	playsound(src, 'sound/abnormalities/thunderbird/tbird_bolt.ogg', 50, TRUE)
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/justitia_effect(T)


//Actual weapons
/obj/item/ego_weapon/city/cane/cane
	name = "cane office - cane"
	desc = "A white cane that holds electricity."
	icon_state = "cane_cane"
	inhand_icon_state = "cane_cane"
	force = 50
	attack_verb_continuous = list("bashes", "crushes")
	attack_verb_simple = list("bash", "crush")
	release_message = "You release your charge, healing yourself!"
	charge_effect = "heal yourself."
	charge_cost = 8

/obj/item/ego_weapon/city/cane/cane/release_charge(mob/living/carbon/human/user)
	..()
	user.adjustBruteLoss(-user.maxHealth*0.07)
	user.adjustSanityLoss(-user.maxSanity*0.07)
	addtimer(CALLBACK(src, .proc/Return, user), 5 SECONDS)

/obj/item/ego_weapon/city/cane/cane/proc/Return(mob/living/carbon/human/user)
	to_chat(user, "<span class='notice'>You heal once more.</span>")
	user.adjustBruteLoss(-user.maxHealth*0.07)
	user.adjustSanityLoss(-user.maxSanity*0.07)
	playsound(src, 'sound/abnormalities/thunderbird/tbird_bolt.ogg', 50, TRUE)
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/justitia_effect(T)



/obj/item/ego_weapon/city/cane/claw
	name = "cane office - claw"
	desc = "A white claw seen in use by the cane office."
	icon_state = "cane_claw"
	inhand_icon_state = "cane_claw"
	force = 20
	attack_speed = 0.3
	attack_verb_continuous = list("cuts", "slices")
	attack_verb_simple = list("cut", "slice")
	release_message = "You release your charge, boosting forwards!"
	charge_effect = "dash a short distance."
	charge_cost = 3
	var/dodgelanding

/obj/item/ego_weapon/city/cane/claw/release_charge(mob/living/user)
	..()
	if(user.dir == NORTH)
		dodgelanding = locate(user.x, user.y + 5, user.z)
	if(user.dir == SOUTH)
		dodgelanding = locate(user.x, user.y - 5, user.z)
	if(user.dir == EAST)
		dodgelanding = locate(user.x + 5, user.y, user.z)
	if(user.dir == WEST)
		dodgelanding = locate(user.x - 5, user.y, user.z)
	user.throw_at(dodgelanding, 3, 2, spin = FALSE)


/obj/item/ego_weapon/city/cane/fist
	name = "cane office - gauntlet"
	desc = "A gauntlet seen in use by the cane office."
	icon_state = "cane_gauntlet"
	inhand_icon_state = "cane_gauntlet"
	force = 50
	attack_verb_continuous = list("smashes", "bashes")
	attack_verb_simple = list("smash", "bash")
	release_message = "You release your energy, powering your gauntlet!"
	charge_effect = "boost this weapon's attack."
	charge_cost = 8

/obj/item/ego_weapon/city/cane/fist/release_charge(mob/living/carbon/human/user)
	..()
	force = force*2
	addtimer(CALLBACK(src, .proc/Return, user), 2 SECONDS)

/obj/item/ego_weapon/city/cane/fist/proc/Return(mob/living/user)
	force = initial(force)

/obj/item/ego_weapon/city/cane/briefcase
	name = "cane office - briefcase"
	desc = "A briefcase seen in use by the cane office."
	icon_state = "cane_briefcase"
	inhand_icon_state = "cane_briefcase"
	force = 30
	attack_verb_continuous = list("smashes", "bashes")
	attack_verb_simple = list("smash", "bash")
	release_message = "You release your energy, knocking everyone nearby backwards!"
	charge_effect = "knock others backwards!"
	charge_cost = 4

/obj/item/ego_weapon/city/cane/briefcase/release_charge(mob/living/user)
	..()
	goonchem_vortex(get_turf(src), 1, 4)

	for(var/turf/T in orange(2, user))
		new /obj/effect/temp_visual/smash_effect(T)

	for(var/mob/living/L in range(2, user))
		if(L == user)
			continue
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(!H.sanity_lost)
				continue
		L.apply_damage(30, WHITE_DAMAGE, null, L.run_armor_check(null, WHITE_DAMAGE), spread_damage = TRUE)

