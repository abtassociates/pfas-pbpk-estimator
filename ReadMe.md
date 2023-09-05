# ATSDR PFAS PBPK Water to Serum Estimator


## Description
The purpose of this project is to produce an R implementation of estimation code for a previously developed web-based calculator to predict individual serum levels of PFAS. 
A built-for-the-web version of this model runs in a user's browser and is implemented in typescript.js. 
This R implementation is intended for research, publication, and testing purposes, and will not replace the typescript.js model for web users. It was used in the preparation of the following manuscript: 

**Meghan T. Lynch, Claire R. Lay, Sara Sokolinski, Adriana Antezana, Carleen Ghio, Weihsueh Chiu, Rachel Rogers. 2023. Community-facing toxicokinetic models to estimate PFAS serum levels based on life history and drinking water exposures. Environment International. 176: 107974. DOI: 10.1016/j.envint.2023.107974.**

Please note: This code can take considerable time to run due to the iterative nature of the calculations and the design of the data inputs, which were designed to match the implementation in javascript as closely as possible. A more user-friendly and much faster version of this model for processing multiple individual exposure histories at once is currently in development for use in the browser-based web tool. The authors will update this repository with more information on access when it is available.  
 
## Getting Started

1. To test the code or to run a simulation of an individual, copy this folder to a location with access to R. 
The code works most easily using the Rstudio Integrated Development Environment. 

2. Initiate an [RStudio project](https://support.rstudio.com/hc/en-us/articles/200526207-Using-RStudio-Projects) inside of this folder. Open the RStudio project in a new R session. 

3. Open a sample simulation file, and save with desired name. Simulation can be run without opening any file other than the 'simulation' markdown files ending in ".Rmd". To begin, open "simulation" markdown file under the top level of the "markdowns" folder. Example simulations are provided for specific situations (see file names and descriptions below for definitions). These files include code to check for and load required package installations ('library'). They will set parameters and produce simulated historical blood serum concentrations for a single individual. Name of author can be set at the top of the file if preferred. 

4. Set 'save_output' If it is set to TRUE, knitting the file will save the full .Rdata output with estimated serum values for each selected time-step. If it is set to FALSE, the markdown file will only produce plots. 

5. Modify the parameters for the simulated individual-level output of serum concentrations by updating the aruments in 'param_list'. See definitions in the Markdown table under "User Set Parameters"

6. Either step through each code chunk to examine the process, or knit the file to produce output. When 'knit', the updated simulation files produce MS word document and .html output files into the folder: 'markdowns/markdown', as well as plotting output in dated 'plots' folders. The format and content can be modified as needed. 

The following sections describe the contents of all files included in this review package. 

<mark>Note to ATSDR/CDC peer reviewers: Only the files starting in 'simulate_PBPK' under the 'markdowns' folder need be opened to run estimates for simulated serum concentrations. Files and folders containing code included for the review package only are noted in the descriptions below.</mark> 

## 1. **Data File** (/data)

### **source_PBPK.xlsx** 
The only source data file for running the R model, it contains all the data used as assumptions. See the ReadMe tab of the file for detailed contents and source information. source data (1a) is created by loading each tab into a list.  

## 2. **Markdowns** (/markdowns)

####  a. **Simulate PBPK** 

These are the only files that must be opened to run simulations. They represent individual examples for the specified demographics. 

1) **[simulate_PBPK_male.Rmd](markdowns/simulate_PBPK_male.Rmd) (the R model)**  (around 290 lines)  
This file is the main file to run the model. It allows the user to change select input parameters. This markdown is a basic structure for simulating concentrations for a single individual.
    It uses **all the modeling functions** to look up values from **source_PBPK.xlsx**, produce iterations for Monte Carlo simulations, calculate results, plot and save. The results are constructed in the form of a data frame, with each row representing a time step. These are wrapped into a list including all iterations.   

2) **[simulate_PBPK_mother.Rmd](markdowns/simulate_PBPK_mother.Rmd)**  (around 290 lines)  
   This file is the same as simulate_PBPK_male.Rmd, except it shows an example of a mother.	 

