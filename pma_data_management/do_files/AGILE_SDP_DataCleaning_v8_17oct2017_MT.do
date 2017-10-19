clear
clear matrix
clear mata
capture log close
* OMG CHANGES!
set maxvar 15000
set more off
numlabel, add

*******************************************************************************
*
*  FILENAME: CCRX_SDP_DataCleaning_$date.do
*  PURPOSE:  SDP data cleaning, labeling, and encoding
*  CREATED:  28 Sep 2017 by MaryT
*  DATA IN:  CCRX_Service_Delivery_Point_v#.csv 
*  DATA OUT: CCRX_SDP_$date_100Prelim.dta"
* 
*
*******************************************************************************

*******************************************************************************
* INSTRUCTIONS
*******************************************************************************
*
* 1. Update the macros in Section 1 by country and round, modeling the example 
*  provided (before data collection)
* 2. Update the country-specific code in Section 2 (before data collection)
* 3. Clean facility names in Section 7
* 4. Apply random ID number from pre-specified country range to facility name in
*  Section 8
* OMG MORE CHANGES!
* 5. Apply random ID number from pre-specified country range to EA name in 
*  Section 9
* 6. Clean RE names and apply random ID number from pre-specified country range 
*  to RE names in Section 10
* 7. Update any country-specific variables to be dropped in Section 11
* 8. When ready to generate dataset for public release, comment out Section 12,
*   un-comment out Section 13 and add any country-specific identifying variables
*  to the list of variables to be dropped in Section 13
* 9. Un-comment out Section 14 to merge in EA weights
*10. Un-comment out Section 15 and save data set for public release
*11. Un-comment out Section 16 and test merge to ensure all SDPs are
*  in an EA with at least one household
*
*******************************************************************************
* 1. SET MACROS: UPDATE THIS SECTION FOR EACH COUNTRY/ROUND
*******************************************************************************

* Set macros for country and round
local country "Kenya"
local round "Round1"
local roundnum "1"
* OMG MORE CHANGES!
local CCRX "AGILE"

* Set macros for csv file name(s)
local csv1 "`CCRX'_SDP_Questionnaire_v8"
local csv2 ""

* Set local macros for directories

global csvfilesdir "C:\Users\Patrick.Owuor\Documents\ICRH2017\data" 
cd "$datadir"

* Update list of all methods counseled on ("methods") and all methods provided/referred ("methods_short");
* confirm methods and exact method spelling in ODK
local methods "fster mster impl_oth iud_cu250 iud_cu375 iud_cu380 iud_tcu380a iud_ppiud iud_other injsp inj_oth pill_oth ec_postpill ec_oth mc_fiesta mc_kiss mc_oth female_condom diaphram foam beads"
local methods_short "mc_fiesta mc_kiss mc_other female_condom pill_other injsp inj_oth iud_cu250 iud_cu375 iud_cu380 iud_tcu380a iud_ppiud iud_clear imp_oth ec_postpill ec_other"

local methods_chv "mc_fiesta mc_kiss mc_other female_condom pill_other injsp inj_oth iud_cu250 iud_cu375 iud_cu380 iud_tcu380a iud_ppiud iud_clear imp_oth ec_postpill ec_other"

* Update list of physical methods, but use full method name, not abbreviation
local methods_stock_full "imp_other iud_cu250 iud_cu375 iud_cu380 iud_tcu380a iud_ppiud iud_other inj_sp inj_other pill_other ec_postpill ec_other mc_fiesta mc_kiss mc_other female_condom diaphram foam_jelly std_days_beads"


* Set local/global macros for current date
local today=c(current_date)
local c_today= "`today'"
global date=subinstr("`c_today'", " ", "",.)
local todaystata=clock("`today'", "DMY")

* Create log
capture log using "`CCRX'_SDP_DataCleaning.log", replace

* Append .csv files if more than one version of the form was used in data collection
 * Read in latest version of the .csv file (largest .csv file)
 insheet using "$datadir/`csv1'.csv", names clear
 save "`csv1'.dta", replace
 
 
 use "`csv1'.dta", clear
 

* Drop duplicate submissions
duplicates drop metainstanceid, force

*******************************************************************************
* 2. GENERATE, RENAME, AND LABEL VARIABLES COUNTRY SPECIFIC VARIABLES: UPDATE BY COUNTRY
******************************************************************************

