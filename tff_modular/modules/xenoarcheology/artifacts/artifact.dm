#define DIG_UNDEFINED 	1
#define DIG_DELETE 		2
#define DIG_ROCK		3

#define BRUSH_DELETE	1
#define BRUSH_UNCOVER	2
#define BRUSH_NONE		3
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Large finds - (Potentially) active alien machinery from the dawn of time
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TO DO LIST:
// * Consider about adding constructshell back
// * Do something about hoverpod, its quite useless now. Maybe get a chance to find a space pod
// * Consider adding more big artifacts
// * Add more effects from /vg/
//

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Boulders - sometimes turn up after excavating turf - excavate further to try and find large xenoarch finds

/obj/structure/boulder
	name = "rocky debris"
	desc = "Leftover rock from an excavation, it's been partially dug out already but there's still a lot to go."
	icon = 'tff_modular/modules/xenoarcheology/icons/mining.dmi'
	icon_state = "boulder1"
	density = TRUE
	opacity = 1
	anchored = TRUE
	var/measured = FALSE
	var/holomark = FALSE
	var/holomark_adv = FALSE
	var/stabilised = FALSE
	var/excavation_level = 0
	var/target_excavation_level = 0
	var/approximate_excavation_level = 0
	var/artifact_find_type
	var/artifact_id
	var/artifact_stabilizing_field
	var/artifact_age

/obj/structure/boulder/examine(mob/user)
	. = ..()
	. += span_notice("[holomark ? "This boulder has been scanned. Target Depth: [approximate_excavation_level] +- 15 cm." : "This boulder has not been scanned."]")
	if(holomark_adv)
		. += span_notice("The item depth is [target_excavation_level] cm.")
	. += span_notice("[measured ? "This boulder has been measured. Dug Depth: [excavation_level]." : "This boulder has not been measured."]")

/obj/structure/boulder/Initialize(mapload)
	. = ..()
	artifact_age = rand(1000,9000000000)
	icon_state = "boulder[rand(1, 4)]"
	target_excavation_level = rand(25, 200)
	approximate_excavation_level = target_excavation_level - (rand(-15,15))
	artifact_find_type = pick_weight(list(
	/obj/machinery/power/supermatter_crystal/shard = 5,
	/obj/vehicle/sealed/mecha/reticence/loaded = 50,
	/obj/machinery/artifact/bluespace_crystal = 100,
	/obj/machinery/power/crystal = 100,
	/obj/machinery/auto_cloner = 100,
	/obj/machinery/replicator = 100,
	/obj/machinery/artifact = 1000
	))
	artifact_stabilizing_field = pick(list(
	"Diffracted carbon dioxide laser",
	"Nitrogen tracer field",
	"Potassium refrigerant cloud",
	"Mercury dispersion wave",
	"Iron wafer conduction field",
	"Calcium binary deoxidiser",
	"Chlorine diffusion emissions",
	"Phoron saturated field"))
	artifact_id = "[pick("kappa","sigma","antaeres","beta","omicron","iota","epsilon","omega","gamma","delta","tau","alpha","fluffy","zeta")]-[rand(0,9999)]"

/obj/structure/boulder/proc/spawn_artifact()
	var/obj/machinery/artifact/new_artifact = new artifact_find_type(get_turf(src))
	if (!stabilised)
		if (prob(50))
			new_artifact.update_integrity(10) // It is on the edge of destruction
		else
			new_artifact.Destroy()

/obj/structure/boulder/Destroy() // spawns and destroys artifact immideately
	. = ..()
	if (!stabilised)
		var/obj/machinery/artifact/new_artifact = new artifact_find_type(get_turf(src))
		new_artifact.Destroy()

/obj/structure/boulder/Bumped(who_moved)
	. = ..()
	if(ishuman(who_moved))
		var/mob/living/carbon/human/Human = who_moved
		var/obj/item/offered_item = Human.get_active_held_item()
		if(istype(offered_item, /obj/item/xenoarch/hammer))
			attackby(offered_item, Human)

	else if(iscyborg(who_moved))
		var/mob/living/silicon/robot/Robot = who_moved
		if(istype(Robot.module_active, /obj/item/xenoarch/hammer))
			attackby(Robot.module_active, Robot)

/obj/structure/boulder/proc/get_scanned(advanced)
	if (advanced)
		holomark_adv = TRUE
	holomark = TRUE
	return TRUE

/obj/structure/boulder/proc/get_stabilised()
	if (stabilised)
		return FALSE
	else
		stabilised = TRUE
		return TRUE

/obj/structure/boulder/proc/get_measured()
	if (measured)
		return FALSE
	else
		measured = TRUE
		return TRUE

/obj/structure/boulder/proc/try_dig(dig_amount)
	if(!dig_amount)
		return DIG_UNDEFINED
	excavation_level += dig_amount
	if(excavation_level > target_excavation_level)
		qdel(src)
		return DIG_DELETE
	return DIG_ROCK

