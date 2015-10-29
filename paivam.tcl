##
##	Päivämäärät by T-101 / Darklite ^ Primitive
##
##	Yells out finnish namedays, number of the week and 
##	and some other funny stuff related to dat. All in Finnish.
##
##	Usage: !pvm		# usually this runs daily
##
##	You must set the "kanavat" variable to fit your needs
##	This script will shout out to all of them
##
##	The "announceHour" variable is the hour of day
##	this will bind to
##
##	Use at own risk, and be nice towards the entities that
##	made possible such awesome, and free services
##
##	2015 | darklite.org | primitive.be | IRCNet
##
##
##	Version history:
##		1.0	-	Initial release

namespace eval ::pvm {

## add channels HERE
set kanavat "#justsesunkanava"

##	Change daily hour HERE
set announceHour 05

##
##	After this, here be dragons
##

set pvmVersion 1.0

bind time - "00 $announceHour % % %" ::pvm::announce
bind pub - !pvm ::pvm::announce

package require http

proc getHoliday {} {
	set juhlaPaivat {
		"01.01 Uudenvuodenpäivä"
		"06.01 Loppiainen"
		"05.02 Runebergin päivä"
		"14.02 Ystävänpäivä"
		"28.02 Kalevalan päivä"
		"08.03 Naistenpäivä"
		"19.03 Minna Canthin päivä, tasa-arvon päivä"
		"01.04 Aprillipäivä"
		"09.04 Mikael Agricolan päivä, suomen kielen päivä"
		"27.04 Kansallinen veteraanipäivä"
		"01.05 Suomalaisen työn päivä eli Vappu"
		"09.05 Eurooppa-päivä"
		"12.05 J.V. Snellmanin päivä, suomalaisuuden päivä"
		"04.06 Puolustusvoimain lippujuhla"
		"06.06 Eino Leinon päivä, runon päivä"
		"09.06 Ahvenanmaan itsehallintopäivä"
		"06.07 Runon ja suven päivä, Eino Leinon päivä"
		"17.07 Kansanvallan päivä"
		"23.07 Mätäkuu alkaa"
		"27.07 Unikeonpäivä"
		"20.08 Kansallinen tykityspäivä"
		"23.08 Mätäkuu loppuu"
		"04.10 Maailman eläinten päivä"
		"10.10 Aleksis Kiven päivä, suomalaisen kirjallisuuden päivä"
		"24.10 Yhdistyneiden kansakuntien (YK:n) päivä"
		"06.11 Svenska dagen eli ruotsalaisuuden päivä"
		"06.12 Suomen itsenäisyyspäivä"
		"08.12 Jean Sibeliuksen päivä, suomalaisen musiikin päivä"
		"13.12 Lucian päivä"
		"24.12 Jouluaatto"
		"25.12 Joulupäivä"
		"26.12 2. joulupäivä, Tapaninpäivä"
		"28.12 Viattomien lasten päivä"
	}

	lappend liikkuvat {03/25 03/31 Sun "Kesäaika alkaa. Siirrä kelloja tunnilla eteenpäin."}
	lappend liikkuvat {05/08 05/14 Sun "Äitienpäivä"}
	lappend liikkuvat {05/15 05/21 Sun "Kaatuneiden muistopäivä"}
	lappend liikkuvat {06/19 06/25 Fri "Juhannusaatto"}
	lappend liikkuvat {06/20 06/26 Sat "Juhannus"}
	lappend liikkuvat {10/25 10/31 Sun "Kesäaika päättyy. Siirrä kelloja tunnilla taaksepäin."}
	lappend liikkuvat {10/31 11/06 Sat "Pyhäinpäivä"}
	lappend liikkuvat {11/08 11/14 Sun "Isänpäivä"}
	lappend paasiainen {-49	"Laskiaissunnuntai"}
	lappend paasiainen {-47	"Laskiaistiistai"}
	lappend paasiainen {-7	"Palmusunnuntai"}
	lappend paasiainen {-3	"Kiirastorstai"}
	lappend paasiainen {-2	"Pitkäperjantai"}
	lappend paasiainen {-1	"Lankalauantai"}
	lappend paasiainen {0	"Pääsiäinen"}
	lappend paasiainen {1	"Toinen Pääsiäispäivä"}
	lappend paasiainen {39	"Helatorstai"}
	lappend paasiainen {49	"Helluntai"}

	# check static holidays
	set date [clock format [clock seconds] -format {%d.%m}]
	if {[lsearch $juhlaPaivat ${date}*] != -1} {
		lappend output [lrange [lindex $juhlaPaivat [lsearch $juhlaPaivat ${date}*]] 1 end]
	}
	# check alternating holidays
        set date [clock scan [clock format [clock seconds] -format {%m/%d}]]
	foreach item $liikkuvat {
		set inDate [clock scan [lindex $item 0]]
		set outDate [clock scan [lindex $item 1]]
		set weekday [clock format [clock seconds] -format %a]
		if {$date >= $inDate && $date <= $outDate && $weekday == [lindex $item 2]} { lappend output [lindex $item 3] }
	}
	# check easter related holidays
	set y [clock format [clock seconds] -format %Y]
	set paschal [expr (3 - (11 * (($y % 19) + 1)) + ($y - 1600) / 100 - ($y - 1600) / 400 - ((($y - 1400) / 100) * 8) / 25) % 30]
	if {$paschal == 29 || ($paschal == 28 && [expr (($y % 19) + 1)] > 11)} {
		set p [expr $paschal - 1] } else { set p $paschal }
	set e [expr $p + ((((8 - ($y + ($y / 4) - ($y / 100) + ($y / 400)) % 7) % 7 - (80 + $p) % 7) - 1) % 7 + 1)]
	if {$e < 11} {
		set easter "[clock scan 03/[expr $e + 21]/$y]"
	} else {
		set easter "[clock scan 04/[expr $e - 10]/$y]"
	}
	foreach item $paasiainen {
		set checkAgainst [clock scan "[lindex $item 0] day" -base $easter]
		if {$date == $checkAgainst} { lappend output [lindex $item 1] }
	}
	# output holiday infoes, if any
	if {[info exists output]} {return ". ([join $output ", "])"}
}

proc getNameday {} {
	set date [clock format [clock seconds] -format {%d.%m}]
	set url http://nimihaku.helsinki.fi/nimihaku.php
	set query [::http::formatQuery paiva ${date}. nimi "" kanta suomi submit Hae]
	set userAgent "Chrome 45.0.2454.101"
	::http::config -useragent $userAgent
	set httpHandler [::http::geturl $url -query $query]
	set text [::http::data $httpHandler]
	::http::cleanup $httpHandler

	set lines [split $text "\n"]
	foreach line [lsearch -all $lines "*td*"] {
		lappend results [string trim [regsub -all {<([^<])*>} [lindex $lines $line] {}]]
	}
	if {[info exists results]} {
		return " ja nimipäivää viettävät: [join [lsort $results] ", "]"
	}
}

proc getDate {} {
	set dayMap {1 "Maanantai" 2 "Tiistai" 3 "Keskiviikko" 4 "Torstai" 5 "Perjantai" 6 "Lauantai" 0 "Sunnuntai"}
	set clock [clock seconds]
	set date [string trim [clock format $clock -format {%e.%m.%Y}]]
	set day [string map $dayMap [clock format $clock -format %w]]
	set weekNumber [expr [clock format $clock -format %W] + 1]
	return "Tänään on $day $date (Viikko $weekNumber)"
}

proc getMerkkipaiva {} {

        set url "http://www.webcal.fi/fi-FI/popup.php?content=eventlist&cid=31"
        set userAgent "Chrome 45.0.2454.101"
        ::http::config -useragent $userAgent
        set httpHandler [::http::geturl $url]
        set html [split [::http::data $httpHandler] "\n"]
        ::http::cleanup $httpHandler

	set date [clock format [clock seconds] -format <td>%d.%m.]
	for { set i 0 } { $i < [llength $html] } { incr i } {
        	if {[regexp $date [lindex $html $i]]} {
			lappend results [string trim [regsub -all {<([^<])*>} [lindex $html [expr $i - 2]] {}]]
        	}
	}
	unset -nocomplain html
	if {[info exists results]} {
		return "Merkkipäiviä tänään: [join $results ", "]"
	}
}

proc outputNameday {} {
	return "[getDate][getNameday][getHoliday]"
}

proc announce { args } {
	variable kanavat
	if {[string index [lindex $args 3] 0] == "#"} {
		# called via !pvm
		putquick "NOTICE [lindex $args 3] :[outputNameday]"
		putquick "NOTICE [lindex $args 3] :[getMerkkipaiva]"
	} else {
		# called via cron
		foreach kanava [split $kanavat] {
        	        putquick "NOTICE $kanava :[outputNameday]"
	                putquick "NOTICE $kanava :[getMerkkipaiva]"

		}
	}

}

putlog "pvm.tcl pvmVersion by T-101 loaded!"

}