* Facility type

label define facility_type_list 1 "hospital" 2 "health_center" 3 "health_post" 4 "health_clinic" 5 "pharmacy" ///
 6 "drug_shop" 7 "other" 8 "retail" 9 "dispensary" 10 "nursing_ maternity" 
encode facility_type, gen(facility_typev2) lab(facility_type_list)

* Survey language 
* UPDATE BY COUNTRY
label define language_list 1 english 2 kiswahili 96 other
encode survey_language, gen(survey_languagev2) lab(language_list)
label define language_list 1 "English" 2 "Kiswahili" 96 "Other" , replace

* Label location variables 
* UPDATE BY COUNTRY
rename  level1 county
label variable county "County"
rename level2 district
label variable district  "District"
rename level3 division
label variable division "Division"
rename level4 location
label variable location "Location" 
label variable nearest_town "Nearest town" 

* Mobile Outreach
label variable mobile_outreach_6mo "Number of times in past 6 months visited by mobile outreach"

* Staffing Group Variables

rename v41 staffing_doctor_here
rename staffing_doctor_grpstaffing_doct staffing_doctor_tot
rename v43 staffing_clinical_officer_here
rename staffing_clinical_officers_grpst staffing_clinical_officer_tot
rename v45 staffing_nurse_here
rename staffing_nurse_grpstaffing_nurse staffing_nurse_tot
rename v47 staffing_med_ass_here
rename staffing_med_ass_grpstaffing_med staffing_med_ass_tot

rename pharmacist_grppharmacist_tot staffing_pharmacist_tot
rename pharmacist_grppharmacist_here staffing_pharmacist_here

rename staffing_pharm_tech_grpstaffing_ staffing_pharm_tech_tot
rename v51 staffing_pharm_tech_here

rename staffing_lab_tech_grpstaffing_la staffing_lab_tech_tot
rename v53 staffing_lab_tech_here

rename staffing_chv_grpstaffing_chv_tot staffing_chv_tot
rename staffing_chv_grpstaffing_chv_her staffing_chv_here

rename staffing_other_grpstaffing_other staffing_other_tot
rename v57 staffing_other_here


* Label staff variables
* UPDATE BY COUNTRY
label variable staffing_doctor_tot "Total number of doctors"
label variable staffing_doctor_here "Number of doctors present today"
label variable staffing_nurse_tot "Total number of nurses / midwives"
label variable staffing_nurse_here "Number of nurses / midwives present today"
label variable staffing_med_ass_tot "Total number of medical assistants"
label variable staffing_med_ass_here "Number of medical assistants present today"
label variable staffing_pharmacist_tot "Total number of pharmacists"
label variable staffing_pharmacist_here "Number of pharmacists present today"

label variable  staffing_pharm_tech_tot "Total number of Pharm tecs"
label variable staffing_pharm_tech_here "Number of pharm techs present today"

label variable  staffing_lab_tech_tot "Total number of Lab techs"
label variable  staffing_lab_tech_here "Number of Lab techs present today"

label variable  staffing_chv_tot "Total number of CHWs"
label variable  staffing_chv_here "Number of CHWs present today"

label variable staffing_other_tot "Total number of other medical staff"
label variable staffing_other_here "Number of other medical staff present today"

*******************************************************************************
* 3. RENAME GENERIC VARIABLES
*******************************************************************************

* Fees Charged Group Variables 

rename fpf_grp* *
rename fpc_grp* *

rename fster_fees fees_female_ster
rename mster_fees fees_male_ster

rename impl_oth_fees fees_implants_other

rename iud_cu250_fees fees_iud_cu250
rename iud_cu375_fees fees_iud_cu375
rename iud_cu380_fees fees_iud_cu380
rename iud_tcu380a_fees fees_tcu380a
rename iud_ppiud_fees fees_iud_ppiud
rename iud_other_fees fees_iud_other


capture rename inj_oth_fees fees_injectables_other
capture rename injsp_fees fees_injectables_sayana

rename pill_oth_fees fees_pills_other

rename ec_postpill_fees fees_ec_postpill
rename ec_oth_fees fees_ec_other

rename mc_fiesta_fees fees_male_condoms_fiesta
rename mc_kiss_fees fees_male_condoms_kiss
rename mc_oth_fees fees_male_condoms_other