3) **[simulate_PBPK_child_bf.Rmd](markdowns/simulate_PBPK_child_bf.Rmd)**  (around 290 lines)  
   This file is the same as simulate_PBPK_male.Rmd, except it shows an example of a breastfeeding infant.	 

4) **[simulate_PBPK_child_tap.Rmd](markdowns/simulate_PBPK_child_tap.Rmd)**  (around 290 lines)  
   This file is the same as simulate_PBPK_male.Rmd, except it shows an example of an infant fed formula made with tap water.	 

5) **[simulate_PBPK_child_other.Rmd](markdowns/simulate_PBPK_child_other.Rmd)**  (around 290 lines)  
   This file is the same as simulate_PBPK_male.Rmd, except it shows an example of an infant fed store-bought formula (not mixed with tap water).	 
	
#### b. **Sensitivity Analysis**

1) **[simulate_PBPK_sensitvty_F6mo.Rmd](markdowns/sensitivity/simulate_PBPK_sensitivity_F6mo.Rmd)** (around 520 lines)  
   This markdown file creates a figure of serum concentration sensitivities for a 6 month old female. First the function **param_make** is used to create a parameter list for PFOA. Next, the **mc_create_child** function is used to create the data frame of model inputs at low, mid and high levels. The markdown uses the function **serum_sensitiv_runs** to pass these inputs through the model. Then, it uses the output and the **tornado_plot** function to plot the results and save them to the 'plots' folder. The chemical in the parameter list is changed and the process is repeated for each chemical. Lastly, the plots are joined together and the complete figure is saved to the 'plots' folder.
   
2) **[simulate_PBPK_sensitvty_F35_BF.Rmd](markdowns/sensitivity/simulate_PBPK_sensitivity_F35_BF.Rmd)** (around 515 lines)  
   This markdown file creates a figure of serum concentration sensitivities for a 35 year old female who breast fed two children. This markdown works the same as **simulate_PBPK_sensitivity_F6mo.Rmd**, except using the **mc_create_F** function.
   
3) **[simulate_PBPK_sensitvty_M8.Rmd](markdowns/sensitivity/simulate_PBPK_sensitivity_M8.Rmd)** (around 510 lines)  
   This markdown file creates a figure of serum concentration sensitivities for a 8 year old male. This markdown works the same as **simulate_PBPK_sensitivity_F6mo.Rmd**. It also uses **mc_create_child** but sets the value of infant (whether the individual is younger than 6 months) to FALSE to omit the sensitivities for MatXfer (Maternal Transfer Rate), PlacXfer (Placental Transfer Rate), and MilkClearance.
   
4) **[simulate_PBPK_sensitvty_M40.Rmd](markdowns/sensitivity/simulate_PBPK_sensitivity_M40.Rmd)** (around 500 lines)  
   This markdown file creates a figure of serum concentration sensitivities for a 40 year old male. This markdown works the same as **simulate_PBPK_sensitivity_F6mo.Rmd**, except using the **mc_create_M** function.


## 3. Parameters
The R model needs an input parameter list to produce output. The following table defines the parameters. These are set directly in the Simulate PBPK markdowns (2a). Parameters are created in the Sensitivity Analysis markdowns (2b) using the function param_make().

