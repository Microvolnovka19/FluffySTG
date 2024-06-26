/obj/item/circuitboard/machine/radiocarbon_spectrometer
	name = "Radiocarbon spectrometer"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/radiocarbon_spectrometer
	req_components = list(
		/datum/stock_part/scanning_module = 4,
		/obj/item/reagent_containers/cup/beaker = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/machinery/radiocarbon_spectrometer
	name = "Radiocarbon spectrometer"
	desc = "A specialised, complex scanner for gleaning information on all manner of small things."
	anchored = TRUE
	density = TRUE
	icon = 'tff_modular/modules/xenoarcheology/icons/machinery.dmi'
	icon_state = "spectrometer"

	use_power = IDLE_POWER_USE // 1 = idle, 2 = active
	idle_power_usage = 20
	active_power_usage = 3000
	var/scanning = FALSE
	var/obj/item/xenoarch/core_sampler/current_sample


/obj/machinery/radiocarbon_spectrometer/attackby(obj/item/to_insert, mob/living/user)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, to_insert))
		update_appearance()
		return
	if(default_pry_open(to_insert))
		return
	if(default_deconstruction_crowbar(to_insert))
		return
	if(istype(to_insert, /obj/item/xenoarch/core_sampler))
		var/obj/item/xenoarch/core_sampler/sampler = to_insert
		if(!powered())
			return
		if(scanning)
			to_chat(user, span_notice("The machine is currently working."))
			return
		if(!sampler.sample)
			balloon_alert(user, "Core sampler is empty!")
			return
		if(!user.transferItemToLoc(sampler, src))
			to_chat(user, span_warning("\The [sampler] is stuck to your hand, you cannot put it in the machine!"))
			return TRUE
		current_sample = sampler
		scanning = TRUE
		visible_message("<span class='notice'>[user] inserts [sampler] into [src].</span>")
		process_sample()
	else
		balloon_alert(user, "Geosamples only!")
	return ..()

/obj/machinery/radiocarbon_spectrometer/proc/process_sample()
	var/data = ""
	if(powered())
		update_use_power(ACTIVE_POWER_USE)
		icon_state = "spectrometer_processing"
		var/obj/structure/boulder/current_boulder = current_sample.sample
		var/age = current_boulder.artifact_age
		data = "Mundane object (archaic xenos origins)<br>"
		data += "<B>Spectometric analysis on mineral sample has determined type of required field: [current_boulder.artifact_stabilizing_field]</B><BR>"
		data += "<HR>"
		if (age > 1000000000)
			data += " - Radiometric dating shows age of approximate [round(age/1000000000)] billion years<br>"
		else if (age > 1000000)
			data += " - Radiometric dating shows age of approximate [round(age/1000000)] million years<br>"
		else
			data += " - Radiometric dating shows age of approximate [round(age/1000)] thousand years<br>"
		data += " - Hyperspectral imaging reveals exotic energy wavelength detected with ID: [current_boulder.artifact_id]<br>"
		sleep(10 SECONDS)
	else
		qdel(current_sample)
		current_sample = NONE
		scanning = FALSE
		icon_state = "spectrometer"
		update_use_power(IDLE_POWER_USE)
		visible_message("<span class='notice'>[src] destroys core sampler due to internal error.</span>")
		return
	if(powered()) // Double check if still powered after sleep
		qdel(current_sample)
		current_sample = NONE
		var/obj/item/paper/artifact_info/P = new(src.loc)
		P.name = "[src] report"
		P.add_raw_text(data)
		P.update_icon()
		var/obj/item/stamp/S = new
		var/stamp_data = S.get_writing_implement_details()
		P.add_stamp(stamp_data["stamp_class"], rand(0, 300), rand(0, 400), rand(0, 360), stamp_data["stamp_icon_state"])
		playsound(src, 'sound/machines/printer.ogg', 25, FALSE)
		scanning = FALSE
		icon_state = "spectrometer"
		update_use_power(IDLE_POWER_USE)
	else
		qdel(current_sample)
		current_sample = NONE
		scanning = FALSE
		icon_state = "spectrometer"
		update_use_power(IDLE_POWER_USE)
		visible_message("<span class='notice'>[src] destroys core sampler due to internal error.</span>")