rename female_condom_fees fees_female_condoms_fc2

rename diaphram_fees fees_diaphragm
rename foam_fees fees_foam
rename beads_fees fees_beads 

 

* Family Planning Register - total and new clients 


rename reg_fster_grpfster_tot visits_female_ster
rename reg_mster_grpmster_tot visits_male_ster
rename reg_impl_j_grpimpl_j_tot visits_implants_jad_total
rename reg_impl_j_grpimpl_j_new visits_implants_jad_new
rename reg_impl_i_grpimpl_i_tot visits_implants_impl_total
rename reg_impl_i_grpimpl_i_new visits_implants_impl_new
rename reg_impl_oth_grpimpl_oth_tot visits_implants_other_total
rename reg_impl_oth_grpimpl_oth_new visits_implants_other_new

rename reg_iud_cu250_grpiud_cu250_tot visits_iud_cu250_tot
rename reg_iud_cu250_grpiud_cu250_new visits_iud_cu250_new
rename reg_iud_cu375_grpiud_cu375_tot visits_iud_cu375_tot
rename reg_iud_cu375_grpiud_cu375_new visits_iud_cu375_new
rename reg_iud_cu380_grpiud_iud_cu380_t visits_iud_cu380_tot
rename reg_iud_cu380_grpiud_iud_cu380_n  visits_iud_cu380_new
rename reg_iud_tcu380a_grpiud_iud_tcu38  visits_iud_tcu38_tot
rename v160 visits_iud_tcu38_new
rename reg_iud_ppiud_grpiud_iud_ppiud_t visits_iud_ppiud_tot
rename reg_iud_ppiud_grpiud_iud_ppiud_n visits_iud_ppiud_new

rename reg_iud_other_grpiud_other_tot visits_iud_other_total
rename reg_iud_other_grpiud_other_new visits_iud_other_new

rename reg_inj_grpinj_tot visits_injectables_total
rename reg_inj_grpinj_new visits_injectables_new
rename reg_injsp_grpinjsp_tot visits_injectables_saya_total
rename reg_injsp_grpinjsp_new visits_injectables_saya_new

rename reg_pill_grppill_tot visits_pill_other_total
rename reg_pill_grppill_new visits_pil_other_new
rename reg_ec_postpill_grpec_postpill_t visits_ec_postpill_total
rename reg_ec_postpill_grpec_postpill_n visits_ec_postpill_n
rename reg_ec_grpec_tot visits_ec_other_total
rename reg_ec_grpec_new visits_ec_other_new
rename reg_mc_fiesta_grpmc_fiesta_tot visits_male_condoms_fiesta_total
rename reg_mc_fiesta_grpmc_fiesta_new visits_male_condoms_fiesta_new
rename reg_mc_kiss_grpmc_kiss_tot visits_male_condoms_kiss_total
rename reg_mc_kiss_grpmc_kiss_new visits_male_condoms_kiss_new
rename reg_mc_oth_grpmc_oth_tot  visits_male_condoms_other_total
rename reg_mc_oth_grpmc_oth_new visits_male_condoms_other_new
rename reg_fc_grpfemale_condom_tot visits_female_cond_fc2_total
rename reg_fc_grpfemale_condom_new visits_female_cond_fc2_new

rename reg_dia_grpdiaphram_tot visits_diaphragm_total
rename reg_dia_grpdiaphram_new visits_diaphragm_new

rename reg_foam_grpfoam_tot visits_foam_total
rename reg_foam_grpfoam_new visits_foam_new
rename reg_beads_grpbeads_tot visits_beads_total
rename reg_beads_grpbeads_new visits_beads_new

***Stock
**Out of stock last three months
rename fpp_os* *
rename os3* *


* Family Planning Record Book - # of products sold

rename reg_sold_grp*  sold_* 
rename register_320b* days_*
 


* Other
cap rename metainstanceid metainstanceID
cap rename submissiondate SubmissionDate
rename antenatal maternalservices
rename sdp_result SDP_result
rename date_groupsystem_date system_date


*******************************************************************************
* 4. RECODE/CLEAN VARIABLES
*******************************************************************************

