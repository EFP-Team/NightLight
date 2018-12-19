/obj/item/chromosome
	name = "blank chromosome"
	icon = 'icons/obj/chromosomes.dmi'
	icon_state = ""
	desc = "A tube holding chromosomic data."
	force = 0
	w_class = WEIGHT_CLASS_SMALL

	var/stabilizer_coeff = 1 //lower is better
	var/synchronizer_coeff = 1 //lower is better
	var/power_coeff = 1 //higher is better
	var/energy_coeff = 1 //lower is better

	var/weight = 5

/obj/item/chromosome/proc/can_apply(datum/mutation/human/HM)
	if(!HM || !(HM.can_chromosome == 1))
		return
	if((stabilizer_coeff != 1) && (HM.stabilizer_coeff != -1)) //if the chromosome is 1, we dont change anything. If the mutation is -1, we cant change it. sorry
		return TRUE
	if((synchronizer_coeff != 1) && (HM.synchronizer_coeff != -1))
		return TRUE
	if((power_coeff != 1) && (HM.power_coeff != -1))
		return TRUE
	if((energy_coeff != 1) && (HM.energy_coeff != -1))
		return TRUE

/obj/item/chromosome/proc/apply(datum/mutation/human/HM)
	if(!HM || !HM.can_chromosome)
		return
	if(HM.stabilizer_coeff != -1)
		HM.stabilizer_coeff = stabilizer_coeff
	if(HM.synchronizer_coeff != -1)
		HM.synchronizer_coeff = synchronizer_coeff
	if(HM.power_coeff != -1)
		HM.power_coeff = power_coeff
	if(HM.energy_coeff != -1)
		HM.energy_coeff = energy_coeff
	HM.can_chromosome = 2
	HM.chromosome_name = name
	qdel(src)

/proc/generate_chromosome()
	var/static/list/chromosomes
	to_chat(world, "1")
	if(!chromosomes)
		to_chat(world, "2")
		chromosomes = list()
		for(var/A in subtypesof(/obj/item/chromosome))
			to_chat(world, "3-[A]")
			var/obj/item/chromosome/CM = A
			to_chat(world, "4-[CM]")
			if(!initial(CM.weight))
				to_chat(world, "5")
				break
			chromosomes[A] = initial(CM.weight)
	var/deleteme = pickweight(chromosomes)
	to_chat(world, "6-[deleteme]")
	return deleteme


/obj/item/chromosome/stabilizer
	name = "stabilizer chromosome"
	icon_state = "stabilizer"
	stabilizer_coeff = 0.5

/obj/item/chromosome/synchronizer
	name = "synchronizer chromosome"
	icon_state = "synchronizer"
	synchronizer_coeff = 0.5

/obj/item/chromosome/power
	name = "power chromosome"
	icon_state = "power"
	power_coeff = 1.5

/obj/item/chromosome/energy
	name = "stabilizer chromosome"
	icon_state = "stabilizer"
	energy_coeff = 0.5