Variable | Description          | Notes
---------|-------------|-------------------------|
chemical | PFAS contaminant |  "PFOA", "PFOS", "PFNA", or "PFHxS"
water_concs | list of drinking water concentrations (ug/L) | concentrations default to 0 before 1960
water_concs_dates | list of dates to apply changes to water concentration | list should be initialized at birth or earlier and dates must be in the format "YYYY-MM-DD"  
perc_tap | list of percentages of daily water intake that comes from tap water | list must contain fractions e.g. 90% = .9
perc_tap_dates | list of dates to apply changes to perc_tap | list should be initialized at birth or earlier and dates must be in the format "YYYY-MM-DD"  
gender | sex | "Female" or "Male"
BW | body weight (kg) | used to select body weight percentiles; the weight should correspond to the age calcuated using the simulation creation date (creation_date), NOT at the end date (ed)
fed_most | whether the individual as an infant was mostly breast fed, fed formula made with tap water, or was fed other store bought formula | "breast milk", "tap water", or "other formula";  "tap water" should be used for adults
fed_mo | number of months after birth the individual was mostly fed fed_most | NA when fed_most = "tap water" or to use defaults of 6 months for fed_most = "breast milk" and 12 months for fed_most = "other formula"; the model data only allows for up to 6 months for breast feeding
mom_pct_tap | the individual's mother's percent of drinking water intake from tap water during pregnancy and breastfeeding | used in placental transfer calculation; must be a fraction and the model defaults to 1 (100%)
numChild | number of children the individual has given birth to | only breast fed children are relevant to a mother's serum calculation
child_gender | list of each child's gender | list must be of length numChild
child_bday | list of each child's birthday | list must be of length numChild and dates must be in the format "YYYY-MM-DD" 
child_bf_mo | list of each child's duration of breast feeding in months| list must be of length numChild; the model data only allows for up to 6 months for breast feeding; if a child was not breast fed use 0 or NA to ignore them
creation_date | manual override for matching calculations run on previous days | defaults to today's date but should correspond with the date the body weight data was provided
niter | number of Monte Carlo iterations | suggested value of 1000; values over 1000 not recommended to avoid intensive computing.  
timestep | number of days between calculations | suggested value of 30
sd | simulation start date | the individual's birthday in the format "YYYY-MM-DD"
ed | simulation end date | may not be exact due to time step

## 4. Scripts
    
All functions are described by code comments within the scripts and in Simulate PBPK markdowns for modeling functions. Scripts listed without any sub-functions contain only one function of the same name. 

### **Modeling Functions** (scripts/functions/)

Scripts included under this heading are for use in the main model. They will be shared by the authors to readers of the published manuscript upon request. 

#### **[main_function](scripts/functions/main_function.r)** (around 110 lines)
This is the main wrapper function that loops through a single simulated iteration. The inputs are the parameter_list, the source data (1a), and the 14 MC varied variables: DWIaf, BW, HL, V_d, MatXfer, MatRemove, MilkClearance, PlacXfer, BkgdF, BkgdM, BkgdFk, BkgdMk, perc_tap, and concs. (See monte_carlo_vars) It also takes the input iter for printing out the Monte Carlo iteration number. When full is set to TRUE the function outputs all timesteps, instead of filtering to the last timestep. 

### **distributions** (scripts/functions/distributions)
#### **[icdf_distributions](scripts/functions/distributions/icdf_distributions.r)**
* **icdf(dtype, prob, parm1, parm2)  - Inverse Cumulative Distribution Function** (around 20 lines)  
Given the distribution type, probability, mean, and standard deviation, this function returns the value within the distribution corresponding to that probability.
* **icdfLogNormal(prob, GM, GSD) - Log-normal Inverse Cumulative Distribution Function** (around 25 lines)  
Given the probability, geometric mean, and geometric standard deviation, this function returns the value within a Lognormal distribution corresponding to that probability.
* **icdfNormal(prob, mu, dev) - Normal Inverse Cumulative Distribution Function** (around 50 lines)   
Given the probability, mean, and standard deviation, this function returns the value within a Normal distribution corresponding to that probability.

#### **[random_distributions](scripts/functions/distributions/random_distributions.r)**  
* **rNormal(mu, sd) - Normal Random Function**  (around 35 lines)
Given mean and standard deviation, this function returns a random value within a Normal distribution.
* **rLogNormal(GM, GSD) - Lognormal Random Function**  (around 20 lines)
Given geometric mean and geometric standard deviation, this function returns a random value within a LogNormal distribution.
* **rrandom(dtype, parm1, parm2) - Random Function**   (around 20 lines)
Given the distribution type, mean and standard deviation, this function returns a random value within the distribution.

#### **[make_rnd_stream](scripts/functions/distributions/make_rnd_stream.r)** (around 50 lines)
Given the mean, standard deviation, distribution type, number of iterations (n), and run type (either icdf or random), this function returns a vector of length n either using **icdf()** or **rrandom()**. If using icdf, it uses every probability between 0 and 1 increasing by 1/n. This ensures the resulting vector has the exact distribution, rather than when using random we get an approximation.

