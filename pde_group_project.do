/* Replication Code Partnership Ideology
*Authors: Bova Marco, Cinti Emanuele,  Engeler Guia, Picci Miriam
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
capture mkdir "$resultspath/summarystatistics"

* Go to Data folder
cd "$datapath"
************************************************************
**#        CLEANING  ***
************************************************************
use "UNFPA_PILOT_v2.dta", clear
bysort country: gen n_country = _N
*------------------*
* Constants
*------------------*
local SWE 1
local KOR 5
local male   2
local female 1
****Create and rename new variables*** 
rename S1 sex
rename S2 age
rename S4 country_residence
rename Q8 marital_status
rename Q9 relationship_status
* Create Education groups from Q40
gen edu3 = .
replace edu3 = 1 if inlist(Q40,1,2)
replace edu3 = 2 if Q40==3
replace edu3 = 3 if Q40==4
replace edu3 = . if Q40==99 | missing(Q40)
label define edu3lbl 1 "Low" 2 "Mid" 3 "High", replace
label values edu3 edu3lbl
* Create Relationship groups from relationship_status = Q9
gen rel3 = .
replace rel3 = 1 if relationship_status==1
replace rel3 = 2 if relationship_status==2
replace rel3 = 3 if inrange(relationship_status,3,6)
label define rel3lbl 1 "Single" 2 "Dating" 3 "Stable", replace
label values rel3 rel3lbl
*Create variable for same sex relationships
gen reltype = .
*different sex
replace reltype = 1 if (sex == 1 & Q13 == 2) | (sex == 2 & Q13 == 1) 
*same sex
replace reltype = 2 if (sex == 1 & Q13 == 1) | (sex == 2 & Q13 == 2)
*unkown
replace reltype = 3 if inlist(sex, 3, 99) | inlist(Q13, 3, 99)
* Check distribution
tab reltype
* Drop same-sex and other/unknown
drop if inlist(reltype, 2, 3)
rename Q41 employment
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
*recode Q19 to make the most conservative answer 5 and least 1
recode Q19 (3 = 5 ) (2 = 4) (4 5 = 2) (1 = 1) (99=99)
*recode Q3F* and Q3M* to make sure that 5 is the most conservative answer and 1 the least
recode Q3F* (1 = 5 ) (2 = 4) (3 = 3) (4=2) (5=1) (99=99)
recode Q3M* (1 = 5 ) (2 = 4) (3 = 3) (4=2) (5=1) (99=99)
*recode Q17r4 this is not a key variable to make sure that 5 is the most conservative answer and 1 the least
recode Q17r4 (1 = 5 ) (2 = 4) (3 = 3) (4=2) (5=1) (99=99)
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
* add only outcome variables, not grouping variables
foreach v in Q16r7 Q16r8 Q19 Q17r4 Q18r5 Q33r3 Q33r7 {
    capture confirm variable `v'
    if !_rc local items "`items' `v'"
}
local items : list uniq items
* variables needed for plotting
local basevars country sex Q40 edu3 rel3
* keep plotting vars (item) + grouping vars (basevars)
local keepvars `basevars' `items'
local keepvars : list uniq keepvars
di as text "Plotting items:"
di as result "`items'"
di as text "Keeping variables for graphing:"
di as result "`keepvars'"
keep `keepvars'
* drop any observation with 99 in any item variable
foreach v of local items {
    capture confirm numeric variable `v'
    if !_rc {
        drop if `v' == 99
    }
}
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
local outdir "$resultspath/figs"

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
    *for Q19 lack of 3
    if "`v'" == "Q19" local xlabopt_v "xlabel(1 2 4 5)"
    else local xlabopt_v "`xlabopt'"
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
              `xlabopt_v' ylabel(0(20)100) ///
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
              `xlabopt_v' ylabel(0(20)100) ///
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
              `xlabopt_v' ylabel(0(20)100) ///
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
              `xlabopt_v' ylabel(0(20)100) ///
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
              `xlabopt_v' ylabel(0(20)100) ///
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
             `xlabopt_v' ylabel(0(20)100) ///
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
             `xlabopt_v' ylabel(0(20)100) ///
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
              `xlabopt_v' ylabel(0(20)100) ///
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
              `xlabopt_v' ylabel(0(20)100) ///
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
              `xlabopt_v' ylabel(0(20)100) ///
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
              `xlabopt_v' ylabel(0(20)100) ///
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
              `xlabopt_v' ylabel(0(20)100) ///
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

/********************************************************************
DESCRIPTIVE STATISTICS
reminder:
    sex: 1 = Female, 2 = Male
    rel3: 1 = Single, 2 = Dating, 3 = Stable
********************************************************************/
local outdir "$resultspath/summarystatistics"

