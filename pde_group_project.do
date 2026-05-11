/* Replication Code Partnership Ideology
Authors: Bova Marco, Cinti Emanuele,  Engeler Guia, Picci Miriam
*/

local user "`c(username)'"
di as text "User: `user'"


/* Pick path (single data folder) */
if ("`user'" == "miria") {
    global path "C:\Users\miria\Downloads\BOCCONI\ESS\POP DYN\RHYMÄTYÖ"
}
else if ("`user'" == "emanuelecinti") {
    global path "/Users/emanuelecinti/Documents/Personal Hub/Learning Hub/Master/Population dynamics/Project"
}
else if ("`user'" == "Bova") {
    global path "/Users/Bova/Documents/Personal/PDE GROUP PROJECT"
}
else if ("`user'" == "") {
    global path ""
}
else {
    global path "`c(pwd)'"   
}

* Project subfolders (relative to $path)
global datapath    "$path"
global resultspath "$path/Results"

* Make sure Results/figs exists
capture mkdir "$resultspath"
capture mkdir "$resultspath/figs"

* Go to Data folder
cd "$datapath"

************************************************************
**# 				       CLEANING 					 ***
************************************************************

use "UNFPA_PILOT_v2.dta", clear


rename S1 sex

rename S2 age

rename S4 country_residence

rename Q8 marital_status

rename Q9 relationship_status

rename Q41 employment

bysort country: gen n_country = _N

* Ideals - Traditional

rename Q30r1oe fert_ideal_life_trad
replace fert_ideal_life_trad=Q30 if fert_ideal_life_trad==.

replace fert_ideal_life_trad=. if fert_ideal_life_trad==98 | fert_ideal_life_trad==99 | fert_ideal_life_trad==998 | fert_ideal_life_trad==999

gen fert_ideal_life_trad_dummy_0c = (fert_ideal_life_trad==0) if fert_ideal_life_trad!=.
gen fert_ideal_life_trad_dummy_1c = (fert_ideal_life_trad==1) if fert_ideal_life_trad!=.
gen fert_ideal_life_trad_dummy_2c = (fert_ideal_life_trad==2) if fert_ideal_life_trad!=.
gen fert_ideal_life_trad_dummy_3c = (fert_ideal_life_trad==3) if fert_ideal_life_trad!=.
gen fert_ideal_life_trad_dummy_4c = (fert_ideal_life_trad==4) if fert_ideal_life_trad!=.
gen fert_ideal_life_trad_dummy_5c = (fert_ideal_life_trad==5) if fert_ideal_life_trad!=. //Note: do >= so 5+ when comparing to rating qs (rating is also 5+). 
gen fert_ideal_life_trad_dummy_6c = (fert_ideal_life_trad==6) if fert_ideal_life_trad!=. 
gen fert_ideal_life_trad_dummy_7c = (fert_ideal_life_trad==7) if fert_ideal_life_trad!=. 
gen fert_ideal_life_trad_dummy_8c = (fert_ideal_life_trad>=8) if fert_ideal_life_trad!=. //Note: beter 8+ if comparing to intentions. Then make also intentions 8+


* Ideals - New rating questions

rename Q31r1 fert_ideal_life_rating_0c
rename Q31r2 fert_ideal_life_rating_1c
rename Q31r3 fert_ideal_life_rating_2c
rename Q31r4 fert_ideal_life_rating_3c
rename Q31r5 fert_ideal_life_rating_4c
rename Q31r6 fert_ideal_life_rating_5c

foreach i of numlist 0/5 {
replace fert_ideal_life_rating_`i'c=. if fert_ideal_life_rating_`i'c==99
}

gen fert_ideal_life_rating_sum = fert_ideal_life_rating_0c+fert_ideal_life_rating_1c+fert_ideal_life_rating_2c+fert_ideal_life_rating_3c+fert_ideal_life_rating_4c +fert_ideal_life_rating_5c  //Note: not sure if to include 5+ children because then rating goes upward compared to traditional question. Otherwise any symmetric rating around 2 gives weighted mean of 2

