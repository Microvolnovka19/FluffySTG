// /proc/giga_teshari_death(mob/living/carbon/dinner)
// 	if(isobserver(dinner))
// 		return

// 	playsound(get_turf(dinner), 'tff_modular/modules/custom_smites/sounds/teshari_swarm.ogg', 60, FALSE)


// 	// var/turf/tesh_source = locate(owner.x + pick(-12, 12), owner.y + pick(-12, 12), owner.z)
// 	//var/obj/effect/client_image_holder/stalker_phantom/teshari/tesh1 = new /obj/effect/client_image_holder/stalker_phantom/teshari(tesh_source, owner)

// // /obj/effect/client_image_holder/stalker_phantom/teshari
// // 	name = "Angry teshari"
// // 	desc = "Furious chicken, ready to fight and scratch and bite and claw and dust you."
// // 	image_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
// // 	image_state = "curseblob"
// // 	invisibility = INVISIBILITY_NONE

// // /obj/effect/client_image_holder/stalker_phantom/teshari/process(seconds_per_tick)
// // 	if(owner.stat == DEAD)
// // 		qdel(src)
// // 		return

// // 	if(get_dist(owner, src) <= 1)
// // 		playsound(owner, 'sound/effects/magic/demon_attack1.ogg', 50)
// // 		owner.visible_message(span_warning("[owner] is torn apart by [src] claws!"),
// // 						      span_userdanger("Teshari claws tear your body apart!"),
// // 							  blind_message=span_hear("You hear flesh ripping."))
// // 		owner.take_bodypart_damage(rand(3, 6))

// // 	else(SPT_PROB(90, seconds_per_tick))
// // 		src.forceMove(get_step_towards(src, owner))
// // 	..()


// /datum/smite/teshari_swarm
// 	name = "Send teshari swarm (LOUD!)"

// /datum/smite/teshari_swarm/effect(client/user, mob/living/target)
// 	if (!isliving(target))
// 		return

// 	if(!iscarbon(target))
// 		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
// 		return
// 	. = ..()

// 	giga_teshari_death(target)