use "UNFPA_PILOT_pde_group_project.dta", clear

local items ""
capture ds Q3Fr*
if !_rc local items "`items' `r(varlist)'"
capture ds Q3Mr*
if !_rc local items "`items' `r(varlist)'"
* add only outcome variables, not grouping variables
foreach v in Q16r7 Q16r8 Q19 {
    capture confirm variable `v'
    if !_rc local items "`items' `v'"
}
local items : list uniq items

tempfile allresults
local first = 1

foreach v of local items {
    preserve
        keep country rel3 sex `v'
        rename `v' score
        drop if missing(score)
        drop if !inrange(score, 1, 5)
        drop if missing(country, rel3, sex)
        * Create Female, Male, and Total groups
        gen sex3 = sex
        expand 2, gen(totalrow)
        replace sex3 = 3 if totalrow == 1
        label define sex3lbl 1 "Female" 2 "Male" 3 "Total", replace
        label values sex3 sex3lbl
        * Peak/mode within each group
        bysort country rel3 sex3: egen peak = mode(score), minmode
        * Summary statistics
        collapse (count) n = score (mean) mean = score (median) median = score (sd) sd = score (p25) p25 = score (p75) p75 = score (first) peak = peak, by(country rel3 sex3)
        gen iqr = p75 - p25
        gen item = "`v'"
        order item country rel3 sex3 n mean median peak sd iqr p25 p75
        format mean median sd iqr p25 p75 %9.2f
        if `first' {
            save `allresults', replace
            local first = 0
        }
        else {
            append using `allresults'
            save `allresults', replace
        }
    restore
}
use `allresults', clear
sort item country rel3 sex3
export excel using "`outdir'/ideology_summary_tables.xlsx", sheet("summary") firstrow(variables) replace
capture restore, not
preserve
keep if inlist(sex3, 1, 2)
/*
Create differences in mean between male and female for each country and variable
Interpretation:
diff_mean_male_female > 0 means men are more conservative on average than women.
diff_mean_male_female < 0 means women are more conservative on average than men.
*/
reshape wide n mean median peak sd iqr p25 p75, i(item country rel3) j(sex3)
gen diff_mean_male_female = mean2 - mean1
gen diff_median_male_female = median2 - median1
gen diff_peak_male_female = peak2 - peak1
gen diff_sd_male_female = sd2 - sd1
gen diff_iqr_male_female = iqr2 - iqr1
rename n1 female_n
rename n2 male_n
rename mean1 female_mean
rename mean2 male_mean
rename median1 female_median
rename median2 male_median
rename peak1 female_peak
rename peak2 male_peak
rename sd1 female_sd
rename sd2 male_sd
rename iqr1 female_iqr
rename iqr2 male_iqr
rename p251 female_p25
rename p252 male_p25
rename p751 female_p75
rename p752 male_p75
order item country rel3 female_n male_n female_mean male_mean diff_mean_male_female female_median male_median diff_median_male_female female_peak male_peak diff_peak_male_female female_sd male_sd diff_sd_male_female female_iqr male_iqr diff_iqr_male_female female_p25 male_p25 female_p75 male_p75
format female_mean male_mean diff_mean_male_female female_median male_median diff_median_male_female female_sd male_sd diff_sd_male_female female_iqr male_iqr diff_iqr_male_female female_p25 male_p25 female_p75 male_p75 %9.2f
export excel using "`outdir'/ideology_summary_tables.xlsx", sheet("male_female_differences") firstrow(variables) sheetreplace
restore

