# Group Enroll
Project for Constraint Programming Course at AGH University.

This project concerns assigning students to groups given various constraints and preferences.
It has been directly inspired by the system working at the AGH University (Faculty of Computer Science, Electronics and Telecommunications).

## Problem Details

Imagine working in the faculty administration at the AGH UST in Krakow. Every year the same story: first you have to prepare the schedule for the whole year, later you have to assign students to the available groups. Recently your faculty started to notice the obnoxious difficulty of those tasks and tried to introduce some automation. Unfortunately it doesn't work as well as you hoped. Therefore you are going to the matter into your own hands. To be realistic, you will focus on the group assignment as it's less disruptive than the whole schedule. After spending some time under the shower and having several eureka moments, you came with the following definition of the problem.

So, first, the input has to contain the current schedule of all the involved groups[^group] over the set of days[^day]. Only then we will focus on the students[^student] and their preferences. Finally we will combine them to obtain an objective function and print the output.

### Schedule

Each group belongs to a class[^class][^group_class] (e.g. `Constraint Programming: Lab`) with a specified duration[^class_duration] in a well defined time unit[^time]. We also have to know which day[^group_day] and at what hour[^group_start] the groups start their activities. This way we can guarantee that student doesn't attend two different groups at the same time. We shouldn't forget about the space restrictions, each class has an upper limit for the number of students in the single group[^class_size].

Other important factor is that we have to know in what building the group occupies the classroom, so later we can calculate the time required to move between the groups. We have to guarantee that student is able to transport between the buildings in time. Finally the schedule can change during the semester, there can be alternative weeks, some courses may to end in the middle of the semester; it's almost impossible to handle all the irregularities. Therefore we will also define what groups do not conflict each other even if they are happening at the same time according to our simplified schedule. One would be worried that would requires lot of work, but luckily somebody has already preprocessed the data and calculated which groups conflict with each other[^groups_conflicts]!

### Preferences

Given the schedule, we can focus on the students[^student] and their preferences. Each student should belong to exactly one group[^group] per class[^class], but there are exceptions — more about them later...

First, some students live at the campus and they do not care, whether they have breaks between the classes. On the other hand, other would prefer to not sit at the university without any purpose. There is an array[^student_break_importance] telling how much important is lack of breaks for the student.

> Wasting time on long boring breaks is not ok :-1:.

secondly, students assign preferences[^preference][^student_prefers] to the available groups; higher the preference is, more they would like to attend the group. The preference = `-1` means that this group is excluded for the given student. If all the groups of a given class are excluded for the student, it means that they do not attend this class — the exception foretold in the first paragraph of this section.

> Being assigned to groups one does not prefer is not ok :-1:.

### Objective

Given the schedule and student preferences we have to define what assignments are better than others. Obviously, every student (with already mentioned exceptions) has to be assigned to a single group of each class. Also the assignment has to be feasible (no bilocation allowed), but what makes the assignment better than others?

1. Students should not waste their time on long boring breaks. For each student and each day we calculate the time they have to spend at the university ("end of the last group" - "start of the of the first group") and how much they spend on learning (sum all the classes' durations this day). Difference between these number is the time they have wasted. Due to the fact that during the semester classes may change, this value in theory could go below zero, but we should assume the `0` is the minimal value. The wasted time is summed for each student and normalized to full hours[^normalized]. We will call this value **break disappointment**.
2. Students should not attend groups they hate. For each student and each class we calculate difference between their favorite group and the one they have been assigned. We sum those values for each student and will call this value **preference disappointment**.

Finally, our objective is to :exclamation:**minimize sum o squared total disappointments**:exclamation:
