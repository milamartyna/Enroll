% Parameters
int: n_students;
int: n_days;
int: n_classes;
int: n_groups;
int: n_time_units_in_hour;
int: exclusion = -1;

set of int: Student = 1..n_students;
set of int: Class = 1..n_classes;
set of int: Group = 1..n_groups;
set of int: Day = 1..n_days;
set of int: Time = 0..n_time_units_in_hour * 24;
set of int: WorkTime = 0..max(Time)*n_days;
set of int: Preference = exclusion..max([student_prefers[s,g] | s in Student, g in Group]);

array[Student] of 0..5: student_break_importance;
array[Student, Group] of int: student_prefers;

array[Class] of Time: class_duration;
array[Class] of int: class_size;

array[Group] of Class: group_class;
array[Group] of Time: group_start;
array[Group] of Day: group_day;
array[Group, Group] of bool: groups_conflicts;

%Variables
array[Student,Group] of var bool: assigment;
array[Group] of var 0..max(class_size) : group_size;

array[Student] of var 0..(max([student_prefers[s,g] | s in Student, g in Group]) * n_classes): preference_dissapointment;

array[Student] of var 0..(n_days*max(WorkTime)): break_dissapointment;
array[Student] of var 0..((((n_days*max(WorkTime)*5+(n_days*max(WorkTime)*8*n_classes)))+1)): total_disappointment;
var int: total_break_disappointment;
var int: total_preference_disappointment;
var int: objective;


% Constrainty

% conflicts -> correct group assigment

constraint forall([assigment[s,g1] + assigment[s,g2] < 2 | s in Student, g1,g2 in Group where groups_conflicts[g1,g2]]);



constraint forall([assigment[i,g] = false |i in Student, g in Group where student_prefers[i,g] = -1]);

constraint forall([ if max([student_prefers[i, g] | g in Group where group_class[g] = c]) = -1 then 
   sum([assigment[i,g] | g in Group where group_class[g] = c])= 0 else sum([assigment[i,g] | g in Group where group_class[g] = c])= 1 endif | c in Class, i in Student]);
   

% correct group size

constraint forall([ group_size[g] =  sum([ assigment[i,g]  | i in Student]) | g in Group]);
constraint forall([ group_size[g] <= class_size[group_class[g]] | g in Group]);


% preference dissapoinment

constraint forall([ sum([ max([student_prefers[i, cg] | cg in Group where 
group_class[cg] = group_class[g]]) - student_prefers[i,g] | g in Group where assigment[i,g]]) = preference_dissapointment[i] | i in Student]);



constraint forall([ ceil_div(sum([ 

  max((max([ if group_day[g] = d then group_start[g] + class_duration[group_class[g]] else -1 endif| g in Group where assigment[i,g]])
   - min([if group_day[g] = d then group_start[g] else 1000 endif | g in Group where assigment[i,g]])) 

  - (sum([if group_day[g] = d then class_duration[group_class[g]] else 0 endif| g in Group where assigment[i,g]])), 0)
| d in Day]), n_time_units_in_hour) = break_dissapointment[i] | i in Student]);

% break and preference total dissapointment
constraint total_break_disappointment = sum([break_dissapointment[i] | i in Student]);
constraint total_preference_disappointment = sum([preference_dissapointment[i] | i in Student]);

% total dissapoitment for each student
constraint forall([total_disappointment[i] = ceil_div(student_break_importance[i] * break_dissapointment[i] + (10 - student_break_importance[i]) * preference_dissapointment[i], 10) | i in Student]);

constraint objective = sum([ total_disappointment[i] ^ 2 | i in Student]);

solve :: bool_search(assigment,first_fail,indomain_min) minimize objective;

% helper function
function var int: ceil_div(var int: x, var int: y) =
  x div y + ((x mod y) > 0);
  
output [ "assignment = [" ++ join(",", ["{" ++ join(",", [show(g) |  g in Group where fix(assigment[s,g])]) ++ "}" | s in Student]) ++ "];\n"]  ++
["total_break_disappointment = ", show(total_break_disappointment), ";\n", ] ++
["total_preference_disappointment = ", show(total_preference_disappointment), ";\n", ] ++
["objective = ", show(objective), ";\n", ]