******************************
*** create overlap statistics
****************************
* Overlap table: Female = 1, Male = 2
local outdir "$resultspath/summarystatistics"

capture restore, not
use "UNFPA_PILOT_pde_group_project.dta", clear
* Recreate items list 
local items ""
capture ds Q3Fr*
if !_rc local items "`items' `r(varlist)'"
capture ds Q3Mr*
if !_rc local items "`items' `r(varlist)'"
foreach v in Q16r7 Q16r8 Q19 {
    capture confirm variable `v'
    if !_rc local items "`items' `v'"
}
local items : list uniq items
di as text "Items used for overlap:"
di as result "`items'"
tempfile overlap_all
local first = 1
foreach v of local items {
    preserve
    keep country rel3 sex `v'
    rename `v' score
    keep if inlist(sex, 1, 2)
    keep if inrange(score, 1, 5)
    contract country rel3 score sex
    reshape wide _freq, i(country rel3 score) j(sex)
    capture confirm variable _freq1
    if _rc gen _freq1 = 0
    capture confirm variable _freq2
    if _rc gen _freq2 = 0
    replace _freq1 = 0 if missing(_freq1)
    replace _freq2 = 0 if missing(_freq2)
    gen female_n_ = _freq1
    gen male_n_ = _freq2
    gen overlap_ = min(female_n_, male_n_)
    gen nonoverlap_ = abs(female_n_ - male_n_)
    keep country rel3 score female_n_ male_n_ overlap_ nonoverlap_
    reshape wide female_n_ male_n_ overlap_ nonoverlap_, i(country rel3) j(score)
    foreach s of numlist 1/5 {
        capture confirm variable female_n_`s'
        if _rc gen female_n_`s' = 0
        capture confirm variable male_n_`s'
        if _rc gen male_n_`s' = 0
        capture confirm variable overlap_`s'
        if _rc gen overlap_`s' = 0
        capture confirm variable nonoverlap_`s'
        if _rc gen nonoverlap_`s' = 0
    }
    gen female_total = female_n_1 + female_n_2 + female_n_3 + female_n_4 + female_n_5
    gen male_total = male_n_1 + male_n_2 + male_n_3 + male_n_4 + male_n_5
    gen total_n = female_total + male_total
    gen overlap_total = overlap_1 + overlap_2 + overlap_3 + overlap_4 + overlap_5
    gen people_in_overlap = 2 * overlap_total
    gen people_not_overlap = nonoverlap_1 + nonoverlap_2 + nonoverlap_3 + nonoverlap_4 + nonoverlap_5
    gen fraction_people_overlap = people_in_overlap / total_n
    gen fraction_people_not_overlap = people_not_overlap / total_n
    gen str20 item = "`v'"
    order item country rel3 female_total male_total total_n overlap_1 overlap_2 overlap_3 overlap_4 overlap_5 overlap_total people_in_overlap people_not_overlap fraction_people_overlap fraction_people_not_overlap nonoverlap_1 nonoverlap_2 nonoverlap_3 nonoverlap_4 nonoverlap_5
    format fraction_people_overlap fraction_people_not_overlap %9.3f
    if `first' == 1 {
        save `overlap_all', replace
        local first = 0
    }
    else {
        append using `overlap_all'
        save `overlap_all', replace
    }
    restore
}
use `overlap_all', clear
sort item country rel3
export excel using "`outdir'/ideology_overlap_tables.xlsx", sheet("overlap_wide") firstrow(variables) replace
save "`outdir'/ideology_overlap_tables.dta", replace

** showcase the overlap for Sweden and South Korea
capture restore, not

use "`outdir'/ideology_overlap_tables.dta", clear
local outdir "$resultspath/summarystatistics"

set graphics off
graph drop _all

set seed 12345
*make the variable names more distant
gen xrel = rel3 + (runiform() - 0.5) * 0.6