* Country/round identifying variables
gen country = "`country'"
gen round = `roundnum' 
label var country "PMA2020 country" 
label var round "PMA2020 round"  
order country-round, first 

foreach var of varlist _all{
capture replace `var'="No" if `var'=="no"
capture replace `var'="Yes" if `var'=="yes"
}

* Create label for yes/no variables
label define yes_no_dnk_nr_list -88 "-88" -99 "-99" 0 "No" 1 "Yes"

* RE name
rename gpyour_name your_name
rename gpname name
capture replace your_name=name_typed if your_name==""
rename your_name RE
label variable RE "RE"

* Managing Authority
label define managing_list 1 government 2 NGO 3 faith_based 4 private 5 other
encode managing_authority, gen(managing_authorityv2) lab(managing_list)
label define managing_list 1 "Government" 2 "NGO" 3 "Faith-based Organization" ///
4 "Private" 5 "Other", replace

* Position
label define positions_list 1 "Owner" 2 "In-Charge/Manager" 3 "Staff"
label values position positions_list

* Generate all date/dateTime varibles in STATA internal form (SIF)
* DateTime: generate SIF variables
foreach x of varlist start end  system_date {
capture confirm variable `x'
if _rc==0 { 
 gen double `x'SIF=clock(`x', "MDYhms")
 format `x'SIF %tc
 } 
}

* Today
gen double todaySIF=clock(today, "YMD")
format todaySIF %tc

* Begin working, open year, fp begin: generate SIF variables
foreach x of varlist  fp_begin  {
capture confirm variable `x'
if _rc==0 {
 gen double `x'SIF=clock(`x', "MDY")
 format `x'SIF %tc
 }
}

* Order new *SIF variables to be next to string counterpart
unab vars: *SIF
local stubs: subinstr local vars "SIF" "", all
foreach var in `stubs'{
cap order `var'SIF, after(`var')
}

 
* Catchment area
label define catchment_list 1 no_catchment 2 yes_knows_size -88 "-88" -99 "-99"
encode knows_population_served, gen (knows_population_servedv2) lab(catchment_list)
label define catchment_list -88 "Doesn't know size of catchment area" ///
-99 "No response" 1 "No catchment area" 2 "Yes, knows size of catchment area", replace




/* CHV methods offered
gen chv_condoms=regexm(methods_offered, "male_condoms") if methods_offered~=""
gen chv_pills=regexm(methods_offered, "pill") if methods_offered~=""
gen chv_injectables=regexm(methods_offered, "injectables") if methods_offered~=""
order chv_condoms-chv_injectables, after(methods_offered)
*/

* Mobile outreach
foreach var in mobile_outreach_6mo {
capture confirm variable `var'
if _rc==0 {
     gen any_`var'=.
     replace any_`var'=0 if `var'==0
     replace any_`var'=1 if `var'>0 & `var'!=. & `var'!=-88 & `var'!=-99
     label val any_`var' yes_no_dnk_nr_list 
  cap order any_`var', after(`var')
  }
  }




* SDP Result
label define SDP_result_list 1 completed 2 not_at_facility 3 postponed 4 refused 5 partly_completed 6 other
encode SDP_result, gen(SDP_resultv2) lab(SDP_result_list)
label define SDP_result_list 1 "Completed" 2 "Not at facility" ///
3 "Postponed" 4 "Refused" 5 "Partly completed" 6 "Other", replace

 

*******************************************************************************
* 5. GENERATE FP METHOD VARIABLES
*******************************************************************************

/*
* Contraceptives : Provided by CHWs
foreach method in `methods_short' {
gen provided_chv_`method'=regexm(fp_provided_chvs, "`method'") if fp_provided_chvs~=""
label values provided_chv_`method' yes_no_dnk_nr_list
}
*/

* Contraceptives: Provided by CHVs 
foreach method in `methods_chv' {
gen provided_chv_`method'=regexm(methods_offered, "`method'") if methods_offered~=""
label values provided_chv_`method' yes_no_dnk_nr_list
}


* FP method  : Provided by facility
foreach method in `methods' {
gen provided_`method'=regexm(fp_provided, "`method'") if fp_provided~=""
label values provided_`method' yes_no_dnk_nr_list
}


* FP methods: charged 
foreach method in `methods' {
rename `method'_charged charged_`method'
cap encode charged_`method', gen(charged_`method'v2) lab(yes_no_dnk_nr_list)
}