gen fert_ideal_life_rating_0c_rel = fert_ideal_life_rating_0c/fert_ideal_life_rating_sum
gen fert_ideal_life_rating_1c_rel = fert_ideal_life_rating_1c/fert_ideal_life_rating_sum
gen fert_ideal_life_rating_2c_rel = fert_ideal_life_rating_2c/fert_ideal_life_rating_sum
gen fert_ideal_life_rating_3c_rel = fert_ideal_life_rating_3c/fert_ideal_life_rating_sum
gen fert_ideal_life_rating_4c_rel = fert_ideal_life_rating_4c/fert_ideal_life_rating_sum
gen fert_ideal_life_rating_5c_rel = fert_ideal_life_rating_5c/fert_ideal_life_rating_sum

//gen fert_ideal_life_rating = (fert_ideal_life_rating_0c*0 + fert_ideal_life_rating_1c*1 + fert_ideal_life_rating_2c*2 + fert_ideal_life_rating_3c*3 + fert_ideal_life_rating_4c*4) / (fert_ideal_life_rating_0c + fert_ideal_life_rating_1c + fert_ideal_life_rating_2c + fert_ideal_life_rating_3c + fert_ideal_life_rating_4c)

gen fert_ideal_life_rating = (fert_ideal_life_rating_0c*0 + fert_ideal_life_rating_1c*1 + fert_ideal_life_rating_2c*2 + fert_ideal_life_rating_3c*3 + fert_ideal_life_rating_4c*4 + fert_ideal_life_rating_5c*5) / (fert_ideal_life_rating_0c + fert_ideal_life_rating_1c + fert_ideal_life_rating_2c + fert_ideal_life_rating_3c + fert_ideal_life_rating_4c + fert_ideal_life_rating_5c)

//bysort country: tab fert_ideal_life_trad , miss
//bysort country: sum  fert_ideal_life_trad fert_ideal_life_rating   


* Fertility Realizations 

rename Q22 nchildren
replace nchildren=. if nchildren==999

gen nchildren_dummy_0c = (nchildren==0) if nchildren!=.
gen nchildren_dummy_1c = (nchildren==1) if nchildren!=.
gen nchildren_dummy_2c = (nchildren==2) if nchildren!=.
gen nchildren_dummy_3c = (nchildren==3) if nchildren!=.
gen nchildren_dummy_4c = (nchildren==4) if nchildren!=.
gen nchildren_dummy_5c = (nchildren==5) if nchildren!=. 
gen nchildren_dummy_6c = (nchildren==6) if nchildren!=. 
gen nchildren_dummy_7c = (nchildren==7) if nchildren!=. 
gen nchildren_dummy_8c = (nchildren>=8) if nchildren!=. //Note: not sure if to make 8+ or to drop but I think better 8+


* Intentions - Lifetime

rename Q29r1oe fert_intent_life
replace fert_intent_life=Q29 if fert_intent_life==.

replace fert_intent_life=. if fert_intent_life==98 | fert_intent_life==99 | fert_intent_life==998 | fert_intent_life==999

rename fert_intent_life additional_fert_intent_life

gen fert_intent_life=.
replace fert_intent_life = additional_fert_intent_life + nchildren //Note: fert intentions ask only for additional intentions

//bysort country: sum  nchildren fert_intent_life fert_ideal_life_trad    

gen fert_intent_life_dummy_0c = (fert_intent_life==0) if fert_intent_life!=.
gen fert_intent_life_dummy_1c = (fert_intent_life==1) if fert_intent_life!=.
gen fert_intent_life_dummy_2c = (fert_intent_life==2) if fert_intent_life!=.
gen fert_intent_life_dummy_3c = (fert_intent_life==3) if fert_intent_life!=.
gen fert_intent_life_dummy_4c = (fert_intent_life==4) if fert_intent_life!=.
gen fert_intent_life_dummy_5c = (fert_intent_life==5) if fert_intent_life!=. 
gen fert_intent_life_dummy_6c = (fert_intent_life==6) if fert_intent_life!=. 
gen fert_intent_life_dummy_7c = (fert_intent_life==7) if fert_intent_life!=. 
gen fert_intent_life_dummy_8c = (fert_intent_life>=8) if fert_intent_life!=. //Note: not sure if to make 8+ or to drop but I think better 8+

*recode the liberal variables 

recode Q19 (1 = 5 ) (2 = 2) (3 = 1) (4=3) (5=4) (99=99)

*recode Q17r4 this is not a key variable