twoway scatter fraction_people_overlap xrel if country == 1, msymbol(i) mlabel(item) mlabsize(vsmall) mlabcolor(navy) mlabposition(0) xlabel(1 "Single" 2 "Dating" 3 "Stable", labsize(medsmall) noticks) ylabel(0(0.1)1, angle(horizontal) format(%3.1f) grid) yscale(range(0 1)) xscale(range(0.35 3.65)) xtitle("") ytitle("Fraction of people in overlap") title("Male-female overlap across variables", size(medium)) subtitle("Sweden", size(small)) legend(off) graphregion(color(white)) plotregion(color(white)) note("Each label is one variable.", size(vsmall)) name(overlap_sweden, replace)

graph export "`outdir'/overlap_distribution_sweden_labeled.png", name(overlap_sweden) replace width(3000)

twoway scatter fraction_people_overlap xrel if country == 5, msymbol(i) mlabel(item) mlabsize(vsmall) mlabcolor(navy) mlabposition(0) xlabel(1 "Single" 2 "Dating" 3 "Stable", labsize(medsmall) noticks) ylabel(0(0.1)1, angle(horizontal) format(%3.1f) grid) yscale(range(0 1)) xscale(range(0.35 3.65)) xtitle("") ytitle("Fraction of people in overlap") title("Male-female overlap across variables", size(medium)) subtitle("South Korea", size(small)) legend(off) graphregion(color(white)) plotregion(color(white)) note("Each label is one variable.", size(vsmall)) name(overlap_southkorea, replace)

graph export "`outdir'/overlap_distribution_southkorea_labeled.png", name(overlap_southkorea) replace width(3000)

set graphics on

/********************************************************************
WASSERSTEIN-1 / EARTH MOVER'S DISTANCE
Female vs Male distributions by:
    country x relationship status x item

This chunk starts from the cleaned project dataset.

Variables used from UNFPA_PILOT_pde_group_project.dta:
    country
    sex
    rel3
    Q3Mr*
    Q3Fr*
    Q16r7
    Q16r8
    Q19
********************************************************************/

use "UNFPA_PILOT_pde_group_project.dta", clear

local outdir "$resultspath/summarystatistics"

capture mkdir "$outdir"

local female 1
local male   2

*------------------------------------------------------*
* 1. Check required grouping variables exist
*------------------------------------------------------*

foreach v in country sex rel3 {
    capture confirm variable `v'
    if _rc {
        di as error "Variable `v' not found in UNFPA_PILOT_pde_group_project.dta"
        exit 111
    }
}

**------------------------------------------------------*
* 2. Define Wasserstein / EMD item list
*------------------------------------------------------*

local w1_items ""

capture ds Q3Mr*
if !_rc local w1_items "`w1_items' `r(varlist)'"

capture ds Q3Fr*
if !_rc local w1_items "`w1_items' `r(varlist)'"

foreach v in Q16r7 Q16r8 Q19 {
    capture confirm variable `v'
    if !_rc local w1_items "`w1_items' `v'"
}

local w1_items : list uniq w1_items

if "`w1_items'" == "" {
    di as error "No Wasserstein items found."
    exit 111
}

di as text "Items used for Wasserstein-1 / EMD:"
di as result "`w1_items'"


*------------------------------------------------------*
* 3. Program to calculate Wasserstein-1 for two groups
*------------------------------------------------------*

