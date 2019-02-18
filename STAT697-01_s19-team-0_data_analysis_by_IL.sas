*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";

* load external file generating "analytic file" dataset cde_analytic_file, from
  which all data analyses below begin;
%include '.\STAT697-01_s19-team-0_data_preparation.sas';


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Question: What are the top five California public K-12 schools experiencing the biggest increase in Free/Reduced-Price Meal Eligibility Rates between AY2014-15 and AY2015-16?'
;

title2 justify=left
'Rationale: This should help identify schools to consider for new outreach based upon increasing child-poverty levels.'
;

footnote1 justify=left
"Of the five schools with the greatest increases in percent eligible for free/reduced-price meals between AY2014-15 and AY2015-16, the percentage point increase ranges from about 67% to about 86%."
;

footnote2 justify=left
"These are significant demographic shifts for a community to experience, so further investigation should be performed to ensure no data errors are involved."
;

footnote3 justify=left
"However, assuming there are no data issues underlying this analysis, possible explanations for such large increases include changing CA demographics and recent loosening of the rules under which students qualify for free/reduced-price meals."
;

* 
Note: This compares the column "Percent (%) Eligible Free (K-12)" from frpm1415
to the column of the same name from frpm1516.

Limitations: Values of "Percent (%) Eligible Free (K-12)" equal to zero should
be excluded from this analysis, since they are potentially missing data values 
;

proc sql outobs=5;
    select
         School
        ,District
        ,Percent_Eligible_FRPM_K12_1415
        ,Percent_Eligible_FRPM_K12_1516
        ,FRPM_Percentage_Point_Increase
    from
        cde_analytic_file
    where
        Percent_Eligible_FRPM_K12_1415 > 0
        and
        Percent_Eligible_FRPM_K12_1516 > 0
    order by
        FRPM_Percentage_Point_Increase desc
    ;
quit;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Research Question: Can Free/Reduced-Price Meal Eligibility Rates be used to predict the proportion of high school graduates earning a combined score of at least 1500 on the SAT in AY2014 at California public K-12 schools?'
;

title2 justify=left
'Rationale: This would help inform whether child-poverty levels are associated with college-preparedness rates, providing a strong indicator for the types of schools most in need of college-preparation outreach.'
;

footnote1 justify=left
"As can be seen in this exploratory analysis, there is an extremely clear negative correlation between student poverty and SAT scores in AY2014-15, with lower-poverty schools much more likely to have high proportions of students with combined SAT scores exceeding 1500."
;

footnote2 justify=left
"Possible explanations for this correlation include child-poverty rates tending to be higher at schools with lower overall academic performance and quality of instruction. In addition, students in non-poverish conditions are more likely to have parents able to pay for SAT preparation."
;

footnote3 justify=left
"Given this apparent correlation based on descriptive methodology, further investigation should be performed using inferential methodology to determine the level of statistical significance of the result."
;

* 
Note: This compares the column "Percent (%) Eligible Free (K-12)" from frpm1415
to the column PCTGE1500 from sat15.

Limitations: Values of "Percent (%) Eligible Free (K-12)" equal to zero should
be excluded from this analysis, since they are potentially missing data values,
and missing values of PCTGE1500 should also be excluded
;

proc rank
        groups=10
        data=cde_analytic_file
        out=cde_analytic_file_ranked
    ;
    var Percent_Eligible_FRPM_K12_1415;
    ranks Percent_Eligible_FRPM_K12_rank;
run;
proc rank
        groups=10
        data=cde_analytic_file_ranked
        out=cde_analytic_file_ranked
    ;
    var Percent_with_SAT_above_1500;
    ranks Percent_with_SAT_above_1500_rank;
run;

proc freq data=cde_analytic_file_ranked;
    table
          Percent_Eligible_FRPM_K12_rank
        * Percent_with_SAT_above_1500_rank
        / norow nocol nopercent
    ;
    label
        Percent_Eligible_FRPM_K12_rank=" "
        Percent_with_SAT_above_1500_rank=" "
    ;
    where
        not(missing(Percent_Eligible_FRPM_K12_1415))
        and
        not(missing(Percent_with_SAT_above_1500))
    ;
run;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Research Question: What are the top ten California public K-12 schools were the number of high school graduates taking the SAT exceeds the number of high school graduates completing UC/CSU entrance requirements?'
;

title2 justify=left
"Rationale: This would help identify schools with significant gaps in preparation specific for California's two public university systems, suggesting where focused outreach on UC/CSU college-preparation might have the greatest impact."
;

footnote1 justify=left
"All ten schools listed appear to have extremely large numbers of 12th-graders graduating who have completed the SAT but not the coursework needed to apply for the UC/CSU system, with differences ranging from 147 to 282."
;

footnote2 justify=left
"These are significant gaps in college-preparation, with some of the percentages suggesting that schools have a college-going culture not aligned with UC/CSU-going. Given the magnitude of these numbers, further investigation should be performed to ensure no data errors are involved."
;

footnote3 justify=left
"However, assuming there are no data issues underlying this analysis, possible explanations for such large numbers of 12th-graders completing only the SAT include lack of access to UC/CSU-preparatory coursework, as well as lack of proper counseling for students early enough in high school to complete all necessary coursework."
;

*
Note: This compares the column NUMTSTTAKR from sat15 to the column TOTAL from
gradaf15.

Limitations: Values of NUMTSTTAKR and TOTAL equal to zero should be excluded
from this analysis, since they are potentially missing data values
;

proc sql outobs=10;
    select
         School
        ,District
        ,Number_of_SAT_Takers /* NUMTSTTAKR from sat15 */
        ,Number_of_Course_Completers /* TOTAL from gradaf15 */
        ,Course_Completers_Gap_Count
        ,Course_Completers_Gap_Percent format percent12.1
    from
        cde_analytic_file
    where
        Number_of_SAT_Takers > 0
        and
        Number_of_Course_Completers > 0
    order by
        Course_Completers_Gap_Count desc
    ;
quit;