recode Q17r4 (1 = 5 ) (2 = 4) (3 = 3) (4=2) (5=1) (99=99)

*to be included Q18r5, Q33r3 Q33r7 

save "UNFPA_PILOT_cleaned.dta",replace

*-----------------------------------------------------------------------------
* Shortlisted Variable selection (and 17.4, Q18r5, Q33r3, Q33r7 for later comparison)
*-----------------------------------------------------------------------------

use "UNFPA_PILOT_cleaned.dta", clear

local xlabopt "xlabel(1(1)5)"

local items ""

capture ds Q3Fr*
if !_rc local items "`items' `r(varlist)'"

capture ds Q3Mr*
if !_rc local items "`items' `r(varlist)'"

* add specific extra variables
foreach v in Q16r7 Q16r8 Q19 Q17r4 Q18r5 Q33r3 Q33r7 {
    capture confirm variable `v'
    if !_rc local items "`items' `v'"
}

local items : list uniq items

* variables needed for plotting
local basevars country sex relationship_status Q40

* keep plotting vars + grouping vars
local keepvars `basevars' `items'
local keepvars : list uniq keepvars

di as text "Plotting items:"
di as result "`items'"

di as text "Keeping variables for graphing:"
di as result "`keepvars'"

keep `keepvars'
compress

save "UNFPA_PILOT_pde_group_project.dta",replace


/********************************************************************
PANELS (6 subplots per item):
  Panel A: Sex only (Male vs Female)
  Panel B: Sex x Education (6 lines)

Countries: Sweden (1) and South Korea (5)
Relationship groups from Q9 = relationship_status:
  Single = 1
  Dating = 2
  Stable = 3–6
********************************************************************/

use "UNFPA_PILOT_pde_group_project.dta", clear
set graphics off

local outdir "$path/Results/figs"

*------------------*
* Constants
*------------------*
local SWE 1
local KOR 5

local male   2
local female 1

*------------------*
* Education groups from Q40
*------------------*
gen edu3 = .
replace edu3 = 1 if inlist(Q40,1,2)
replace edu3 = 2 if Q40==3
replace edu3 = 3 if Q40==4
replace edu3 = . if Q40==99 | missing(Q40)

label define edu3lbl 1 "Low" 2 "Mid" 3 "High", replace
label values edu3 edu3lbl

*------------------*
* Relationship groups from relationship_status = Q9
*------------------*
gen rel3 = .
replace rel3 = 1 if relationship_status==1
replace rel3 = 2 if relationship_status==2
replace rel3 = 3 if inrange(relationship_status,3,6)

label define rel3lbl 1 "Single" 2 "Dating" 3 "Stable", replace
label values rel3 rel3lbl

*======================================================*
* LOOP OVER ITEMS
*======================================================*
foreach v of local items {

    capture confirm variable `v'
    if _rc continue

    *----------------------------------*
    * Filename classification
    *----------------------------------*

    * Short label
    local vlabtext : variable label `v'
    if `"`vlabtext'"' == "" local vlabtext "`v'"
    local vlabshort = substr(`"`vlabtext'"',1,60)
    if length(`"`vlabtext'"') > 60 local vlabshort "`vlabshort'..."

    *------------------------------*
    * Make the 6 small graphs (SEX)
    *------------------------------*

    * --- SWE / Single
    preserve
        keep if country==`SWE' & rel3==1
        keep sex `v'
        drop if missing(sex) | missing(`v')
        keep if inlist(sex,`male',`female')
        keep if inrange(`v',1,5)
        contract sex `v', freq(N)
        by sex: egen T = total(N)
        gen pct = 100*N/T
        gen x = .
        replace x = `v'
        quietly twoway ///
            (connected pct x if sex==`male',   sort lcolor(blue) msymbol(O) mcolor(blue)) ///
            (connected pct x if sex==`female', sort lcolor(red)  msymbol(D) mcolor(red)) ///
            , title("Sweden - Single", size(small)) ///
              legend(off) xtitle("") ytitle("Percent") ///
              `xlabopt' ylabel(0(20)100) ///
              name(gS1, replace)
    restore

    * --- SWE / Dating
    preserve
        keep if country==`SWE' & rel3==2
        keep sex `v'
        drop if missing(sex) | missing(`v')
        keep if inlist(sex,`male',`female')
        keep if inrange(`v',1,5)
        contract sex `v', freq(N)
        by sex: egen T = total(N)
        gen pct = 100*N/T
        gen x = .
        replace x = `v'
        quietly twoway ///
            (connected pct x if sex==`male',   sort lcolor(blue) msymbol(O) mcolor(blue)) ///
            (connected pct x if sex==`female', sort lcolor(red)  msymbol(D) mcolor(red)) ///
            , title("Sweden - Dating", size(small)) ///
              legend(off) xtitle("") ytitle("Percent") ///
              `xlabopt' ylabel(0(20)100) ///
              name(gS2, replace)
    restore

    * --- SWE / Stable
    preserve
        keep if country==`SWE' & rel3==3
        keep sex `v'
        drop if missing(sex) | missing(`v')
        keep if inlist(sex,`male',`female')
        keep if inrange(`v',1,5)
        contract sex `v', freq(N)
        by sex: egen T = total(N)
        gen pct = 100*N/T
        gen x = .
        replace x = `v'
        quietly twoway ///
            (connected pct x if sex==`male',   sort lcolor(blue) msymbol(O) mcolor(blue)) ///
            (connected pct x if sex==`female', sort lcolor(red)  msymbol(D) mcolor(red)) ///
            , title("Sweden - Stable", size(small)) ///
              legend(off) xtitle("") ytitle("Percent") ///
              `xlabopt' ylabel(0(20)100) ///
              name(gS3, replace)
    restore

    * --- KOR / Single
    preserve
        keep if country==`KOR' & rel3==1
        keep sex `v'
        drop if missing(sex) | missing(`v')
        keep if inlist(sex,`male',`female')
        keep if inrange(`v',1,5)
        contract sex `v', freq(N)
        by sex: egen T = total(N)
        gen pct = 100*N/T
		gen x = .
        replace x = `v'
        quietly twoway ///
            (connected pct x if sex==`male',   sort lcolor(blue) msymbol(O) mcolor(blue)) ///
            (connected pct x if sex==`female', sort lcolor(red)  msymbol(D) mcolor(red)) ///
            , title("South Korea - Single", size(small)) ///
              legend(off) xtitle("") ytitle("Percent") ///
              `xlabopt' ylabel(0(20)100) ///
              name(gS4, replace)
    restore

    * --- KOR / Dating
    preserve
        keep if country==`KOR' & rel3==2
        keep sex `v'
        drop if missing(sex) | missing(`v')
        keep if inlist(sex,`male',`female')
        keep if inrange(`v',1,5)
        contract sex `v', freq(N)
        by sex: egen T = total(N)
        gen pct = 100*N/T
		gen x = .
        replace x = `v'
        quietly twoway ///
            (connected pct x if sex==`male',   sort lcolor(blue) msymbol(O) mcolor(blue)) ///
            (connected pct x if sex==`female', sort lcolor(red)  msymbol(D) mcolor(red)) ///
            , title("South Korea - Dating", size(small)) ///
              legend(off) xtitle("") ytitle("Percent") ///
              `xlabopt' ylabel(0(20)100) ///
              name(gS5, replace)
    restore

    * --- KOR / Stable
    preserve
        keep if country==`KOR' & rel3==3
        keep sex `v'
        drop if missing(sex) | missing(`v')
        keep if inlist(sex,`male',`female')
        keep if inrange(`v',1,5)
        contract sex `v', freq(N)
        by sex: egen T = total(N)
        gen pct = 100*N/T
		gen x = .
        replace x = `v'
        quietly twoway ///
            (connected pct x if sex==`male',   sort lcolor(blue) msymbol(O) mcolor(blue)) ///
            (connected pct x if sex==`female', sort lcolor(red)  msymbol(D) mcolor(red)) ///
            , title("South Korea - Stable", size(small)) ///
              legend(off) xtitle("") ytitle("Percent") ///
              `xlabopt' ylabel(0(20)100) ///
              name(gS6, replace)
    restore

    graph combine gS1 gS2 gS3 gS4 gS5 gS6, ///
        cols(3) ///
        title("`v'", size(medsmall)) ///
        subtitle("`vlabshort'", size(vsmall)) ///
        name(PANEL_SEX, replace)

     graph export "`outdir'/PANEL_SEX_`v'.png", ///
        name(PANEL_SEX) replace width(3600)

    capture graph drop gS1 gS2 gS3 gS4 gS5 gS6
    capture graph drop PANEL_SEX

    *------------------------------*
    * Make the 6 small graphs (SEX x EDU)
    *------------------------------*

    * --- SWE / Single
    preserve
        keep if country==`SWE' & rel3==1
        keep sex edu3 `v'
        drop if missing(sex) | missing(edu3) | missing(`v')
        keep if inlist(sex,`male',`female')
        keep if inrange(`v',1,5)
        contract sex edu3 `v', freq(N)
        by sex edu3: egen T = total(N)
        gen pct = 100*N/T
        gen x = .
        replace x = `v'
        quietly twoway ///
            (connected pct x if sex==`male'   & edu3==1, sort lcolor(black)    msymbol(O) mcolor(black)) ///
            (connected pct x if sex==`male'   & edu3==2, sort lcolor(blue)     msymbol(O) mcolor(blue)) ///
            (connected pct x if sex==`male'   & edu3==3, sort lcolor(eltblue)  msymbol(O) mcolor(eltblue)) ///
            (connected pct x if sex==`female' & edu3==1, sort lcolor(purple)   msymbol(D) mcolor(purple)) ///
            (connected pct x if sex==`female' & edu3==2, sort lcolor(red)      msymbol(D) mcolor(red)) ///
            (connected pct x if sex==`female' & edu3==3, sort lcolor(pink*0.5) msymbol(D) mcolor(pink*0.5)) ///
            , title("Sweden - Single", size(small)) ///
              legend(off) xtitle("") ytitle("Percent") ///
              `xlabopt' ylabel(0(20)100) ///
              name(gE1, replace)
    restore

    * --- SWE / Dating
    preserve
        keep if country==`SWE' & rel3==2
        keep sex edu3 `v'
        drop if missing(sex) | missing(edu3) | missing(`v')
        keep if inlist(sex,`male',`female')
        keep if inrange(`v',1,5)
        contract sex edu3 `v', freq(N)
        by sex edu3: egen T = total(N)
        gen pct = 100*N/T
        gen x = .
        replace x = `v'
        quietly twoway ///
            (connected pct x if sex==`male'   & edu3==1, sort lcolor(black)    msymbol(O) mcolor(black)) ///
            (connected pct x if sex==`male'   & edu3==2, sort lcolor(blue)     msymbol(O) mcolor(blue)) ///
            (connected pct x if sex==`male'   & edu3==3, sort lcolor(eltblue)  msymbol(O) mcolor(eltblue)) ///
            (connected pct x if sex==`female' & edu3==1, sort lcolor(purple)   msymbol(D) mcolor(purple)) ///
            (connected pct x if sex==`female' & edu3==2, sort lcolor(red)      msymbol(D) mcolor(red)) ///
            (connected pct x if sex==`female' & edu3==3, sort lcolor(pink*0.5) msymbol(D) mcolor(pink*0.5)) ///
            , title("Sweden - Dating", size(small)) ///
              legend(off) xtitle("") ytitle("Percent") ///
              `xlabopt' ylabel(0(20)100) ///
              name(gE2, replace)
    restore

    * --- SWE / Stable
    preserve
        keep if country==`SWE' & rel3==3
        keep sex edu3 `v'
        drop if missing(sex) | missing(edu3) | missing(`v')
        keep if inlist(sex,`male',`female')
        keep if inrange(`v',1,5)
        contract sex edu3 `v', freq(N)
        by sex edu3: egen T = total(N)
        gen pct = 100*N/T
        gen x = .
        replace x = `v'
        quietly twoway ///
            (connected pct x if sex==`male'   & edu3==1, sort lcolor(black)    msymbol(O) mcolor(black)) ///
            (connected pct x if sex==`male'   & edu3==2, sort lcolor(blue)     msymbol(O) mcolor(blue)) ///
            (connected pct x if sex==`male'   & edu3==3, sort lcolor(eltblue)  msymbol(O) mcolor(eltblue)) ///
            (connected pct x if sex==`female' & edu3==1, sort lcolor(purple)   msymbol(D) mcolor(purple)) ///
            (connected pct x if sex==`female' & edu3==2, sort lcolor(red)      msymbol(D) mcolor(red)) ///
            (connected pct x if sex==`female' & edu3==3, sort lcolor(pink*0.5) msymbol(D) mcolor(pink*0.5)) ///
            , title("Sweden - Stable", size(small)) ///
              legend(off) xtitle("") ytitle("Percent") ///
              `xlabopt' ylabel(0(20)100) ///
              name(gE3, replace)
    restore

    * --- KOR / Single
    preserve
        keep if country==`KOR' & rel3==1
        keep sex edu3 `v'
        drop if missing(sex) | missing(edu3) | missing(`v')
        keep if inlist(sex,`male',`female')
        keep if inrange(`v',1,5)
        contract sex edu3 `v', freq(N)
        by sex edu3: egen T = total(N)
        gen pct = 100*N/T
        gen x = .
        replace x = `v'
        quietly twoway ///
            (connected pct x if sex==`male'   & edu3==1, sort lcolor(black)    msymbol(O) mcolor(black)) ///
            (connected pct x if sex==`male'   & edu3==2, sort lcolor(blue)     msymbol(O) mcolor(blue)) ///
            (connected pct x if sex==`male'   & edu3==3, sort lcolor(eltblue)  msymbol(O) mcolor(eltblue)) ///
            (connected pct x if sex==`female' & edu3==1, sort lcolor(purple)   msymbol(D) mcolor(purple)) ///
            (connected pct x if sex==`female' & edu3==2, sort lcolor(red)      msymbol(D) mcolor(red)) ///
            (connected pct x if sex==`female' & edu3==3, sort lcolor(pink*0.5) msymbol(D) mcolor(pink*0.5)) ///
            , title("South Korea - Single", size(small)) ///
              legend(off) xtitle("") ytitle("Percent") ///
              `xlabopt' ylabel(0(20)100) ///
              name(gE4, replace)
    restore

    * --- KOR / Dating
    preserve
        keep if country==`KOR' & rel3==2
        keep sex edu3 `v'
        drop if missing(sex) | missing(edu3) | missing(`v')
        keep if inlist(sex,`male',`female')
        keep if inrange(`v',1,5)
        contract sex edu3 `v', freq(N)
        by sex edu3: egen T = total(N)
        gen pct = 100*N/T
        gen x = .
        replace x = `v'
        quietly twoway ///
            (connected pct x if sex==`male'   & edu3==1, sort lcolor(black)    msymbol(O) mcolor(black)) ///
            (connected pct x if sex==`male'   & edu3==2, sort lcolor(blue)     msymbol(O) mcolor(blue)) ///
            (connected pct x if sex==`male'   & edu3==3, sort lcolor(eltblue)  msymbol(O) mcolor(eltblue)) ///
            (connected pct x if sex==`female' & edu3==1, sort lcolor(purple)   msymbol(D) mcolor(purple)) ///
            (connected pct x if sex==`female' & edu3==2, sort lcolor(red)      msymbol(D) mcolor(red)) ///
            (connected pct x if sex==`female' & edu3==3, sort lcolor(pink*0.5) msymbol(D) mcolor(pink*0.5)) ///
            , title("South Korea - Dating", size(small)) ///
              legend(off) xtitle("") ytitle("Percent") ///
              `xlabopt' ylabel(0(20)100) ///
              name(gE5, replace)
    restore

    * --- KOR / Stable
    preserve
        keep if country==`KOR' & rel3==3
        keep sex edu3 `v'
        drop if missing(sex) | missing(edu3) | missing(`v')
        keep if inlist(sex,`male',`female')
        keep if inrange(`v',1,5)
        contract sex edu3 `v', freq(N)
        by sex edu3: egen T = total(N)
        gen pct = 100*N/T
        gen x = .
        replace x = `v'
        quietly twoway ///
            (connected pct x if sex==`male'   & edu3==1, sort lcolor(black)    msymbol(O) mcolor(black)) ///
            (connected pct x if sex==`male'   & edu3==2, sort lcolor(blue)     msymbol(O) mcolor(blue)) ///
            (connected pct x if sex==`male'   & edu3==3, sort lcolor(eltblue)  msymbol(O) mcolor(eltblue)) ///
            (connected pct x if sex==`female' & edu3==1, sort lcolor(purple)   msymbol(D) mcolor(purple)) ///
            (connected pct x if sex==`female' & edu3==2, sort lcolor(red)      msymbol(D) mcolor(red)) ///
            (connected pct x if sex==`female' & edu3==3, sort lcolor(pink*0.5) msymbol(D) mcolor(pink*0.5)) ///
            , title("South Korea - Stable", size(small)) ///
              legend(off) xtitle("") ytitle("Percent") ///
              `xlabopt' ylabel(0(20)100) ///
              name(gE6, replace)
    restore

    graph combine gE1 gE2 gE3 gE4 gE5 gE6, ///
        cols(3) ///
        title("`v' (sex x education)", size(medsmall)) ///
        subtitle("`vlabshort'", size(vsmall)) ///
        name(PANEL_SEXEDU, replace)
		
    graph export "`outdir'/PANEL_SEXEDU_`v'.png", ///
        name(PANEL_SEXEDU) replace width(4200)

    capture graph drop gE1 gE2 gE3 gE4 gE5 gE6
    capture graph drop PANEL_SEXEDU
}

set graphics on
di as result "Done. Panels saved in: `outdir'"

/*
/********************************************************************
1) Recode PNA/DK style values to missing for your PCA items
2) Check how many items each person answered (and distribution)
Edit the item list if needed.
********************************************************************/

use "UNFPA_PILOT_pde_group_project.dta", clear

*drop because no need from here onwards
drop Q17r8 Q18r5

* 1) Expand wildcard lists into actual variables
ds Q3Fr* Q3Mr* Q17r* Q18r*, has(type numeric)
local items `r(varlist)'

di as text "PCA items used:"
di as result "`items'"

* 2) Recode PNA/DK codes to missing (adjust if you have other codes)
foreach v of local items {
    quietly replace `v' = . if inlist(`v', 97, 98, 99, 998, 999)
}

* 3) Count answered items per person
egen n_answered = rownonmiss(`items')
gen  n_missing  = wordcount("`items'") - n_answered

label var n_answered "Number of PCA items answered"
label var n_missing  "Number of PCA items missing"

summ n_answered n_missing
tab n_answered, missing

count if n_answered == wordcount("`items'")
di as result "Complete cases: " r(N)


/*Nice — you're totally fine for PCA with listwise deletion here.
	•	You have 28 items in the PCA set.
	•	7,114 / 8,008 = 88.8% are complete cases (answered all 28 after recoding PNA→missing).
	•	Missingness is low enough that standard PCA on complete cases is reasonable.
*/



/********************************************************************
PCA (end of do-file)
- assumes `items' already exists (local macro with your PCA variables)
- assumes PNA/DK already recoded to missing
********************************************************************/

* Quick sanity check
di as text "PCA items (" wordcount("`items'") "): `items'"

* 1) Initial PCA (eigenvalues + scree) to justify #components
pca `items'
*screeplot, name(scree_pca, replace) commented out to make code faster
matrix list e(Ev)

* 2) Keep 4 components (all those with eigenvalues > 1) + rotate for interpretation
pca `items', components(4)
rotate, varimax

* 3) Inspect rotated loadings (your Stata may not support blanks(); this always works)
estat loadings

* 4) Create component scores (use in regressions/plots)
predict PC1 PC2 PC3 PC4

* Optional: standardize scores (nice for interpretation/comparisons)
foreach k in 1 2 3 4 {
    egen zPC`k' = std(PC`k')
    label var zPC`k' "Standardized PC`k'"
}

* Optional: store a simple correlation check among components (should be ~0 for varimax)
corr PC1 PC2 PC3 PC4


*PC1: Non-traditional family norms / general permissiveness (Q3 approve/disapprove on childfree, cohabitation, nonmarital childbearing, divorce)
*PC1: Non-traditional family norms / general permissiveness (Q3 approve/disapprove on childfree, cohabitation, nonmarital childbearing, divorce)
* PC2: Perceived barriers/constraints to forming a union (Q18: financial, employment, housing, pressure/stigma/health, negative past experiences)
* PC3: Independence/readiness orientation (Q17: career/self-focus, avoiding responsibilities, not ready, difficulty finding suitable partner)
* PC4: Work–family gender-role norms (Q3Fr4 & Q3Mr4: parents working full-time with children under age 3)

*/