capture program drop w1_twogroups
program define w1_twogroups, rclass
    syntax varname(numeric) [if], GROUP(varname numeric) G1(integer) G2(integer)

    marksample touse

    preserve

        keep if `touse'
        keep `varlist' `group'
        keep if !missing(`varlist', `group')
        keep if inlist(`group', `g1', `g2')

        quietly count if `group' == `g1'
        local n1 = r(N)

        quietly count if `group' == `g2'
        local n2 = r(N)

        if `n1' == 0 | `n2' == 0 {
            restore
            return scalar W1 = .
            return scalar N1 = `n1'
            return scalar N2 = `n2'
            exit
        }

        contract `varlist' `group', freq(n)

        fillin `varlist' `group'
        replace n = 0 if missing(n)

        bysort `group': egen total = total(n)
        gen double p = n / total

        keep `varlist' `group' p

        reshape wide p, i(`varlist') j(`group')

        capture confirm variable p`g1'
        if _rc gen double p`g1' = 0

        capture confirm variable p`g2'
        if _rc gen double p`g2' = 0

        replace p`g1' = 0 if missing(p`g1')
        replace p`g2' = 0 if missing(p`g2')

        sort `varlist'

        gen double F1 = sum(p`g1')
        gen double F2 = sum(p`g2')

        gen double absdiff = abs(F1 - F2)
        gen double dx = `varlist'[_n+1] - `varlist' if _n < _N
        gen double contrib = absdiff * dx if _n < _N
        replace contrib = 0 if missing(contrib)

        quietly summarize contrib, meanonly
        local w1 = r(sum)

    restore

    return scalar W1 = `w1'
    return scalar N1 = `n1'
    return scalar N2 = `n2'
end


*------------------------------------------------------*
* 4. Calculate W1 by country x rel3 x item
*------------------------------------------------------*

tempfile w1_all
tempname handle

postfile `handle' ///
    str40 item ///
    int country ///
    str80 country_label ///
    int rel3 ///
    str20 relationship ///
    double W1 ///
    int female_n ///
    int male_n ///
    using `w1_all', replace

levelsof country if !missing(country), local(countries)
levelsof rel3 if inlist(rel3, 1, 2, 3), local(rels)

local countrylbl : value label country
local rellbl     : value label rel3

foreach c of local countries {

    local cname "`c'"
    if "`countrylbl'" != "" {
        local cname : label `countrylbl' `c'
        if `"`cname'"' == "" local cname "`c'"
    }

    foreach r of local rels {

        local rname "`r'"
        if "`rellbl'" != "" {
            local rname : label `rellbl' `r'
            if `"`rname'"' == "" local rname "`r'"
        }

        foreach v of local w1_items {

            quietly w1_twogroups `v' ///
                if country == `c' ///
                & rel3 == `r' ///
                & inlist(sex, `female', `male') ///
                & inrange(`v', 1, 5), ///
                group(sex) g1(`female') g2(`male')

            post `handle' ///
                ("`v'") ///
                (`c') ///
                (`"`cname'"') ///
                (`r') ///
                (`"`rname'"') ///
                (r(W1)) ///
                (r(N1)) ///
                (r(N2))
        }
    }
}

postclose `handle'


*------------------------------------------------------*
* 5. Open and label results
*------------------------------------------------------*

use `w1_all', clear

format W1 %9.4f

label var item "Item"
label var country "Country code"
label var country_label "Country"
label var rel3 "Relationship status code"
label var relationship "Relationship status"
label var female_n "Female N"
label var male_n "Male N"
label var W1 "Wasserstein-1 distance: Female vs Male"

order item country country_label rel3 relationship female_n male_n W1
sort item country rel3


*------------------------------------------------------*
* 6. Export long results
*------------------------------------------------------*

export excel using "`outdir'/wasserstein1_gender_by_country_relationship.xlsx", ///
    sheet("w1_long") firstrow(variables) replace

save "`outdir'/wasserstein1_gender_by_country_relationship_long.dta", replace


*------------------------------------------------------*
* 7. Create wide table: Single, Dating, Stable side-by-side
*------------------------------------------------------*

preserve

keep item country country_label rel3 female_n male_n W1

reshape wide W1 female_n male_n, i(item country country_label) j(rel3)

capture rename W11 W1_single
capture rename W12 W1_dating
capture rename W13 W1_stable

capture rename female_n1 female_n_single
capture rename female_n2 female_n_dating
capture rename female_n3 female_n_stable

capture rename male_n1 male_n_single
capture rename male_n2 male_n_dating
capture rename male_n3 male_n_stable

order item country country_label ///
    W1_single female_n_single male_n_single ///
    W1_dating female_n_dating male_n_dating ///
    W1_stable female_n_stable male_n_stable

format W1_single W1_dating W1_stable %9.4f

export excel using "`outdir'/wasserstein1_gender_by_country_relationship.xlsx", ///
    sheet("w1_wide") firstrow(variables) sheetreplace

save "`outdir'/wasserstein1_gender_by_country_relationship_wide.dta", replace

restore


*------------------------------------------------------*
* 8. Display largest gender distribution gaps
*------------------------------------------------------*

gsort -W1

list item country_label relationship female_n male_n W1 in 1/30, ///
    sepby(country_label relationship)

di as result "Done. Wasserstein-1 / EMD tables saved in:"
di as result "`outdir'/wasserstein1_gender_by_country_relationship.xlsx"


set graphics off

/********************************************************************
RELATIONSHIP-STATUS HEATMAP
Main purpose:
    Compare female-male Wasserstein-1 distance across:
        Single vs Dating vs Stable

Rows:
    variables

Columns:
    relationship status

Cell:
    W1 distance

One graph per country.
********************************************************************/

capture restore, not

local outdir "$resultspath/summarystatistics"
local figdir "$resultspath/figs"

capture mkdir "$figdir"

use "`outdir'/wasserstein1_gender_by_country_relationship_long.dta", clear

keep if inlist(rel3, 1, 2, 3)
drop if missing(W1)

levelsof country, local(countries)

foreach c of local countries {

    preserve

        keep if country == `c'

        local cname = country_label[1]

        *------------------------------------------------------*
        * Order items by their maximum W1 within this country
        *------------------------------------------------------*

        bysort item: egen maxW1_item = max(W1)
        egen tag_item = tag(item)

        gsort -maxW1_item item

        gen item_rank_tmp = sum(tag_item)
        bysort item: egen item_order = max(item_rank_tmp)

        quietly summarize item_order
        gen y = r(max) + 1 - item_order

        *------------------------------------------------------*
        * W1 categories for heat intensity
        *------------------------------------------------------*

        gen W1cat = .
        replace W1cat = 1 if W1 < 0.25
        replace W1cat = 2 if W1 >= 0.25 & W1 < 0.50
        replace W1cat = 3 if W1 >= 0.50 & W1 < 0.75
        replace W1cat = 4 if W1 >= 0.75 & W1 < 1.00
        replace W1cat = 5 if W1 >= 1.00

        gen str5 W1label = string(W1, "%4.2f")

        *------------------------------------------------------*
        * Y-axis labels: all variable names
        *------------------------------------------------------*

        levelsof y, local(yvals)

        local ylabels ""

        foreach yy of local yvals {
            levelsof item if y == `yy', local(thisitem) clean
            local ylabels `"`ylabels' `yy' "`thisitem'""'
        }

        *------------------------------------------------------*
        * Heatmap graph
        *------------------------------------------------------*

        twoway ///
            (scatter y rel3 if W1cat == 1, ///
                msymbol(S) msize(huge) mcolor(gs15)) ///
            (scatter y rel3 if W1cat == 2, ///
                msymbol(S) msize(huge) mcolor(gs13)) ///
            (scatter y rel3 if W1cat == 3, ///
                msymbol(S) msize(huge) mcolor(gs10)) ///
            (scatter y rel3 if W1cat == 4, ///
                msymbol(S) msize(huge) mcolor(gs7)) ///
            (scatter y rel3 if W1cat == 5, ///
                msymbol(S) msize(huge) mcolor(gs4)) ///
            (scatter y rel3, ///
                msymbol(i) ///
                mlabel(W1label) ///
                mlabposition(0) ///
                mlabsize(vsmall) ///
                mlabcolor(black)) ///
            , ///
            xlabel(1 "Single" 2 "Dating" 3 "Stable", labsize(medsmall)) ///
            ylabel(`ylabels', angle(horizontal) labsize(vsmall)) ///
            xscale(range(0.5 3.5)) ///
            xtitle("") ///
            ytitle("") ///
            title("Female-male ideological distance by relationship status", size(medium)) ///
            subtitle("`cname'", size(small)) ///
            legend(order(1 "W1 < 0.25" ///
                         2 "0.25-0.49" ///
                         3 "0.50-0.74" ///
                         4 "0.75-0.99" ///
                         5 "W1 >= 1.00") ///
                   rows(1) size(vsmall)) ///
            note("Cell values are Wasserstein-1 distances. Darker cells indicate larger female-male distributional gaps.", size(vsmall)) ///
            graphregion(color(white)) ///
            plotregion(color(white)) ///
            name(w1_heatmap_`c', replace)

        graph export "`figdir'/w1_relationship_heatmap_country_`c'.png", ///
            name(w1_heatmap_`c') replace width(4200)

    restore
}
/********************************************************************
CLEVELAND DOT PLOT:
Female-male Wasserstein distance by relationship status

Main point:
    Compare Single vs Dating vs Stable for each item.

Rows:
    variables

x-axis:
    W1 female-male distance

Markers:
    Single / Dating / Stable

Grey line:
    range from smallest to largest W1 for that variable
********************************************************************/

capture restore, not

local outdir "$resultspath/summarystatistics"
local figdir "$resultspath/figs"

capture mkdir "$figdir"

use "`outdir'/wasserstein1_gender_by_country_relationship_long.dta", clear

keep if inlist(rel3, 1, 2, 3)
drop if missing(W1)

levelsof country, local(countries)

foreach c of local countries {

    preserve

        keep if country == `c'

        local cname "`=country_label[1]'"

        *------------------------------------------------------*
        * Order variables by how much W1 varies across
        * Single / Dating / Stable.
        * This puts the most relationship-relevant items on top.
        *------------------------------------------------------*

        bysort item: egen W1max = max(W1)
        bysort item: egen W1min = min(W1)
        gen W1range = W1max - W1min

        egen tag_item = tag(item)

        gsort -W1range -W1max item

        gen rank_tmp = sum(tag_item)
        bysort item: egen item_order = max(rank_tmp)

        quietly summarize item_order
        gen y = r(max) + 1 - item_order

        *------------------------------------------------------*
        * Y-axis labels: all variable names
        *------------------------------------------------------*

        levelsof y, local(yvals)
        local ylabels ""

        foreach yy of local yvals {
            levelsof item if y == `yy', local(thisitem) clean
            local ylabels `"`ylabels' `yy' "`thisitem'""'
        }

        *------------------------------------------------------*
        * Optional value labels only for large distances
        *------------------------------------------------------*

        gen str5 W1label = string(W1, "%4.2f")
        gen str5 W1label_big = ""
        replace W1label_big = W1label if W1 >= 0.50

        quietly summarize W1
        local xmax = ceil(r(max)*10)/10 + 0.10
        if `xmax' < 0.80 local xmax = 0.80

        *------------------------------------------------------*
        * Graph
        *------------------------------------------------------*

        twoway ///
            (pcspike y W1min y W1max if tag_item == 1, ///
                lcolor(gs12) lwidth(medthin)) ///
            (scatter y W1 if rel3 == 1, ///
                msymbol(O) msize(medium) mcolor(navy)) ///
            (scatter y W1 if rel3 == 2, ///
                msymbol(D) msize(medium) mcolor(maroon)) ///
            (scatter y W1 if rel3 == 3, ///
                msymbol(T) msize(medium) mcolor(forest_green)) ///
            (scatter y W1, ///
                msymbol(i) ///
                mlabel(W1label_big) ///
                mlabposition(12) ///
                mlabsize(vsmall) ///
                mlabcolor(black)) ///
            , ///
            xlabel(0(0.25)`xmax', labsize(small)) ///
            ylabel(`ylabels', angle(horizontal) labsize(small)) ///
            xscale(range(0 `xmax')) ///
            xtitle("Female-male Wasserstein-1 distance", size(small)) ///
            ytitle("") ///
            title("Female-male ideological distance by relationship status", size(medium)) ///
            subtitle("`cname'", size(small)) ///
            legend(order(2 "Single" 3 "Dating" 4 "Stable") ///
                   rows(1) size(small) position(6)) ///
            note("Dots farther right indicate larger female-male distributional distance. Grey line shows the range across relationship statuses. Values shown for W1 >= 0.50.", size(vsmall)) ///
            graphregion(color(white)) ///
            plotregion(color(white)) ///
            name(w1_dotplot_`c', replace)

        graph export "`figdir'/w1_relationship_dotplot_country_`c'.png", ///
            name(w1_dotplot_`c') replace width(4200)

    restore
}

/********************************************************************
OVERLAP + WASSERSTEIN GRAPH

x-axis:
    People not in female-male overlap, %

y-axis:
    Wasserstein-1 distance

Markers:
    Single / Dating / Stable

Interpretation:
    Upper-right = strongest female-male mismatch
********************************************************************/

capture restore, not

local outdir "$resultspath/summarystatistics"
local figdir "$resultspath/figs"

capture mkdir "$figdir"

*------------------------------------------------------*
* 1. Load overlap results
*------------------------------------------------------*

use "`outdir'/ideology_overlap_tables.dta", clear

keep item country rel3 fraction_people_not_overlap fraction_people_overlap ///
     female_total male_total total_n

gen pct_people_not_overlap = 100 * fraction_people_not_overlap
gen pct_people_overlap     = 100 * fraction_people_overlap

tempfile overlapdata
save `overlapdata', replace


*------------------------------------------------------*
* 2. Load Wasserstein results
*------------------------------------------------------*

use "`outdir'/wasserstein1_gender_by_country_relationship_long.dta", clear

keep item country country_label rel3 relationship W1 female_n male_n

*------------------------------------------------------*
* 3. Merge W1 with overlap
*------------------------------------------------------*

merge 1:1 item country rel3 using `overlapdata'

keep if _merge == 3
drop _merge

keep if inlist(rel3, 1, 2, 3)
drop if missing(W1, pct_people_not_overlap)

format W1 %9.3f
format pct_people_not_overlap pct_people_overlap %9.1f

save "`outdir'/overlap_wasserstein_combined.dta", replace


*------------------------------------------------------*
* 4. Plot one graph per country
*------------------------------------------------------*

levelsof country, local(countries)

foreach c of local countries {

    preserve

        keep if country == `c'

        local cname "`=country_label[1]'"

        quietly summarize pct_people_not_overlap
        local xmax = ceil(r(max)/10)*10
        if `xmax' < 40 local xmax = 40
        if `xmax' > 100 local xmax = 100

        quietly summarize W1
        local ymax = ceil(r(max)*10)/10 + 0.10
        if `ymax' < 0.80 local ymax = 0.80

        twoway ///
            (scatter W1 pct_people_not_overlap if rel3 == 1, ///
                msymbol(O) msize(medium) mcolor(navy%75) ///
                mlabel(item) mlabsize(tiny) mlabposition(12) mlabcolor(navy)) ///
            (scatter W1 pct_people_not_overlap if rel3 == 2, ///
                msymbol(D) msize(medium) mcolor(maroon%75) ///
                mlabel(item) mlabsize(tiny) mlabposition(12) mlabcolor(maroon)) ///
            (scatter W1 pct_people_not_overlap if rel3 == 3, ///
                msymbol(T) msize(medium) mcolor(forest_green%75) ///
                mlabel(item) mlabsize(tiny) mlabposition(12) mlabcolor(forest_green)) ///
            , ///
            xlabel(0(10)`xmax', labsize(small)) ///
            ylabel(0(0.25)`ymax', angle(horizontal) labsize(small)) ///
            xscale(range(0 `xmax')) ///
            yscale(range(0 `ymax')) ///
            xtitle("People not in female-male overlap (%)", size(small)) ///
            ytitle("Wasserstein-1 distance", size(small)) ///
            title("Female-male mismatch: overlap and Wasserstein distance", size(medium)) ///
            subtitle("`cname'", size(small)) ///
            legend(order(1 "Single" 2 "Dating" 3 "Stable") ///
                   rows(1) size(small) position(6)) ///
            note("Upper-right = larger share outside overlap and larger distributional distance.", size(vsmall)) ///
            graphregion(color(white)) ///
            plotregion(color(white)) ///
            name(overlap_w1_`c', replace)

        graph export "`figdir'/overlap_wasserstein_country_`c'.png", ///
            name(overlap_w1_`c') replace width(4200)

    restore
}

set graphics on


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