#### **[monte_carlo_vars](scripts/distributions/monte_carlo_vars.r)** (around 110 lines)  
This function maps the values in the MonteCarlo list from the source data (1a) into make_rnd_stream(). It takes the parameter list and source data object (1a) as inputs. It uses chemical, BW, perc_tap, water_concs and niter.  
It creates variable streams from R model parameters using inverse cumulative distribution functions, but can be switched to random variable streams with the additional input of RunType = "random" to make_rnd_stream().  The function returns 14 Monte Carlo variables, an adjustment factor for drinking water intake (DWIaf), half life (HL), volume of distribution (V_d), body weight (BW), percentage maternal transfer to breastmilk (MatXfer), percentage placental transfer to infant serum (PlacXfer), the milk clearance rate (MilkClear), and maternal serum elimination during breastfeeding (MatRemove), adult background serums (BkgdF & BkgdM) and child background serums (BkgdFk & BkgdMk), water concentrations (concs), and percentage water intake from tap water (perc_tap).

#### **[shuffle_array](scripts/distributions/shuffle_array.r)** (around 25 lines)
This function shuffles a vector. It is used within MakeRndStream.

#### **[quantile_list](scripts/plotting/quantile_list.R)** (around 35 lines) 
Given the final results object, this function calculates the mean, 5th and 95th percentiles of the column Serum_a for all MonteCarlo iterations. It returns a summary data frame. 

### **populate_frame** (scripts/functions/populate_frame/)
#### **[age_adjust](scripts/functions/populate_frame/age_adjust)** (around 25 lines)  
Given the number of days lived and the look up table in the Age_adjust tab of the source file (1a), this function returns the appropriate adjustment factor for that age. 

#### **[create_frame](scripts/functions/populate_frame/create_frame.r)** (around 35 lines)  
This function stages the output data frame, names the columns, then populates dates and age variables. It requires inputs sd, ed & timestep from the parameter list.

#### **[pop_AA_VD](scripts/functions/populate_frame/pop_AA_VD.r)** (around 20 lines)  
Given the model data frame, the source data (1a) object, and MC varied V_d, the function passes the column Days (age in days) to ageAdjust(), along with the Age-Adjust list from the source data (1a). It looks up age adjustment factors and populates the column V_d by multiplying the volume of distribution by this vector.

#### **[pop_BG](scripts/functions/populate_frame/pop_BG.r)** (around 45 lines)  
Given the model data frame, all MC varied options of background serum, and the parameters gender, creation_date, sd (start date), HL (half life) and timestep, this function first calculates the current age. It is calculated by the difference between the start date  and the creation date. The function then populates the Bkgd_serum column of the data frame. The initial background serum is decided using that current age and gender to determine if we apply male or female background serums for children or adults. Children are considered younger than 12 years old. For every other time step, we calculate a time step adjustment. This represents the portion of the background serum that was eliminated in the previous time step.

#### **[pop_BW](scripts/functions/populate_frame/pop_BW.r)** (around 75 lines)  
The function inputs are the model data frame, the source data (1a) object, MonteCarlo varied BW, and the parameters creation_date, gender, and sd.
The model calculates the current age at the time of running the model by the difference between the start date (sd from parameters) and the creation date. A body weight percentile is selected using the current age, MC varied body weight and the smoothed percentiles of male or female body weights in BW_M or BW_F of the source data (1a). The model then populates the BW column by assuming the same body weight percentile at each age.   

#### **[pop_DWC](scripts/functions/populate_frame/pop_DWC.r)** (around 25 lines)  
Given the data frame, the lists of water concentrations and their respective sampling dates, this function populates the DWC column of the data frame looking up the drinking water concentration corresponding to the Date column.

#### **[pop_DWI_BMI](scripts/functions/populate_frame/pop_DWI_BMI.r)** (around 60 lines)  
The function inputs are the model data frame, the source data (1a), the MonteCarlo variable DWIaf, and parameters fed_most and fed_mo. First, it loads the DWI (drinking water intake) and Breastfeeding lists from the source data. If the individual is breast fed, the BMI column is populated from Breastfeeding for a maximum 6 months. If an individual is fed other formula, DWI is set to zero for a maximum of 12 months and if they are breast fed, DWI is set to zero during breastfeeding. fed_most is used to decide the calculations to perform, and fed_mo adjusts the length of breastfeeding or time drinking other formula. The DWI column is populated using the median values in the DWI list multiplied by the MC varied DWIaf (DWI adjustment factor). 

