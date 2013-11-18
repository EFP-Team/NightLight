// List is required to compile the resources into the game when it loads.
// Dynamically loading it has bad results with sounds overtaking each other, even with the wait variable.
#ifdef AI_VOX

var/list/vox_sounds = list("," = 'sound/vox_fem/,.ogg',
"." = 'sound/vox_fem/..ogg',
"a" = 'sound/vox_fem/a.ogg',
"abortions" = 'sound/vox_fem/abortions.ogg',
"accelerating" = 'sound/vox_fem/accelerating.ogg',
"accelerator" = 'sound/vox_fem/accelerator.ogg',
"accepted" = 'sound/vox_fem/accepted.ogg',
"access" = 'sound/vox_fem/access.ogg',
"acknowledge" = 'sound/vox_fem/acknowledge.ogg',
"acknowledged" = 'sound/vox_fem/acknowledged.ogg',
"acquired" = 'sound/vox_fem/acquired.ogg',
"acquisition" = 'sound/vox_fem/acquisition.ogg',
"across" = 'sound/vox_fem/across.ogg',
"activate" = 'sound/vox_fem/activate.ogg',
"activated" = 'sound/vox_fem/activated.ogg',
"activity" = 'sound/vox_fem/activity.ogg',
"adios" = 'sound/vox_fem/adios.ogg',
"administration" = 'sound/vox_fem/administration.ogg',
"advanced" = 'sound/vox_fem/advanced.ogg',
"aft" = 'sound/vox_fem/aft.ogg',
"after" = 'sound/vox_fem/after.ogg',
"agent" = 'sound/vox_fem/agent.ogg',
"ai" = 'sound/vox_fem/ai.ogg',
"alarm" = 'sound/vox_fem/alarm.ogg',
"alert" = 'sound/vox_fem/alert.ogg',
"alien" = 'sound/vox_fem/alien.ogg',
"aligned" = 'sound/vox_fem/aligned.ogg',
"all" = 'sound/vox_fem/all.ogg',
"alpha" = 'sound/vox_fem/alpha.ogg',
"am" = 'sound/vox_fem/am.ogg',
"amigo" = 'sound/vox_fem/amigo.ogg',
"ammunition" = 'sound/vox_fem/ammunition.ogg',
"an" = 'sound/vox_fem/an.ogg',
"and" = 'sound/vox_fem/and.ogg',
"announcement" = 'sound/vox_fem/announcement.ogg',
"anomalous" = 'sound/vox_fem/anomalous.ogg',
"antenna" = 'sound/vox_fem/antenna.ogg',
"any" = 'sound/vox_fem/any.ogg',
"apprehend" = 'sound/vox_fem/apprehend.ogg',
"approach" = 'sound/vox_fem/approach.ogg',
"are" = 'sound/vox_fem/are.ogg',
"area" = 'sound/vox_fem/area.ogg',
"arm" = 'sound/vox_fem/arm.ogg',
"armed" = 'sound/vox_fem/armed.ogg',
"armor" = 'sound/vox_fem/armor.ogg',
"armory" = 'sound/vox_fem/armory.ogg',
"array" = 'sound/vox_fem/array.ogg',
"arrest" = 'sound/vox_fem/arrest.ogg',
"asimov" = 'sound/vox_fem/asimov.ogg',
"ass" = 'sound/vox_fem/ass.ogg',
"asshole" = 'sound/vox_fem/asshole.ogg',
"assholes" = 'sound/vox_fem/assholes.ogg',
"at" = 'sound/vox_fem/at.ogg',
"atomic" = 'sound/vox_fem/atomic.ogg',
"attention" = 'sound/vox_fem/attention.ogg',
"authorize" = 'sound/vox_fem/authorize.ogg',
"authorized" = 'sound/vox_fem/authorized.ogg',
"automatic" = 'sound/vox_fem/automatic.ogg',
"away" = 'sound/vox_fem/away.ogg',
"b" = 'sound/vox_fem/b.ogg',
"back" = 'sound/vox_fem/back.ogg',
"backman" = 'sound/vox_fem/backman.ogg',
"bad" = 'sound/vox_fem/bad.ogg',
"bag" = 'sound/vox_fem/bag.ogg',
"bailey" = 'sound/vox_fem/bailey.ogg',
"barracks" = 'sound/vox_fem/barracks.ogg',
"base" = 'sound/vox_fem/base.ogg',
"bay" = 'sound/vox_fem/bay.ogg',
"be" = 'sound/vox_fem/be.ogg',
"been" = 'sound/vox_fem/been.ogg',
"before" = 'sound/vox_fem/before.ogg',
"beyond" = 'sound/vox_fem/beyond.ogg',
"biohazard" = 'sound/vox_fem/biohazard.ogg',
"biological" = 'sound/vox_fem/biological.ogg',
"birdwell" = 'sound/vox_fem/birdwell.ogg',
"bitch" = 'sound/vox_fem/bitch.ogg',
"bitches" = 'sound/vox_fem/bitches.ogg',
"black" = 'sound/vox_fem/black.ogg',
"blast" = 'sound/vox_fem/blast.ogg',
"blocked" = 'sound/vox_fem/blocked.ogg',
"blue" = 'sound/vox_fem/blue.ogg',
"bottom" = 'sound/vox_fem/bottom.ogg',
"bravo" = 'sound/vox_fem/bravo.ogg',
"breach" = 'sound/vox_fem/breach.ogg',
"breached" = 'sound/vox_fem/breached.ogg',
"break" = 'sound/vox_fem/break.ogg',
"bridge" = 'sound/vox_fem/bridge.ogg',
"bust" = 'sound/vox_fem/bust.ogg',
"but" = 'sound/vox_fem/but.ogg',
"button" = 'sound/vox_fem/button.ogg',
"bypass" = 'sound/vox_fem/bypass.ogg',
"c" = 'sound/vox_fem/c.ogg',
"cable" = 'sound/vox_fem/cable.ogg',
"call" = 'sound/vox_fem/call.ogg',
"called" = 'sound/vox_fem/called.ogg',
"canal" = 'sound/vox_fem/canal.ogg',
"cap" = 'sound/vox_fem/cap.ogg',
"captain" = 'sound/vox_fem/captain.ogg',
"capture" = 'sound/vox_fem/capture.ogg',
"cargo" = 'sound/vox_fem/cargo.ogg',
"ceiling" = 'sound/vox_fem/ceiling.ogg',
"celsius" = 'sound/vox_fem/celsius.ogg',
"Centcom" = 'sound/vox_fem/Centcom.ogg',
"center" = 'sound/vox_fem/center.ogg',
"centi" = 'sound/vox_fem/centi.ogg',
"central" = 'sound/vox_fem/central.ogg',
"chamber" = 'sound/vox_fem/chamber.ogg',
"changed" = 'sound/vox_fem/changed.ogg',
"charlie" = 'sound/vox_fem/charlie.ogg',
"check" = 'sound/vox_fem/check.ogg',
"checkpoint" = 'sound/vox_fem/checkpoint.ogg',
"chemical" = 'sound/vox_fem/chemical.ogg',
"cleanup" = 'sound/vox_fem/cleanup.ogg',
"clear" = 'sound/vox_fem/clear.ogg',
"clearance" = 'sound/vox_fem/clearance.ogg',
"close" = 'sound/vox_fem/close.ogg',
"clown" = 'sound/vox_fem/clown.ogg',
"code" = 'sound/vox_fem/code.ogg',
"coded" = 'sound/vox_fem/coded.ogg',
"collider" = 'sound/vox_fem/collider.ogg',
"come" = 'sound/vox_fem/come.ogg',
"command" = 'sound/vox_fem/command.ogg',
"communication" = 'sound/vox_fem/communication.ogg',
"complex" = 'sound/vox_fem/complex.ogg',
"computer" = 'sound/vox_fem/computer.ogg',
"condition" = 'sound/vox_fem/condition.ogg',
"connor" = 'sound/vox_fem/connor.ogg',
"containment" = 'sound/vox_fem/containment.ogg',
"contamination" = 'sound/vox_fem/contamination.ogg',
"contraband" = 'sound/vox_fem/contraband.ogg',
"control" = 'sound/vox_fem/control.ogg',
"coolant" = 'sound/vox_fem/coolant.ogg',
"coomer" = 'sound/vox_fem/coomer.ogg',
"core" = 'sound/vox_fem/core.ogg',
"correct" = 'sound/vox_fem/correct.ogg',
"corridor" = 'sound/vox_fem/corridor.ogg',
"coward" = 'sound/vox_fem/coward.ogg',
"cowards" = 'sound/vox_fem/cowards.ogg',
"crew" = 'sound/vox_fem/crew.ogg',
"cross" = 'sound/vox_fem/cross.ogg',
"cryogenic" = 'sound/vox_fem/cryogenic.ogg',
"cunt" = 'sound/vox_fem/cunt.ogg',
"cyborg" = 'sound/vox_fem/cyborg.ogg',
"cyborgs" = 'sound/vox_fem/cyborgs.ogg',
"d" = 'sound/vox_fem/d.ogg',
"damage" = 'sound/vox_fem/damage.ogg',
"damaged" = 'sound/vox_fem/damaged.ogg',
"danger" = 'sound/vox_fem/danger.ogg',
"day" = 'sound/vox_fem/day.ogg',
"deactivated" = 'sound/vox_fem/deactivated.ogg',
"decompression" = 'sound/vox_fem/decompression.ogg',
"decontamination" = 'sound/vox_fem/decontamination.ogg',
"deeoo" = 'sound/vox_fem/deeoo.ogg',
"defense" = 'sound/vox_fem/defense.ogg',
"degrees" = 'sound/vox_fem/degrees.ogg',
"delta" = 'sound/vox_fem/delta.ogg',
"denied" = 'sound/vox_fem/denied.ogg',
"deploy" = 'sound/vox_fem/deploy.ogg',
"deployed" = 'sound/vox_fem/deployed.ogg',
"destroy" = 'sound/vox_fem/destroy.ogg',
"destroyed" = 'sound/vox_fem/destroyed.ogg',
"detain" = 'sound/vox_fem/detain.ogg',
"detected" = 'sound/vox_fem/detected.ogg',
"detonation" = 'sound/vox_fem/detonation.ogg',
"device" = 'sound/vox_fem/device.ogg',
"did" = 'sound/vox_fem/did.ogg',
"die" = 'sound/vox_fem/die.ogg',
"dimensional" = 'sound/vox_fem/dimensional.ogg',
"dirt" = 'sound/vox_fem/dirt.ogg',
"disengaged" = 'sound/vox_fem/disengaged.ogg',
"dish" = 'sound/vox_fem/dish.ogg',
"disposal" = 'sound/vox_fem/disposal.ogg',
"distance" = 'sound/vox_fem/distance.ogg',
"distortion" = 'sound/vox_fem/distortion.ogg',
"do" = 'sound/vox_fem/do.ogg',
"doctor" = 'sound/vox_fem/doctor.ogg',
"door" = 'sound/vox_fem/door.ogg',
"down" = 'sound/vox_fem/down.ogg',
"dual" = 'sound/vox_fem/dual.ogg',
"duct" = 'sound/vox_fem/duct.ogg',
"e" = 'sound/vox_fem/e.ogg',
"east" = 'sound/vox_fem/east.ogg',
"echo" = 'sound/vox_fem/echo.ogg',
"ed" = 'sound/vox_fem/ed.ogg',
"effect" = 'sound/vox_fem/effect.ogg',
"egress" = 'sound/vox_fem/egress.ogg',
"eight" = 'sound/vox_fem/eight.ogg',
"eighteen" = 'sound/vox_fem/eighteen.ogg',
"eighty" = 'sound/vox_fem/eighty.ogg',
"electric" = 'sound/vox_fem/electric.ogg',
"electromagnetic" = 'sound/vox_fem/electromagnetic.ogg',
"elevator" = 'sound/vox_fem/elevator.ogg',
"eleven" = 'sound/vox_fem/eleven.ogg',
"eliminate" = 'sound/vox_fem/eliminate.ogg',
"emergency" = 'sound/vox_fem/emergency.ogg',
"energy" = 'sound/vox_fem/energy.ogg',
"engage" = 'sound/vox_fem/engage.ogg',
"engaged" = 'sound/vox_fem/engaged.ogg',
"engine" = 'sound/vox_fem/engine.ogg',
"enter" = 'sound/vox_fem/enter.ogg',
"entry" = 'sound/vox_fem/entry.ogg',
"environment" = 'sound/vox_fem/environment.ogg',
"error" = 'sound/vox_fem/error.ogg',
"escape" = 'sound/vox_fem/escape.ogg',
"evacuate" = 'sound/vox_fem/evacuate.ogg',
"exchange" = 'sound/vox_fem/exchange.ogg',
"exit" = 'sound/vox_fem/exit.ogg',
"expect" = 'sound/vox_fem/expect.ogg',
"experiment" = 'sound/vox_fem/experiment.ogg',
"experimental" = 'sound/vox_fem/experimental.ogg',
"explode" = 'sound/vox_fem/explode.ogg',
"explosion" = 'sound/vox_fem/explosion.ogg',
"exposure" = 'sound/vox_fem/exposure.ogg',
"exterminate" = 'sound/vox_fem/exterminate.ogg',
"extinguish" = 'sound/vox_fem/extinguish.ogg',
"extinguisher" = 'sound/vox_fem/extinguisher.ogg',
"extreme" = 'sound/vox_fem/extreme.ogg',
"f" = 'sound/vox_fem/f.ogg',
"facility" = 'sound/vox_fem/facility.ogg',
"fahrenheit" = 'sound/vox_fem/fahrenheit.ogg',
"failed" = 'sound/vox_fem/failed.ogg',
"failure" = 'sound/vox_fem/failure.ogg',
"farthest" = 'sound/vox_fem/farthest.ogg',
"fast" = 'sound/vox_fem/fast.ogg',
"feet" = 'sound/vox_fem/feet.ogg',
"field" = 'sound/vox_fem/field.ogg',
"fifteen" = 'sound/vox_fem/fifteen.ogg',
"fifth" = 'sound/vox_fem/fifth.ogg',
"fifty" = 'sound/vox_fem/fifty.ogg',
"final" = 'sound/vox_fem/final.ogg',
"fine" = 'sound/vox_fem/fine.ogg',
"fire" = 'sound/vox_fem/fire.ogg',
"first" = 'sound/vox_fem/first.ogg',
"five" = 'sound/vox_fem/five.ogg',
"flooding" = 'sound/vox_fem/flooding.ogg',
"floor" = 'sound/vox_fem/floor.ogg',
"fool" = 'sound/vox_fem/fool.ogg',
"for" = 'sound/vox_fem/for.ogg',
"forbidden" = 'sound/vox_fem/forbidden.ogg',
"force" = 'sound/vox_fem/force.ogg',
"fore" = 'sound/vox_fem/fore.ogg',
"forms" = 'sound/vox_fem/forms.ogg',
"found" = 'sound/vox_fem/found.ogg',
"four" = 'sound/vox_fem/four.ogg',
"fourteen" = 'sound/vox_fem/fourteen.ogg',
"fourth" = 'sound/vox_fem/fourth.ogg',
"fourty" = 'sound/vox_fem/fourty.ogg',
"foxtrot" = 'sound/vox_fem/foxtrot.ogg',
"freeman" = 'sound/vox_fem/freeman.ogg',
"freezer" = 'sound/vox_fem/freezer.ogg',
"from" = 'sound/vox_fem/from.ogg',
"front" = 'sound/vox_fem/front.ogg',
"fuck" = 'sound/vox_fem/fuck.ogg',
"fucking" = 'sound/vox_fem/fucking.ogg',
"fucks" = 'sound/vox_fem/fucks.ogg',
"fuel" = 'sound/vox_fem/fuel.ogg',
"g" = 'sound/vox_fem/g.ogg',
"gas" = 'sound/vox_fem/gas.ogg',
"get" = 'sound/vox_fem/get.ogg',
"glory" = 'sound/vox_fem/glory.ogg',
"go" = 'sound/vox_fem/go.ogg',
"going" = 'sound/vox_fem/going.ogg',
"good" = 'sound/vox_fem/good.ogg',
"goodbye" = 'sound/vox_fem/goodbye.ogg',
"gordon" = 'sound/vox_fem/gordon.ogg',
"got" = 'sound/vox_fem/got.ogg',
"government" = 'sound/vox_fem/government.ogg',
"granted" = 'sound/vox_fem/granted.ogg',
"gray" = 'sound/vox_fem/gray.ogg',
"great" = 'sound/vox_fem/great.ogg',
"green" = 'sound/vox_fem/green.ogg',
"grenade" = 'sound/vox_fem/grenade.ogg',
"guard" = 'sound/vox_fem/guard.ogg',
"gulf" = 'sound/vox_fem/gulf.ogg',
"gun" = 'sound/vox_fem/gun.ogg',
"guthrie" = 'sound/vox_fem/guthrie.ogg',
"h" = 'sound/vox_fem/h.ogg',
"hacker" = 'sound/vox_fem/hacker.ogg',
"hackers" = 'sound/vox_fem/hackers.ogg',
"handling" = 'sound/vox_fem/handling.ogg',
"hangar" = 'sound/vox_fem/hangar.ogg',
"harm" = 'sound/vox_fem/harm.ogg',
"has" = 'sound/vox_fem/has.ogg',
"have" = 'sound/vox_fem/have.ogg',
"hazard" = 'sound/vox_fem/hazard.ogg',
"head" = 'sound/vox_fem/head.ogg',
"health" = 'sound/vox_fem/health.ogg',
"heat" = 'sound/vox_fem/heat.ogg',
"helicopter" = 'sound/vox_fem/helicopter.ogg',
"helium" = 'sound/vox_fem/helium.ogg',
"hello" = 'sound/vox_fem/hello.ogg',
"help" = 'sound/vox_fem/help.ogg',
"here" = 'sound/vox_fem/here.ogg',
"hide" = 'sound/vox_fem/hide.ogg',
"high" = 'sound/vox_fem/high.ogg',
"highest" = 'sound/vox_fem/highest.ogg',
"hit" = 'sound/vox_fem/hit.ogg',
"hole" = 'sound/vox_fem/hole.ogg',
"hostile" = 'sound/vox_fem/hostile.ogg',
"hot" = 'sound/vox_fem/hot.ogg',
"hotel" = 'sound/vox_fem/hotel.ogg',
"hour" = 'sound/vox_fem/hour.ogg',
"hours" = 'sound/vox_fem/hours.ogg',
"human" = 'sound/vox_fem/human.ogg',
"hundred" = 'sound/vox_fem/hundred.ogg',
"hunger" = 'sound/vox_fem/hunger.ogg',
"hydro" = 'sound/vox_fem/hydro.ogg',
"hydroponics" = 'sound/vox_fem/hydroponics.ogg',
"i" = 'sound/vox_fem/i.ogg',
"idiot" = 'sound/vox_fem/idiot.ogg',
"illegal" = 'sound/vox_fem/illegal.ogg',
"immediate" = 'sound/vox_fem/immediate.ogg',
"immediately" = 'sound/vox_fem/immediately.ogg',
"in" = 'sound/vox_fem/in.ogg',
"inches" = 'sound/vox_fem/inches.ogg',
"india" = 'sound/vox_fem/india.ogg',
"ing" = 'sound/vox_fem/ing.ogg',
"inoperative" = 'sound/vox_fem/inoperative.ogg',
"inside" = 'sound/vox_fem/inside.ogg',
"inspection" = 'sound/vox_fem/inspection.ogg',
"inspector" = 'sound/vox_fem/inspector.ogg',
"interchange" = 'sound/vox_fem/interchange.ogg',
"intruder" = 'sound/vox_fem/intruder.ogg',
"invalid" = 'sound/vox_fem/invalid.ogg',
"invasion" = 'sound/vox_fem/invasion.ogg',
"is" = 'sound/vox_fem/is.ogg',
"it" = 'sound/vox_fem/it.ogg',
"j" = 'sound/vox_fem/j.ogg',
"johnson" = 'sound/vox_fem/johnson.ogg',
"juliet" = 'sound/vox_fem/juliet.ogg',
"k" = 'sound/vox_fem/k.ogg',
"key" = 'sound/vox_fem/key.ogg',
"kill" = 'sound/vox_fem/kill.ogg',
"kilo" = 'sound/vox_fem/kilo.ogg',
"kit" = 'sound/vox_fem/kit.ogg',
"l" = 'sound/vox_fem/l.ogg',
"lab" = 'sound/vox_fem/lab.ogg',
"lambda" = 'sound/vox_fem/lambda.ogg',
"laser" = 'sound/vox_fem/laser.ogg',
"last" = 'sound/vox_fem/last.ogg',
"launch" = 'sound/vox_fem/launch.ogg',
"law" = 'sound/vox_fem/law.ogg',
"laws" = 'sound/vox_fem/laws.ogg',
"leak" = 'sound/vox_fem/leak.ogg',
"leave" = 'sound/vox_fem/leave.ogg',
"left" = 'sound/vox_fem/left.ogg',
"legal" = 'sound/vox_fem/legal.ogg',
"level" = 'sound/vox_fem/level.ogg',
"lever" = 'sound/vox_fem/lever.ogg',
"lie" = 'sound/vox_fem/lie.ogg',
"lieutenant" = 'sound/vox_fem/lieutenant.ogg',
"life" = 'sound/vox_fem/life.ogg',
"light" = 'sound/vox_fem/light.ogg',
"lima" = 'sound/vox_fem/lima.ogg',
"liquid" = 'sound/vox_fem/liquid.ogg',
"loading" = 'sound/vox_fem/loading.ogg',
"locate" = 'sound/vox_fem/locate.ogg',
"located" = 'sound/vox_fem/located.ogg',
"location" = 'sound/vox_fem/location.ogg',
"lock" = 'sound/vox_fem/lock.ogg',
"locked" = 'sound/vox_fem/locked.ogg',
"locker" = 'sound/vox_fem/locker.ogg',
"lockout" = 'sound/vox_fem/lockout.ogg',
"loose" = 'sound/vox_fem/loose.ogg',
"lower" = 'sound/vox_fem/lower.ogg',
"lowest" = 'sound/vox_fem/lowest.ogg',
"m" = 'sound/vox_fem/m.ogg',
"magnetic" = 'sound/vox_fem/magnetic.ogg',
"main" = 'sound/vox_fem/main.ogg',
"maintenance" = 'sound/vox_fem/maintenance.ogg',
"malfunction" = 'sound/vox_fem/malfunction.ogg',
"man" = 'sound/vox_fem/man.ogg',
"mass" = 'sound/vox_fem/mass.ogg',
"materials" = 'sound/vox_fem/materials.ogg',
"maximum" = 'sound/vox_fem/maximum.ogg',
"may" = 'sound/vox_fem/may.ogg',
"me" = 'sound/vox_fem/me.ogg',
"medbay" = 'sound/vox_fem/medbay.ogg',
"medical" = 'sound/vox_fem/medical.ogg',
"men" = 'sound/vox_fem/men.ogg',
"mercy" = 'sound/vox_fem/mercy.ogg',
"mesa" = 'sound/vox_fem/mesa.ogg',
"message" = 'sound/vox_fem/message.ogg',
"meter" = 'sound/vox_fem/meter.ogg',
"micro" = 'sound/vox_fem/micro.ogg',
"middle" = 'sound/vox_fem/middle.ogg',
"mike" = 'sound/vox_fem/mike.ogg',
"miles" = 'sound/vox_fem/miles.ogg',
"military" = 'sound/vox_fem/military.ogg',
"milli" = 'sound/vox_fem/milli.ogg',
"million" = 'sound/vox_fem/million.ogg',
"minefield" = 'sound/vox_fem/minefield.ogg',
"minimum" = 'sound/vox_fem/minimum.ogg',
"minutes" = 'sound/vox_fem/minutes.ogg',
"mister" = 'sound/vox_fem/mister.ogg',
"mode" = 'sound/vox_fem/mode.ogg',
"money" = 'sound/vox_fem/money.ogg',
"motor" = 'sound/vox_fem/motor.ogg',
"motorpool" = 'sound/vox_fem/motorpool.ogg',
"move" = 'sound/vox_fem/move.ogg',
"must" = 'sound/vox_fem/must.ogg',
"my" = 'sound/vox_fem/my.ogg',
"n" = 'sound/vox_fem/n.ogg',
"nanotrasen" = 'sound/vox_fem/nanotrasen.ogg',
"nearest" = 'sound/vox_fem/nearest.ogg',
"nice" = 'sound/vox_fem/nice.ogg',
"nine" = 'sound/vox_fem/nine.ogg',
"nineteen" = 'sound/vox_fem/nineteen.ogg',
"ninety" = 'sound/vox_fem/ninety.ogg',
"no" = 'sound/vox_fem/no.ogg',
"nominal" = 'sound/vox_fem/nominal.ogg',
"north" = 'sound/vox_fem/north.ogg',
"not" = 'sound/vox_fem/not.ogg',
"november" = 'sound/vox_fem/november.ogg',
"now" = 'sound/vox_fem/now.ogg',
"number" = 'sound/vox_fem/number.ogg',
"o" = 'sound/vox_fem/o.ogg',
"objective" = 'sound/vox_fem/objective.ogg',
"observation" = 'sound/vox_fem/observation.ogg',
"obtain" = 'sound/vox_fem/obtain.ogg',
"of" = 'sound/vox_fem/of.ogg',
"officer" = 'sound/vox_fem/officer.ogg',
"ok" = 'sound/vox_fem/ok.ogg',
"on" = 'sound/vox_fem/on.ogg',
"one" = 'sound/vox_fem/one.ogg',
"open" = 'sound/vox_fem/open.ogg',
"operating" = 'sound/vox_fem/operating.ogg',
"operations" = 'sound/vox_fem/operations.ogg',
"operative" = 'sound/vox_fem/operative.ogg',
"option" = 'sound/vox_fem/option.ogg',
"order" = 'sound/vox_fem/order.ogg',
"organic" = 'sound/vox_fem/organic.ogg',
"oscar" = 'sound/vox_fem/oscar.ogg',
"out" = 'sound/vox_fem/out.ogg',
"outside" = 'sound/vox_fem/outside.ogg',
"over" = 'sound/vox_fem/over.ogg',
"overload" = 'sound/vox_fem/overload.ogg',
"override" = 'sound/vox_fem/override.ogg',
"p" = 'sound/vox_fem/p.ogg',
"pacify" = 'sound/vox_fem/pacify.ogg',
"pain" = 'sound/vox_fem/pain.ogg',
"pal" = 'sound/vox_fem/pal.ogg',
"panel" = 'sound/vox_fem/panel.ogg',
"percent" = 'sound/vox_fem/percent.ogg',
"perimeter" = 'sound/vox_fem/perimeter.ogg',
"permitted" = 'sound/vox_fem/permitted.ogg',
"personnel" = 'sound/vox_fem/personnel.ogg',
"pipe" = 'sound/vox_fem/pipe.ogg',
"plant" = 'sound/vox_fem/plant.ogg',
"plasma" = 'sound/vox_fem/plasma.ogg',
"platform" = 'sound/vox_fem/platform.ogg',
"please" = 'sound/vox_fem/please.ogg',
"point" = 'sound/vox_fem/point.ogg',
"port" = 'sound/vox_fem/port.ogg',
"portal" = 'sound/vox_fem/portal.ogg',
"power" = 'sound/vox_fem/power.ogg',
"presence" = 'sound/vox_fem/presence.ogg',
"press" = 'sound/vox_fem/press.ogg',
"primary" = 'sound/vox_fem/primary.ogg',
"proceed" = 'sound/vox_fem/proceed.ogg',
"processing" = 'sound/vox_fem/processing.ogg',
"progress" = 'sound/vox_fem/progress.ogg',
"proper" = 'sound/vox_fem/proper.ogg',
"propulsion" = 'sound/vox_fem/propulsion.ogg',
"prosecute" = 'sound/vox_fem/prosecute.ogg',
"protective" = 'sound/vox_fem/protective.ogg',
"push" = 'sound/vox_fem/push.ogg',
"q" = 'sound/vox_fem/q.ogg',
"quantum" = 'sound/vox_fem/quantum.ogg',
"quebec" = 'sound/vox_fem/quebec.ogg',
"queen" = 'sound/vox_fem/queen.ogg',
"question" = 'sound/vox_fem/question.ogg',
"questioning" = 'sound/vox_fem/questioning.ogg',
"quick" = 'sound/vox_fem/quick.ogg',
"quit" = 'sound/vox_fem/quit.ogg',
"r" = 'sound/vox_fem/r.ogg',
"radiation" = 'sound/vox_fem/radiation.ogg',
"radioactive" = 'sound/vox_fem/radioactive.ogg',
"rads" = 'sound/vox_fem/rads.ogg',
"raider" = 'sound/vox_fem/raider.ogg',
"raiders" = 'sound/vox_fem/raiders.ogg',
"rapid" = 'sound/vox_fem/rapid.ogg',
"reach" = 'sound/vox_fem/reach.ogg',
"reached" = 'sound/vox_fem/reached.ogg',
"reactor" = 'sound/vox_fem/reactor.ogg',
"red" = 'sound/vox_fem/red.ogg',
"relay" = 'sound/vox_fem/relay.ogg',
"released" = 'sound/vox_fem/released.ogg',
"remaining" = 'sound/vox_fem/remaining.ogg',
"removal" = 'sound/vox_fem/removal.ogg',
"renegade" = 'sound/vox_fem/renegade.ogg',
"repair" = 'sound/vox_fem/repair.ogg',
"report" = 'sound/vox_fem/report.ogg',
"reports" = 'sound/vox_fem/reports.ogg',
"required" = 'sound/vox_fem/required.ogg',
"research" = 'sound/vox_fem/research.ogg',
"resevoir" = 'sound/vox_fem/resevoir.ogg',
"resistance" = 'sound/vox_fem/resistance.ogg',
"rest" = 'sound/vox_fem/rest.ogg',
"right" = 'sound/vox_fem/right.ogg',
"rocket" = 'sound/vox_fem/rocket.ogg',
"roger" = 'sound/vox_fem/roger.ogg',
"romeo" = 'sound/vox_fem/romeo.ogg',
"room" = 'sound/vox_fem/room.ogg',
"round" = 'sound/vox_fem/round.ogg',
"run" = 'sound/vox_fem/run.ogg',
"s" = 'sound/vox_fem/s.ogg',
"safe" = 'sound/vox_fem/safe.ogg',
"safety" = 'sound/vox_fem/safety.ogg',
"sarah" = 'sound/vox_fem/sarah.ogg',
"sargeant" = 'sound/vox_fem/sargeant.ogg',
"satellite" = 'sound/vox_fem/satellite.ogg',
"save" = 'sound/vox_fem/save.ogg',
"science" = 'sound/vox_fem/science.ogg',
"scream" = 'sound/vox_fem/scream.ogg',
"screen" = 'sound/vox_fem/screen.ogg',
"search" = 'sound/vox_fem/search.ogg',
"second" = 'sound/vox_fem/second.ogg',
"secondary" = 'sound/vox_fem/secondary.ogg',
"seconds" = 'sound/vox_fem/seconds.ogg',
"sector" = 'sound/vox_fem/sector.ogg',
"secure" = 'sound/vox_fem/secure.ogg',
"secured" = 'sound/vox_fem/secured.ogg',
"security" = 'sound/vox_fem/security.ogg',
"select" = 'sound/vox_fem/select.ogg',
"selected" = 'sound/vox_fem/selected.ogg',
"sensors" = 'sound/vox_fem/sensors.ogg',
"service" = 'sound/vox_fem/service.ogg',
"seven" = 'sound/vox_fem/seven.ogg',
"seventeen" = 'sound/vox_fem/seventeen.ogg',
"seventy" = 'sound/vox_fem/seventy.ogg',
"severe" = 'sound/vox_fem/severe.ogg',
"sewage" = 'sound/vox_fem/sewage.ogg',
"sewer" = 'sound/vox_fem/sewer.ogg',
"shield" = 'sound/vox_fem/shield.ogg',
"shipment" = 'sound/vox_fem/shipment.ogg',
"shirt" = 'sound/vox_fem/shirt.ogg',
"shit" = 'sound/vox_fem/shit.ogg',
"shitlord" = 'sound/vox_fem/shitlord.ogg',
"shits" = 'sound/vox_fem/shits.ogg',
"shitting" = 'sound/vox_fem/shitting.ogg',
"shock" = 'sound/vox_fem/shock.ogg',
"shoot" = 'sound/vox_fem/shoot.ogg',
"shower" = 'sound/vox_fem/shower.ogg',
"shut" = 'sound/vox_fem/shut.ogg',
"shuttle" = 'sound/vox_fem/shuttle.ogg',
"side" = 'sound/vox_fem/side.ogg',
"sierra" = 'sound/vox_fem/sierra.ogg',
"sight" = 'sound/vox_fem/sight.ogg',
"silo" = 'sound/vox_fem/silo.ogg',
"singularity" = 'sound/vox_fem/singularity.ogg',
"six" = 'sound/vox_fem/six.ogg',
"sixteen" = 'sound/vox_fem/sixteen.ogg',
"sixty" = 'sound/vox_fem/sixty.ogg',
"slime" = 'sound/vox_fem/slime.ogg',
"slow" = 'sound/vox_fem/slow.ogg',
"solar" = 'sound/vox_fem/solar.ogg',
"solars" = 'sound/vox_fem/solars.ogg',
"soldier" = 'sound/vox_fem/soldier.ogg',
"some" = 'sound/vox_fem/some.ogg',
"someone" = 'sound/vox_fem/someone.ogg',
"something" = 'sound/vox_fem/something.ogg',
"son" = 'sound/vox_fem/son.ogg',
"sorry" = 'sound/vox_fem/sorry.ogg',
"south" = 'sound/vox_fem/south.ogg',
"squad" = 'sound/vox_fem/squad.ogg',
"square" = 'sound/vox_fem/square.ogg',
"ss13" = 'sound/vox_fem/ss13.ogg',
"stairway" = 'sound/vox_fem/stairway.ogg',
"starboard" = 'sound/vox_fem/starboard.ogg',
"station" = 'sound/vox_fem/station.ogg',
"status" = 'sound/vox_fem/status.ogg',
"sterile" = 'sound/vox_fem/sterile.ogg',
"sterilization" = 'sound/vox_fem/sterilization.ogg',
"storage" = 'sound/vox_fem/storage.ogg',
"stuck" = 'sound/vox_fem/stuck.ogg',
"sub" = 'sound/vox_fem/sub.ogg',
"subsurface" = 'sound/vox_fem/subsurface.ogg',
"sudden" = 'sound/vox_fem/sudden.ogg',
"suffer" = 'sound/vox_fem/suffer.ogg',
"suit" = 'sound/vox_fem/suit.ogg',
"superconducting" = 'sound/vox_fem/superconducting.ogg',
"supercooled" = 'sound/vox_fem/supercooled.ogg',
"supply" = 'sound/vox_fem/supply.ogg',
"surface" = 'sound/vox_fem/surface.ogg',
"surrender" = 'sound/vox_fem/surrender.ogg',
"surround" = 'sound/vox_fem/surround.ogg',
"surrounded" = 'sound/vox_fem/surrounded.ogg',
"switch" = 'sound/vox_fem/switch.ogg',
"syndicate" = 'sound/vox_fem/syndicate.ogg',
"system" = 'sound/vox_fem/system.ogg',
"systems" = 'sound/vox_fem/systems.ogg',
"t" = 'sound/vox_fem/t.ogg',
"tactical" = 'sound/vox_fem/tactical.ogg',
"take" = 'sound/vox_fem/take.ogg',
"talk" = 'sound/vox_fem/talk.ogg',
"tango" = 'sound/vox_fem/tango.ogg',
"tank" = 'sound/vox_fem/tank.ogg',
"target" = 'sound/vox_fem/target.ogg',
"team" = 'sound/vox_fem/team.ogg',
"temperature" = 'sound/vox_fem/temperature.ogg',
"temporal" = 'sound/vox_fem/temporal.ogg',
"ten" = 'sound/vox_fem/ten.ogg',
"terminal" = 'sound/vox_fem/terminal.ogg',
"terminated" = 'sound/vox_fem/terminated.ogg',
"termination" = 'sound/vox_fem/termination.ogg',
"test" = 'sound/vox_fem/test.ogg',
"that" = 'sound/vox_fem/that.ogg',
"the" = 'sound/vox_fem/the.ogg',
"then" = 'sound/vox_fem/then.ogg',
"there" = 'sound/vox_fem/there.ogg',
"third" = 'sound/vox_fem/third.ogg',
"thirteen" = 'sound/vox_fem/thirteen.ogg',
"thirty" = 'sound/vox_fem/thirty.ogg',
"this" = 'sound/vox_fem/this.ogg',
"those" = 'sound/vox_fem/those.ogg',
"thousand" = 'sound/vox_fem/thousand.ogg',
"threat" = 'sound/vox_fem/threat.ogg',
"three" = 'sound/vox_fem/three.ogg',
"through" = 'sound/vox_fem/through.ogg',
"tide" = 'sound/vox_fem/tide.ogg',
"time" = 'sound/vox_fem/time.ogg',
"to" = 'sound/vox_fem/to.ogg',
"top" = 'sound/vox_fem/top.ogg',
"topside" = 'sound/vox_fem/topside.ogg',
"touch" = 'sound/vox_fem/touch.ogg',
"towards" = 'sound/vox_fem/towards.ogg',
"toxins" = 'sound/vox_fem/toxins.ogg',
"track" = 'sound/vox_fem/track.ogg',
"train" = 'sound/vox_fem/train.ogg',
"traitor" = 'sound/vox_fem/traitor.ogg',
"transportation" = 'sound/vox_fem/transportation.ogg',
"truck" = 'sound/vox_fem/truck.ogg',
"tunnel" = 'sound/vox_fem/tunnel.ogg',
"turn" = 'sound/vox_fem/turn.ogg',
"turret" = 'sound/vox_fem/turret.ogg',
"twelve" = 'sound/vox_fem/twelve.ogg',
"twenty" = 'sound/vox_fem/twenty.ogg',
"two" = 'sound/vox_fem/two.ogg',
"u" = 'sound/vox_fem/u.ogg',
"unauthorized" = 'sound/vox_fem/unauthorized.ogg',
"under" = 'sound/vox_fem/under.ogg',
"uniform" = 'sound/vox_fem/uniform.ogg',
"unlocked" = 'sound/vox_fem/unlocked.ogg',
"until" = 'sound/vox_fem/until.ogg',
"up" = 'sound/vox_fem/up.ogg',
"update" = 'sound/vox_fem/update.ogg',
"updated" = 'sound/vox_fem/updated.ogg',
"updating" = 'sound/vox_fem/updating.ogg',
"upload" = 'sound/vox_fem/upload.ogg',
"upper" = 'sound/vox_fem/upper.ogg',
"uranium" = 'sound/vox_fem/uranium.ogg',
"us" = 'sound/vox_fem/us.ogg',
"usa" = 'sound/vox_fem/usa.ogg',
"use" = 'sound/vox_fem/use.ogg',
"used" = 'sound/vox_fem/used.ogg',
"user" = 'sound/vox_fem/user.ogg',
"v" = 'sound/vox_fem/v.ogg',
"vacate" = 'sound/vox_fem/vacate.ogg',
"valid" = 'sound/vox_fem/valid.ogg',
"vapor" = 'sound/vox_fem/vapor.ogg',
"vent" = 'sound/vox_fem/vent.ogg',
"ventilation" = 'sound/vox_fem/ventilation.ogg',
"victor" = 'sound/vox_fem/victor.ogg',
"violated" = 'sound/vox_fem/violated.ogg',
"violation" = 'sound/vox_fem/violation.ogg',
"virology" = 'sound/vox_fem/virology.ogg',
"voltage" = 'sound/vox_fem/voltage.ogg',
"vox" = 'sound/vox_fem/vox.ogg',
"vox_login" = 'sound/vox_fem/vox_login.ogg',
"voxtest" = 'sound/vox_fem/voxtest.ogg',
"voxtest2" = 'sound/vox_fem/voxtest2.ogg',
"w" = 'sound/vox_fem/w.ogg',
"walk" = 'sound/vox_fem/walk.ogg',
"wall" = 'sound/vox_fem/wall.ogg',
"wanker" = 'sound/vox_fem/wanker.ogg',
"want" = 'sound/vox_fem/want.ogg',
"wanted" = 'sound/vox_fem/wanted.ogg',
"warm" = 'sound/vox_fem/warm.ogg',
"warn" = 'sound/vox_fem/warn.ogg',
"warning" = 'sound/vox_fem/warning.ogg',
"waste" = 'sound/vox_fem/waste.ogg',
"water" = 'sound/vox_fem/water.ogg',
"we" = 'sound/vox_fem/we.ogg',
"weapon" = 'sound/vox_fem/weapon.ogg',
"welcome" = 'sound/vox_fem/welcome.ogg',
"west" = 'sound/vox_fem/west.ogg',
"whiskey" = 'sound/vox_fem/whiskey.ogg',
"white" = 'sound/vox_fem/white.ogg',
"wilco" = 'sound/vox_fem/wilco.ogg',
"will" = 'sound/vox_fem/will.ogg',
"with" = 'sound/vox_fem/with.ogg',
"without" = 'sound/vox_fem/without.ogg',
"wood" = 'sound/vox_fem/wood.ogg',
"woody" = 'sound/vox_fem/woody.ogg',
"x" = 'sound/vox_fem/x.ogg',
"xeno" = 'sound/vox_fem/xeno.ogg',
"xenobiology" = 'sound/vox_fem/xenobiology.ogg',
"xenomorph" = 'sound/vox_fem/xenomorph.ogg',
"xenomorphs" = 'sound/vox_fem/xenomorphs.ogg',
"y" = 'sound/vox_fem/y.ogg',
"yankee" = 'sound/vox_fem/yankee.ogg',
"yards" = 'sound/vox_fem/yards.ogg',
"year" = 'sound/vox_fem/year.ogg',
"yellow" = 'sound/vox_fem/yellow.ogg',
"yes" = 'sound/vox_fem/yes.ogg',
"you" = 'sound/vox_fem/you.ogg',
"your" = 'sound/vox_fem/your.ogg',
"yourself" = 'sound/vox_fem/yourself.ogg',
"z" = 'sound/vox_fem/z.ogg',
"zero" = 'sound/vox_fem/zero.ogg',
"zone" = 'sound/vox_fem/zone.ogg',
"zulu" = 'sound/vox_fem/zulu.ogg',
)
#endif