/obj/structure/boulder/proc/try_uncover()
	if(excavation_level > target_excavation_level)
		qdel(src)
		return BRUSH_DELETE
	if(excavation_level == target_excavation_level)
		spawn_artifact()
		qdel(src)
		return BRUSH_UNCOVER
	try_dig(1)
	return BRUSH_NONE

/obj/structure/boulder/attackby(obj/item/attack_item, mob/user)
	. = ..()
	if(istype(attack_item, /obj/item/pickaxe))
		to_chat(user, span_notice("You begin smashing the boulder."))
		if(!do_after(user, 2.5 SECONDS, target = src))
			to_chat(user, span_warning("You slip and smash the boulder with extra force!"))
			excavation_level += rand(10,50)
			return
		switch(try_dig(25))
			if(DIG_UNDEFINED)
				message_admins("Tell coders something broke with xenoarch hammers and dig amount.")
				return
			if(DIG_DELETE)
				to_chat(user, span_warning("The boulder crumbles, leaving nothing behind."))
				return
			if(DIG_ROCK)
				to_chat(user, span_notice("You successfully dig the boulder. The item inside seems to be still intact."))

	if(istype(attack_item, /obj/item/xenoarch/hammer))
		var/obj/item/xenoarch/hammer/hammer = attack_item
		to_chat(user, span_notice("You begin carefully using your hammer."))
		if(!do_after(user, hammer.dig_speed, target = src))
			to_chat(user, span_warning("You interrupt your careful planning, damaging the boulder in the process!"))
			excavation_level += rand(1,5)
			return
		switch(try_dig(hammer.dig_amount))
			if(DIG_UNDEFINED)
				message_admins("Tell coders something broke with xenoarch hammers and dig amount.")
				return
			if(DIG_DELETE)
				to_chat(user, span_warning("The boulder crumbles, leaving nothing behind."))
				return
			if(DIG_ROCK)
				to_chat(user, span_notice("You successfully dig around the item."))

	if (istype(attack_item, /obj/item/xenoarch/handheld_scanner))
		var/obj/item/xenoarch/handheld_scanner/scanner = attack_item
		if (holomark_adv || (holomark && !istype(scanner, /obj/item/xenoarch/handheld_scanner/advanced)))
			to_chat(user, span_notice("The boulder was already scanned. You can even see the holomark attached to it."))
			return
		to_chat(user, span_notice("You begin to scan [src] using [scanner]."))
		if(!do_after(user, scanner.scanning_speed, target = src))
			to_chat(user, span_warning("You interrupt your scanning, damaging the boulder in the process!"))
			excavation_level += rand(1,5)
			return
		if(get_scanned(scanner.scan_advanced))
			to_chat(user, (span_notice("You successfully scanned the boulder, attaching the holomark to it with some info!")))
			if(scanner.scan_advanced)
				to_chat(user, span_notice("Thanks to the advanced scanner the holomark now also displays the exact depth needed!"))
			return

	if(istype(attack_item, /obj/item/xenoarch/tape_measure))
		if (measured)
			to_chat(user, span_notice("The boulder was already measured."))
			return
		to_chat(user, span_notice("You begin carefully using your measuring tape."))
		if(!do_after(user, 4 SECONDS, target = src))
			to_chat(user, span_warning("You interrupt your careful planning, damaging the boulder in the process!"))
			excavation_level += rand(1,5)
			return
		if(get_measured())
			to_chat(user, span_notice("You successfully attach a holo measuring tape to the boulder; the boulder will now report its dug depth always!"))
			return

	if(istype(attack_item, /obj/item/xenoarch/brush))
		var/obj/item/xenoarch/brush/brush = attack_item
		to_chat(user, span_notice("You begin carefully using your brush."))
		if(!do_after(user, brush.dig_speed, target = src))
			to_chat(user, span_warning("You interrupt your careful planning, damaging the boulder in the process!"))
			excavation_level += rand(1,5)
			return
		switch(try_uncover())
			if(BRUSH_DELETE)
				to_chat(user, span_warning("The boulder crumbles, leaving nothing behind."))
				return
			if(BRUSH_UNCOVER)
				to_chat(user, span_notice("You successfully brush around the item, fully revealing the item!"))
				return
			if(BRUSH_NONE)
				to_chat(user, span_notice("You brush around the item, but it wasn't revealed... hammer some more."))

	if(istype(attack_item, /obj/item/xenoarch/handheld_recoverer))
		to_chat(user, span_warning("The boulder must be stabilized using a different tool."))

	if(istype(attack_item, /obj/item/xenoarch/core_sampler))
		var/obj/item/xenoarch/core_sampler/sampler = attack_item
		if(sampler.used)
			balloon_alert(user, "This sampler was already used!")
			return
		sampler.sample = src
		sampler.used = TRUE
		sampler.icon_state = "sampler"
		to_chat(user, span_notice("You successfully took a sample of [src]. Now take it to the radiocarbon spectrometer."))



#undef BRUSH_DELETE
#undef BRUSH_UNCOVER
#undef BRUSH_NONE

#undef DIG_UNDEFINED
#undef DIG_DELETE
#undef DIG_ROCK
