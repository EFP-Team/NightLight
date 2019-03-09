//Darkmode preference by Kmc2000//

/*
This lets you switch chat themes by using winset and CSS loading, you must relog to see this change (or rebuild your browseroutput datum)

Things to note:
If you change ANYTHING in interface/skin.dmf you need to change it here:
Format:
winset(src, "window as appears in skin.dmf after elem", "var to change = currentvalue;var to change = desired value")
*/

/client/proc/force_white_theme() //There's no way round it. We're essentially changing the skin by hand. It's painful but it works, and is the way Lummox suggested.
	//Main windows
	winset(src, "infowindow", "background-color = #2c2f33;background-color = none")
	winset(src, "infowindow", "text-color = #99aab5;text-color = #000000")
	winset(src, "info", "background-color = #272727;background-color = none")
	winset(src, "info", "text-color = #99aab5;text-color = #000000")
	winset(src, "browseroutput", "background-color = #272727;background-color = none")
	winset(src, "browseroutput", "text-color = #99aab5;text-color = #000000")
	winset(src, "outputwindow", "background-color = #272727;background-color = none")
	winset(src, "outputwindow", "text-color = #99aab5;text-color = #000000")
	winset(src, "mainwindow", "background-color = #2c2f33;background-color = none")
	winset(src, "split", "background-color = #272727;background-color = none")
	//Buttons
	winset(src, "changelog", "background-color = #494949;background-color = none")
	winset(src, "changelog", "text-color = #99aab5;text-color = #000000")
	winset(src, "rules", "background-color = #494949;background-color = none")
	winset(src, "rules", "text-color = #99aab5;text-color = #000000")
	winset(src, "wiki", "background-color = #494949;background-color = none")
	winset(src, "wiki", "text-color = #99aab5;text-color = #000000")
	winset(src, "forum", "background-color = #494949;background-color = none")
	winset(src, "forum", "text-color = #99aab5;text-color = #000000")
	winset(src, "github", "background-color = #3a3a3a;background-color = none")
	winset(src, "github", "text-color = #99aab5;text-color = #000000")
	winset(src, "report-issue", "background-color = #492020;background-color = none")
	winset(src, "report-issue", "text-color = #99aab5;text-color = #000000")
	//Status and verb tabs
	winset(src, "output", "background-color = #272727;background-color = none")
	winset(src, "output", "text-color = #99aab5;text-color = #000000")
	winset(src, "outputwindow", "background-color = #272727;background-color = none")
	winset(src, "outputwindow", "text-color = #99aab5;text-color = #000000")
	winset(src, "statwindow", "background-color = #272727;background-color = none")
	winset(src, "statwindow", "text-color = #eaeaea;text-color = #000000")
	winset(src, "stat", "background-color = #2c2f33;background-color = #FFFFFF")
	winset(src, "stat", "tab-background-color = #272727;tab-background-color = #FFFFFF")
	winset(src, "stat", "text-color = #99aab5;text-color = #000000")
	winset(src, "stat", "tab-text-color = #99aab5;tab-text-color = #000000")
	//Say, OOC, me Buttons etc.
	winset(src, "saybutton", "background-color = #272727;background-color = none")
	winset(src, "saybutton", "text-color = #99aab5;text-color = #000000")
	winset(src, "oocbutton", "background-color = #272727;background-color = none")
	winset(src, "oocbutton", "text-color = #99aab5;text-color = #000000")
	winset(src, "mebutton", "background-color = #272727;background-color = none")
	winset(src, "mebutton", "text-color = #99aab5;text-color = #000000")
	winset(src, "asset_cache_browser", "background-color = #272727;background-color = none")
	winset(src, "asset_cache_browser", "text-color = #99aab5;text-color = #000000")
	winset(src, "tooltip", "background-color = #272727;background-color = none")
	winset(src, "tooltip", "text-color = #99aab5;text-color = #000000")

/datum/asset/group/goonchat/white //White theme goonchat assets, these are loaded instead of the standard dark theme assets
	children = list(
		/datum/asset/simple/jquery,
		/datum/asset/simple/goonchat/white,
		/datum/asset/spritesheet/goonchat
	)

/datum/asset/simple/goonchat/white
	verify = FALSE
	assets = list(
		"json2.min.js"             = 'code/modules/goonchat/browserassets/js/json2.min.js',
		"errorHandler.js"          = 'code/modules/goonchat/browserassets/js/errorHandler.js',
		"browserOutput.js"         = 'code/modules/goonchat/browserassets/js/browserOutput.js',
		"fontawesome-webfont.eot"  = 'tgui/assets/fonts/fontawesome-webfont.eot',
		"fontawesome-webfont.svg"  = 'tgui/assets/fonts/fontawesome-webfont.svg',
		"fontawesome-webfont.ttf"  = 'tgui/assets/fonts/fontawesome-webfont.ttf',
		"fontawesome-webfont.woff" = 'tgui/assets/fonts/fontawesome-webfont.woff',
		"font-awesome.css"	       = 'code/modules/goonchat/browserassets/css/font-awesome.css',
		"browserOutput.css"	       = 'code/modules/goonchat/browserassets/css/browserOutput_white.css',
	)