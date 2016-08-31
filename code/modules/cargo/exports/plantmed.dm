/datum/export/plantmedicine
        cost = 2 //Gets multiplied based on healing chems inside of seed
        unit_name = Medicine
        export_types = list(/obj/item/seeds)
        SSshuttle.points = SSshuttle.points

/datum/export/plantmed/get_cost(obj/O)
        var/obj/item/seeds/S = O
        if S.has_reagent("omnizine, 1)
                S.reagents.get_reagent_amount("omnizine")
                        return ..() * cost
                
        if S.has_reagent("earthsblood, 1)
                S.reagents.get_reagent_amount("earthsblood")
                        return ..() * cost
                
/datum/export/plantmed/sell_object(obj/O)
        var/cost = ..()
        if SSshuttle.points = 14000
                return 0
