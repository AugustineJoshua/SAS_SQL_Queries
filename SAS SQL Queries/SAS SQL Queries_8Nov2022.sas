/*Import sheet 'YourDatasheet'*/
proc import datafile='C:\MyFolder\MyDatafile.xlsx'
out=import dbms=xlsx replace;
sheet='O2Consumption';
run;

data import; set work.import;
if ID='ABC001' then group='1';
if ID='ABC002' then group='1';
if ID='ABC003' then group='1';
if ID='ABC004' then group='1';
if ID='ABC005' then group='1';
if ID='ABC006' then group='1';
if ID='ABC007' then group='2';
if ID='ABC008' then group='2';
if ID='ABC008' then group='2';
if ID='ABC009' then group='2';
if ID='ABC010' then group='2';

run;

/*See Contents*/
proc contents data=work.import;
run;

proc print data=work.import;
run;

/*Means*/
proc means data=work.import n nmiss mean std stderr median min max qrange maxdec=4 nway;
class group;
var VO2_L_min Var6 HR_min VO2_HR_mL RER;
run;

/*Selecting all variables from the dataset*/
proc sql; 
select *
from work.import;
quit; 

/*Display the list of columns to the SAS log*/
proc sql feedback; 
select * 
from work.import;
quit;

/*Selecting specific variables from the dataset*/
proc sql; 
select ID, Week, MaximumVsAverage, Task1VsTask2, VO2_L_min, Var6, HR_min, VO2_HR_mL, RER
from work.import;
quit;

/*Limiting the number of rows on display in viewer*/
proc sql outobs=10; 
select ID, Week, MaximumVsAverage, Task1VsTask2, VO2_L_min, Var6, HR_min, VO2_HR_mL, RER
from work.import;
quit;

/*Renaming a variable in output*/
options nolabel;
proc sql; 
select Var6 as VO2perKg_mL_min_kg
from work.import;
quit;

/*Labelling variables*/
options label;
proc sql;
select Var6,
var6 label="VO2perKg_mL_min_kg"
from work.import;
quit;

/*Formatting variables*/
proc sql;
select Var6 format 8.2
from work.import;
quit;

/*Creating a new variable*/
proc sql; 
select VO2_L_min, (VO2_L_min*1000) as VO2_mL_min
from work.import;
quit;

/*Referring to a previously calculated variable to create a new variable with a different unit of measurement*/
proc sql; 
select VO2_L_min, (VO2_L_min*1000) as VO2_mL_min,
CALCULATED VO2_mL_min/82 as VO2_mL_min_kg
from work.import;
quit;

/*Referring to a previously calculated variable to create a new variable - Oxygen Pulse*/
proc sql; 
select VO2_L_min, (VO2_L_min*1000) as VO2_mL_min,
CALCULATED VO2_mL_min/72 as VO2_mL_min_HR
from work.import;
quit;

/*Removing duplicate rows*/
proc sql;
select distinct *
from work.import;
quit;

/*Sorting data*/
proc sql; 
select ID, Week, MaximumVsAverage, Task1VsTask2
from work.import
order by ID asc, Week asc, MaximumVsAverage desc;
quit;

/*Subsetting data with WHERE, BETWEEN-AND, CONTAINS-OR, IN, IS MISSING, IS NULL, LIKE*/
proc sql;
select VO2_L_min, (VO2_L_min*1000) as VO2_mL_min
from work.import
where calculated VO2_mL_min >500; /*<2000*/
quit;

proc sql;
select VO2_L_min, (VO2_L_min*1000) as VO2_mL_min
from work.import
where calculated VO2_mL_min between 500 and 2000;
quit;

proc sql;
select VO2_L_min, (VO2_L_min*1000) as VO2_mL_min,
case
when calculated VO2_mL_min between . and 499.99 then 'Low'
when calculated VO2_mL_min between 500 and 1999.99 then 'Within Range'
when calculated VO2_mL_min between 2000 and 2999.99 then 'High'
else 'Very high'
end as VO2_L_min_label
from work.import;
quit;

/*Aggregating data - COUNT (PROC FREQ), AVG/MIN/MAX/SUM (PROC MEANS)*/
proc sql; 
select *, COUNT(Week) as Week_Group 
from work.import
group by Week;
quit;

proc sql; 
select *, AVG(VO2_L_min) as VO2_L_min_Avg 
from work.import
group by Week
order by calculated VO2_L_min_Avg desc;
quit;

/*Example - Importing and Joining sheets 'GXT'; 'VO2 Data'*/
dm 'log;clear;output;clear;odsresults;clear';

proc import datafile='C:\MyFolder\MyDatafile.xlsx'
out=GXT dbms=xlsx replace;
sheet="GXT";
getnames=yes;
run;

proc import datafile='C:\MyFolder\MyDatafile.xlsx'
out=O2Consumption dbms=xlsx replace;
sheet="O2Consumption";
getnames=yes;
run;

data work_all;/*Importing observations from sheets below each other*/
set GXT O2Consumption;
run;

proc sql;/*Merging observations by ID*/
create table work_table as
select coalesce (x.ID,y.ID) as ID,Ax,Var4,Var5,RPE,RQ,PeakHR,Week,MaximumVsAverage,Task1VsTask2,VO2_L_min,Var6,HR_min,VO2_HR_mL,RER
from GXT as x full join O2Consumption as y
on x.id = y.id;
quit;

data work_table; set work_table;/*Adding a variable*/
if ID='ABC001' then group='1';
if ID='ABC002' then group='1';
if ID='ABC003' then group='1';
if ID='ABC004' then group='1';
if ID='ABC005' then group='1';
if ID='ABC006' then group='1';
if ID='ABC007' then group='2';
if ID='ABC007' then group='2';
if ID='ABC008' then group='2';
if ID='ABC009' then group='2';
if ID='ABC010' then group='2';
run;

/*See Contents*/
proc contents data=work_table;
run;

proc print data=work_table;
run;