### **serum_calculations** (scripts/functions/serum_calculations/)
#### **[bf_days](scripts/functions/serum_calculations/bf_days.r)** (around 45 lines)
Given the data frame and the parameters gender, child_bday, and child_bf_mo, this function populates the Breastfeeding column and returns the populated data frame. Breastfeeding is set to 1 when a mother is breastfeeding her child, and 0 otherwise. 

#### **[daily_dose_BM](scripts/functions/serum_calculations/bf_days.r)** (around 55 lines)
Given the current age (calculated with parameters sd and creation_date), the Serum Clearance Rate from Breastfeeding (CRBFPerStep calculated with MC varied MatRemove), the Breast milk Clearance Rate (BMCRPerStep calculated with MC varied MilkClear), the data frame, and Monte Carlo variables MatXfer,  HL, V_d, BkgdF, and the parameter mom_pct_tap (mother's percent of drinking water intake from tap water), this function calculates the daily dose from breast milk. First, it populates the BMC (Breast Milk Concentration) column calculating the mother's steady state serum concentration at birth and multiplying by MC varied MatXfer to calculate the initial value. Then BMCRPerSetp is used to decay that value over time. Daily_Dose_BM is calculated with the columns BMC, BW, and BMI (Breast Milk intake). It also begins the serum calculations for breastfed infants by calculating an intial mother_serum (mother's steady state serum concentration) and using CRBFPerStep to decay over time. It returns the populated data frame. 

#### **[rescursive_serum](scripts/functions/serum_calculations/recursive_serum.r)**
* **recursive_serum() - Recusrive Serum Calculation** (around 80 lines)
This function takes the following inputs: the model data frame, DecayPerStep (calculated with MC varied HL), CRBFPerStep (Decay with additional decay for breast milk clearance), the current age (calculated with sd and creation_date), iter (number of recursions to perform), MC varied PlacXfer (Placental transfer), the timestep parameter, and a binary variable for whether an individual was breastfed. If iter = 1 the initial serum calculation is performed using curage to determine whether to use the adult or the infant calculation. For iter > 1, a recursive formula is performed and a list of serums is returned representing each serum timestep. The recursive formula returns serum concentrations going back all the way to the initial timestep. 
* **recursive_serum_large() - Recursive Serum Calculation** (around 60 lines)
This function performs the same calculation as recursive_serum() with the same inputs. For different operating systems, there is a limit of recursion. This function takes the value of recursive_serum for iter = 650 and then continues the calculation for more time steps. 

#### **[serum_calc](scripts/serum_calc_functions.r)** (around 125 lines)
This is a wrapper function used to populate the model data frame with the other serum calculation functions (bf_days(), daily_dose_BM(), recursive_serum() and recursive_serum_large()). It takes the following inputs: the model data frame, Monte Carlo varied perc_tap (percent drinking water intake from tap water), Maternal Transfer Rate, Placental Transfer Rate, Milk Clearance Rate, Maternal Removal Rate, half life, volume of distribution, and adult female background serum and from the parameter lists, the dates that perc_tap change, the timestep (number of days between calculatons), number of children given birth to, birthdays of children,
number of months each child was breastfed, gender, sd (start date, individual's birthday), creation_date (date used when calculating current age), mom_pct_tap (mother's percent tap at birth), and fed_most (main source of water as an infant, either "breast milk", "tap water", or "other formula")
This function populates the serum_b and serum_a columns by looping over the time steps and in the process also updates columns BMC, mother_serum, Daily_Dose_DW and Daily_Dose_BM. The HL is used to calculate the elimination rate (DecayPerStep); MatRemove is used to calculate the elimination rate during breastfeeding (CRBFPerStep); MilkClear is used to calculate the breast milk clearance (BMCRPerStep); and sd and creation_date are used to calculate the current age. The function populates the Daily_Dose_DW column before passing all these values to the underlying functions. Finally, it returns the populated data frame.

### **Sensitivity Analysis Functions** (scripts/analysis/sensitivity)

#### **[mc_create_functions](scripts/analysis/sensitivity/mc_create_functions.r)** 
* **mc_create_M** (around 50 lines)
Given the parameter list, source file, and ranges of values for the adult male sensitivity model inputs (low, mid, high), this function creates a data frame of model inputs for the sensitivity run. While it uses the monte_carlo_vars function, the parameter list (created with **param_make**) uses niter = 1 which results in only one row for each sensitivity value. The model inputs impacting adult males are body weight (BW_range), drinking water intake adjustment factors (DWIaf_range), half life (HL_range), volume of distribution (V_d_range), background serum (Bkgd_range), and water concentrations (concs_range).

* **mc_create_F** (around 50 lines)
Given the parameter list, source file, and ranges of values for the breastfeeding adult female sensitivity model inputs (low, mid, high), this function creates a data frame of model inputs for the sensitivity run. While it uses the monte_carlo_vars function, the parameter list (created with **param_make**) uses niter = 1 which results in only one row for each sensitivity value. The model inputs impacting adult males all also impact adult females. Women who have breast fed also are impacted by Maternal Removal Rates (MatRemove_range) which accounts for increased clearance from the mother's blood due to breastfeeding.

***mc_create_child** (around 100 lines)
Given the parameter list, source file, and ranges of values for the child sensitivity model inputs (low, mid, high), this function creates a data frame of model inputs for the sensitivity run. While it uses the monte_carlo_vars function, the parameter list (created with **param_make**) uses niter = 1 which results in only one row for each sensitivity value. The model inputs impacting adult males all also impact children. The function defaults to infant = TRUE which adds sensitivities for Maternal Transfer Rate (MatXfer_range, blood to milk), Placental Transfer Rate (PlacXfer_range, blood to blood), and Milk Clearance (MilkClear_range). For children over 6 months old (like the 8 year old male example), the value for infant is set to FALSE to omit these sensitivies.

#### **[param_make](scripts/analysis/sensitivity/param_make.r)** (around 80 lines)
This function creates a parameter list that defaults to PFOA for a 40 year old male born on 1982-01-01 weighing 81.6 kg who drinks 90% of his water from the tap. The water concentrations are 0.1 ug/L before 2020-01-01 and 0.002 ug/L afterwards. The time step is 30 days and the number of iterations to create is 1. Parameter lists for other individuals and chemicals use these default settings and only modify the parameters that would be different. The only parameter that cannot be changed is the creation_date which is assumed to be the end date (ed). This creates reproducible results.

#### **[serum_sensitiv_runs](scripts/analysis/sensitivity/serum_sensitiv_runs.r)** (around 50 lines)
This function takes the data frames of model inputs (created by mc_create_functions) and passes them into the **main_func** along with the parameter list (created using **param_make**) and the source data. It returns a data frame of the model inputs joined with the last serum value. 

#### **[tornado_plot](scripts/analysis/sensitivity/tornado_plot.r)** (around 50 lines)
This function needs the data frame of model results (created by **serum_sensitiv_runs**) pivoted longer and filtered to low and high levels. It also needs a baseline value, which is the result from the mid level runs that should match for all variables. The inputs var, level, val and result identify the column names for the the variable name being varied, the sensitivity level, the variable value, and the serum concentration result, respectively. The input h_just is set to NA by default, but can be set to 0 to shift labels right to avoid over plotting. The input var_order allows the user to override the sorting of variables. Bkgd is the value of the background serum in ug/L which is plotted as a vertical line. line_label controls whether to label that line. The input together, which defaults to NA, is a list of variables that should paste their high and low level labels into one. This avoids over plotting of labels when impacts are small.


## Contributing Team for this code

**Team Leads (Contacts) : 
[Meghan Lynch](Meghan_Lynch@abtassoc.com)
[Sara Sokolinksi](Sara_Sokolinski@abtassoc.com)
[Claire Lay](Claire_Lay@abtassoc.com)

#### Other Members:

|Name     |  Email   | 
|---------|-----------------|
|[Carleen Ghio]| (Carleen_Ghio@abtassoc.com)
|[Adriana Antezana]| (Adriana_Antezana@abtassoc.com)