* Stockouts today
label define stock_list 1 instock_obs 2 instock_unobs 3 outstock -99 "-99"
foreach method in `methods_stock_full' {
tostring fpp_os_`method', replace
encode fpp_os_`method', gen(stock_`method'v2) lab (stock_list)
}
label define stock_list 1 "In-stock and observed" ///
2 "In-stock but not observed" 3 "Out of stock" -99 "No response", replace

/*
* Order generated stockout variables
foreach var in `methods_stock_full' {
order stockout_3mo_`var'v2, after (stockout_3mo_`var')
drop stockout_3mo_`var'
rename stockout_3mo_`var'v2 stockout_3mo_`var' 
}*/

* Rename  provided_*, and charged_* variables to be consistent with earlier rounds
foreach var in  provided  charged {
cap rename `var'_fster `var'_female_ster
cap rename `var'_mster `var'_male_ster
cap rename `var'_impl_j `var'_implants_jad
cap rename `var'_impl_i `var'_implants_impla
cap rename `var'_impl_oth `var'_implants_other
capture rename `var'_inj_oth `var'_injectables_other
capture rename `var'_inj_sp `var'_injectables_sp

capture rename `var'_iud_lyd `var'_iud_lydia
capture rename `var'_ius_eli `var'_iud_eloira
capture rename `var'_iud_oth `var'_iud_other
cap rename `var'_pill_levofem `var'_pill_levofem
cap rename `var'_pill_oth `var'_pill_other
cap rename `var'_mc `var'_male_condoms
cap rename `var'_fc2 `var'_female_condoms_fc2
cap rename `var'_fc_oth `var'_female_condoms_other
capture rename `var'_dia_caya `var'_diaphragm_caya
capture rename `var'_dia_oth `var'_diaphragm_other
}

*******************************************************************************
* 6. LABEL VARIABLES
*******************************************************************************

* Encode and label Yes/No variables 
foreach var  in rec_commodities provide_commodities whole_site_orient hmis imp_other_os3 iud_cu250_os3 ///
iud_cu375_os3 iud_cu380_os3 iud_tcu380a_os3 iud_ppiud_os3 iud_other_os3 inj_sp_os3 inj_other_os3 ///
 pill_other_os3 ec_postpill_os3 ec_other_os3 mc_fiesta_os3 mc_kiss_os3 mc_other_os3 female_condom_os3 ///
 diaphram_os3 foam_jelly_os3 std_days_beads_os3  hiv_condom hiv_other_fp share_org {
cap encode `var', gen(`var'v2) lab(yes_no_dnk_nr_list)
} 



* Order and rename generated variables
foreach var in rec_commodities provide_commodities whole_site_orient hmis  imp_other_os3 iud_cu250_os3 ///
iud_cu375_os3 iud_cu380_os3 iud_tcu380a_os3 iud_ppiud_os3 iud_other_os3 inj_sp_os3 inj_other_os3 ///
 pill_other_os3 ec_postpill_os3 ec_other_os3 mc_fiesta_os3 mc_kiss_os3 mc_other_os3 female_condom_os3 ///
 diaphram_os3 foam_jelly_os3 std_days_beads_os3 hiv_condom hiv_other_fp share_org {
cap  `var'v2, after (`var')
drop `var'
cap rename `var'v2 `var' 
}

/*
* Order generated stock variables
foreach var in `methods_stock_full' {
cap order stock_`var'v2, after (stock_`var')
drop stock_`var'
rename stock_`var'v2 stock_`var' 
}
*/

**Services provided at facility
local services "antenatal delivery postnatal postabortion"

foreach service in `services' {
gen `service'=regexm(maternalservices, "`service'") if maternalservices~=""
label values `service' yes_no_dnk_nr_list
}


* Label method related FP variables

/*foreach method in `methods'{
label variable counseled_`method' "Counsel on `method'" 
}*/

foreach method in `methods_short' {
label variable provided_`method' "Provide `method'"
label variable charged_`method' "Charge for `method'" 
label variable fees_`method' "Fees for `method'"
label variable sold_`method' "Number of `method' sold in last month"
}

