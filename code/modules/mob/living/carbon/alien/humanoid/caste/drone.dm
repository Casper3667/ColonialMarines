/mob/living/carbon/alien/humanoid/drone
	name = "alien drone"
	caste = "Drone"
	maxHealth = 205
	health = 205
	icon_state = "Drone Walking"
	storedPlasma = 350   //OLD STORED: 100
	max_plasma = 750 //OLD MAX: 500
	damagemin = 20 //OLD MIN 26
	damagemax = 20 //OLD MAX 32
	heal_rate = 4
	plasma_rate = 12
	tacklemin = 2
	tacklemax = 4 //old max 5
	tackle_chance = 40 //Should not be above 100% old chance 50
	var/hasJelly = 0
	var/jellyProgress = 0
	var/jellyProgressMax = 1200
	psychiccost = 30
	Stat()
		..()
		stat(null, "Jelly Progress: [jellyProgress]/[jellyProgressMax]")
	proc/growJelly()
		spawn while(1)
			if(hasJelly)
				if(jellyProgress < jellyProgressMax)
					jellyProgress = min(jellyProgress + 1, jellyProgressMax)
			sleep(10)
	proc/canEvolve()
		if(!hasJelly)
			return 0
		if(jellyProgress < jellyProgressMax)
			return 0
		return 1

/mob/living/carbon/alien/humanoid/drone/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(src.name == "alien drone")
		src.name = text("alien drone ([rand(1, 1000)])")
	src.real_name = src.name
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/resin,/mob/living/carbon/alien/humanoid/proc/weak_acid)
	growJelly()
	verbs -= /atom/movable/verb/pull
	/*var/matrix/M = matrix()
	M.Scale(0.9,0.9)
	src.transform = M
	*/
	..()
//Drones use the same base as generic humanoids.
//Drone verbs

/mob/living/carbon/alien/humanoid/drone/verb/evolve() // -- TLE
	set name = "Evolve (750)"
	set desc = "Produce an interal egg sac capable of spawning children. Only one queen can exist at a time."
	set category = "Alien"

	if(powerc(500))
		// Queen check
		var/no_queen = 1
		for(var/mob/living/carbon/alien/humanoid/queen/Q in living_mob_list)
			if(!Q.key && Q.brain_op_stage != 4)
				continue
			no_queen = 0

		if(no_queen)
			adjustToxLoss(-500)
			src << "\green You begin to evolve!"
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\green <B>[src] begins to twist and contort!</B>"), 1)
			var/mob/living/carbon/alien/humanoid/queen/new_xeno = new (loc)
			mind.transfer_to(new_xeno)
			del(src)
		else
			src << "<span class='notice'>We already have an alive queen.</span>"
	return



/mob/living/carbon/alien/humanoid/drone/verb/evolve2() // -- TLE
	set name = "Evolve (Jelly)"
	set desc = "Evolve into your next form"
	set category = "Alien"
	if(!hivemind_check(psychiccost))
		src << "\red Your queen's psychic strength is not powerful enough for you to evolve further."
		return
	if(!canEvolve())
		if(hasJelly)
			src << "You are not ready to evolve yet"
		else
			src << "You need a mature royal jelly to evolve"
		return
	if(src.stat != CONSCIOUS)
		src << "You are unable to do that now."
		return
	if(jellyProgress >= jellyProgressMax)	//TODO ~Carn
		//green is impossible to read, so i made these blue and changed the formatting slightly
		src << "<B>Hivelord</B> \blue The ULTIMATE hive construction alien.  Capable of building massive hives, that's to it's tremendous Plasma reserve.  However, it is very slow and weak."
		src << "<B>Carrier</B> \blue The latest advance in Alien Evolution.  Capable of holding upto 6 runners, and throwing them a far distance, directly to someones face."
		var/alien_caste = alert(src, "Please choose which alien caste you shall belong to.",,"Hivelord","Carrier")

		var/mob/living/carbon/alien/humanoid/new_xeno
		switch(alien_caste)
			if("Hivelord")
				new_xeno = new /mob/living/carbon/alien/humanoid/hivelord(loc)
			if("Carrier")
				new_xeno = new /mob/living/carbon/alien/humanoid/carrier(loc)
		if(mind)	mind.transfer_to(new_xeno)
		del(src)
		return
	else
		src << "\red You are not ready to evolve."
		return

	del(src)


	return



/mob/living/carbon/alien/humanoid/drone

	handle_regular_hud_updates()

		..() //-Yvarov
		var/AHF = maxHealth/5 //Alien Health Fraction

		if (healths)
			if (stat != 2)
				switch(health)
					if(AHF*4 to INFINITY)
						healths.icon_state = "health0"
					if(AHF*3 to AHF*4)
						healths.icon_state = "health1"
					if(AHF*2 to AHF*3)
						healths.icon_state = "health2"
					if(AHF to AHF*2)
						healths.icon_state = "health3"
					if(0 to AHF)
						healths.icon_state = "health4"
					else
						healths.icon_state = "health5"
			else
				healths.icon_state = "health6"