label variable visits_female_ster "Number of female sterilization visits in last month"
label variable visits_male_ster "Number of male sterilization visits in last month"
foreach method in `methods_stock_full' {
label variable visits_`method'_new "Number of new `method' visits in last month" 
label variable visits_`method'_total "Number of total `method' visits in last month" 
label variable stock_`method' "Observed and in/out stock: `method'"
label variable stockout_days_`method' "Number of days have been stocked out of `method'" 

}

* Label other non-country specific variables

label variable fp_beginSIF "Month and year began providing FP (SIF)"
label variable startSIF "SDP interview start time (SIF)"
label variable start "SDP interview start time (string)"
label variable endSIF "SDP interview end time (SIF)"
label variable end "SDP interview end time (string)"
cap label variable SubmissionDateSIF "Date and time of SDP submission (SIF)"
cap label variable SubmissionDate "Date and time of SDP submission (string)"
label variable system_date "Current date & time (string)"
label variable system_dateSIF "Current date & time (SIF)"
label variable today "Date of interview (string)"
label variable todaySIF "Date of interview (SIF)"
label variable facility_type "Type of facility"
label variable advanced_facility "Advanced facility"
label variable managing_authority "Managing authority"
label variable available "Competent respondent available for interview"
label variable consent_obtained "Consent obtained from interviewee"
label variable position "Interviewee position at facility"
label variable days_open "Number of days per week facility is open"

label variable knows_population_served "Know size of catchment area"
label variable population_served "Size of catchment population"
label variable elec_cur "Facility has electricity at this time"
label variable water_cur "Facility has water at this time"
label variable fp_offered "Facility usually offers FP"
label variable fp_provided "Which of the following methods are provided to clients at this facility?"
label variable fp_community_health_volunteers "Facility provides family planning supervision, support, or supplies to CHVs"
label variable num_fp_volunteers "Number of family planning CHVs supported by facility"
label variable fp_community_health_volunteers "Facility provides supervision, support, or supplies to CHVs"
label variable num_fp_volunteers "Number of CHVs supported by facility"
label variable methods_offered "CHVs provide FP methods"


label variable implant_insert "Personnel able to insert implant"
label variable implant_remove "Personnel able to remove implant"
label variable iud_insert "Personnel able to insert IUD"

label variable maternalservices "Types of maternal health services offered"
label variable hiv_services "Facility offers HIV services"
label variable hiv_condom "Facility offers condoms when client comes in for HIV services"
label variable hiv_other_fp "Facility offers other FP services to HIV clients"
label variable SDP_result "SDP interview result"
cap label variable maternalservices "Provide antenatal services" 
label variable delivery "Provide delivery services"
label variable postnatal "Provide postnatal services"
label variable post_abortion "Provide post-abortion services"
label variable fp_begin "Month and year began providing FP (string)"
label variable fp_days "Number of days per week FP offered"
label variable fp_today "FP offered today"
capture label variable num_fp_volunteers "Number of CHVs supported to provide FP services" 
label variable locationlatitude "Facility location: latitude"
label variable locationlongitude "Facility location: longitude"
label variable locationaltitude "Facility location: altitude"
label variable locationaccuracy "Facility GPS accuracy"
label variable facility_name "Facility name"
label variable facility_name_other "Facility name (other)"
label variable facility_number "Facility number"
capture label var work_begin "When did you begin working at this facility (string)"
capture label var work_beginSIF "When did you begin working at this facility (SIF)"

capture confirm variable any_mobile_outreach_6mo
if _rc==0 {     
label variable any_mobile_outreach_6mo "Facility has had mobile outreach team visit in last 6 months"
}


label define yes_no_dnk_nr_list -88 "Don't know" -99 "No response" 0 "No" 1 "Yes", replace


*******************************************************************************
* 11. DROP UNNECESSARY VARIABLES 
*******************************************************************************

* Drop country-specific variables
* UPDATE BY COUNTRY


* Drop variables
drop date_groupsystem_date_check manual_date your_name_check name_typed services_info ///
consent_start consent begin_interview witness_auto witness_manual staffing_prompt /// 
facility_open_string fps_info *_note  *_label deviceid simserial phonenumber key

*******************************************************************************
* 12. SAVE DATA AND CLOSE LOG
*******************************************************************************

numlabel, add

saveold "`CCRX'_SDP_$date_Prelim.dta", version(12) replace

log close


