Part 1
Task 1.1
Relation A: Employee

A superkey is a combination of attributes that can uniquely identify each row in a table.

1) Examples superkeys:
    {EmpID}, {SSN}, {Email}, {phone}, {EmpID,phone}, {EmpID,SSN}, {Email,phone}

A candidate key is a minimal superkey from which an attribute cannot be deleted without losing its uniqueness.
2) Examples candidate keys:
    {EmpID}, {SSN}, {Email}, {phone}
3) I would like {EmpID} like a primary key, because it is stable and can't edit in contrast to Phone or Email, which can be edit.
4) No, 2 employees can't have 2 same number. We can see it in the table. 

Relation B: Course Registration
1) {StudentID}, {CourseCode}, {Section}, {Semester}, {Year}
2) {StudentID} - because each regestration of student need to identify unique
    {CourseCode} - necessary, for differences courses, on which student registered.
    {Section} - One Course has some section. It necessary for us for know, which section choosen a student
    {Semester} - Important, because student can take the course in different Semesters.
    {Year} - Important too, because student can take the course in different years.
 
3) Additional candidate keys - combination of attributes, which can unique identify an entry in the table, but is not minimal 
    {StudentID, CourseCode, Semester}

Task 1.2
Given Tables:
Student(StudentID, Name, Email, Major, AdvisorID)
Professor(ProfID, Name, Department, Salary)
Course(CourseID, Title, Credits, DepartmentCode)
Department(DeptCode, DeptName, Budget, ChairID)
Enrollment(StudentID, CourseID, Semester, Grade)

Foreign Keys: (StudentID, CourseID, AdvisorID, ChairID, DepartmentCode)

Part 2.
Task 2.1 is file "Task 2.1.png"
Task 2.2 is file "Task 2.2.png"

Part 4
Task 4.1.

Given Table:
StudentProject(StudentID, StudentName, StudentMajor,
                ProjectID, ProjectTitle, ProjectType,
                SupervisorID, SupervisorName, SupervisorDept, Role,
                HoursWorked, StartDate, EndDate)

1) Main Functional Dependencies:

    StudentID -> StudentName, StudentMajor;
    ProjectID -> ProjectTitle, ProjectType, SupervisorID;
    SupervisorID -> SupervisorName, SupervisorDept;
    StudentID, ProjectID -> Role, HoursWorked, StartDate, EndDate;
2)Redundancy:
    The student data is repeated for each project.
    The supervisor data is repeated for each project.
    The project data is repeated for each student.
    Anomalies:
    Update Anomaly:
    If student changes their major, you need to update all student's records.
    If the manager changes departments, you need to update all related projects.

    Insertion Anomaly:
    You can't add a new supervisor without a project.
    You can't add a new student without a project.

    Deletion Anomaly:
    If you delete a student's latest project, the student's information will be lost.
    If you delete the supervisor's last project, the supervisor's information will be lost.

3) Apply 1NF:
    In this table no 1NF violations because:

    - All attributes are atomic (not composite);
    - There are no duplicate groups;
    - There is a specific primary key;

4) Apply 2NF:
    Primary key: (StudentID, ProjectID) - composite key
    StudentID and StudentMajor depend from StudentID;
    ProjectTitle, ProjectType, SupervisorID depend from ProjectID;

    Decomposition - This is the process of splitting a table into multiple tables or 
    a relationship into multiple relationships to process a specific set of data.

    Decomposition in 2NF:
    1. Student(StudentID, StudentName, StudentMajor); 
    2. Project(ProjectID, ProjectTitle, ProjectType, SupervisorID);     
    3. Supervisor(SupervisorID, SupervisorName, SupervisorDept);
    4. StudentProjct(StudentID,ProjectID, Role, HoursWorked, StartDate, EndDate)

5) Transitive Dependencies:

In the Projects table: ProjectID -> SupervisorID -> SupervisorName, SupervisorDept

This is a violation of 3NF, since SupervisorName and 
SupervisorDept depend on SupervisorID, and not directly on the primary key.

    Final Decomposition to 3NF:
    Students(StudentID, StudentName, StudentMajor)
    PK: StudentID

    Supervisors(SupervisorID, SupervisorName, SupervisorDept)
    PK: SupervisorID

    Projects(ProjectID, ProjectTitle, ProjectType, SupervisorID)
    PK: ProjectID
    FK: SupervisorID -> Supervisors.SupervisorID

    StudentProjects(StudentID, ProjectID, Role, HoursWorked, StartDate, EndDate)
    PK: (StudentID, ProjectID)
    FK: StudentID -> Students.StudentID
    FK: ProjectID -> Projects.ProjectID

Task 4.2: Advanced Normalization
Given Table:
                CourseSchedule(StudentID, StudentMajor, CourseID, CourseName,
                InstructorID, InstructorName, TimeSlot, Room, Building)

1) Primary key: (StudentID, CourseID,TimeSlot,Room)

2) Functional Dependencies:
    1.StudentID -> StudentMajor;
    2.CourseID -> CourseName;
    3.InstructorID -> InstructorName
    4.Room -> Building;
    5.(CourseID, TimeSlot, Room) -> InstructorID;
    6. (StudentID, CourseID, TimeSlot, Room) -> all other attributes;

3) Check if the table is in BCNF:
We check our FDs:

    1.(StudentID) -> (StudentMajor) - (StudentID) isn't a superkey; (BCNF violation)
    2.(CourseID) -> courseName) - (CourseID) isn't a superkey; (BCNF violation)
    3.(InstructorID) -> (InstructorName) - InstructorID isn't a superkey; (BCNF violation)
    4.(Room) -> (Building) - (Room) isn't a superkey; (BCNF violation)
    5.(CourseID, TimeSlot, Room) -> InstructorID - (CourseID, TimeSlot, Room) is a superkey (corresponds to BCNF)
    6.Full PK dependence - (corresponds to BCNF)

    The table is NOT in BCNF by cause of a lot violations.

4) Decomposition to BCNF:

    Table 1: Students:
    Students(StudentID, StudentMajor)
    PK: StudentID
    FD: StudentID -> StudentMajor
    
    Table 2: Courses:
    Courses(CourseID, CourseName)  
    PK: CourseID
    FD: CourseID -> CourseName

    Table 3: Instructors:
    Instructors(InstructorID, InstructorName)
    PK: InstructorID
    FD: InstructorID -> InstructorName

    Table 4: Rooms:
    Rooms(Room, Building)
    PK: Room
    FD: Room -> Building

    Table 5: CourseSection:
    CourseSections(CourseID, TimeSlot, Room, InstructorID)
    PK: (CourseID, TimeSlot, Room)
    FD: (CourseID, TimeSlot, Room) -> InstructorID
    FK: CourseID -> Courses.CourseID
    FK: InstructorID -> Instructors.InstructorID  
    FK: Room -> Rooms.Room

    Table 6: StudentEnrollments
    StudentEnrollments(StudentID, CourseID, TimeSlot, Room)
    PK: (StudentID, CourseID, TimeSlot, Room)
    FK: StudentID → Students.StudentID
    FK: (CourseID, TimeSlot, Room) → CourseSections.(CourseID, TimeSlot, Room)

5) Potential loss of information:

    There is NO loss of information in this decomposition because:
    -All dependencies are saved: All functional dependencies are saved in the corresponding tables
    -All data is saved;
    -No redundant connections


Part 5
Task 5.1 

    1) File "Task 5.1"

    2)Convert your ER diagram to a normalized relational schema
    Student(StudentID,Name,Specialization,Course,Phone,Hobby)
    StudentClubs(StudentID,ClubID,AdvisorID,Title,Room,Quantity,Direction,TimeOfMeeting)
    Tracking(ClubID,StudentID,TimeOfMeeting,Attendance)
    RoleInClub(StudentID,Role,Obligation)
    FacultyAdvisors(AdvisorID,AdvisorName,ClubID)
    RoomReservations(ClubID,Room,TimeOfMeeting)
    BudExpenseTracing(ClubID,Cost list,Remains,Spent,Purpose,Budget)

    Connection:
    AdvisorID refers to FacultyAdvisors.AdvisorID;
    TimeOfMeeting refers to RoomReservations.TimeOfMeeting;
    Room refers to RoomReservations.Room;
    and etc.

    3) 
    
    1. Choice: How to keep a job history?

    OPTION 1: Current positions only:
    - Ease of implementation;
    - Loss of historical data;

    OPTION 2: Full history with dates:
    - Saving history for students' portfolios;
    - More complex queries;

    THE SELECTED OPTION: 2;
    It is important for the university to track the history of student leadership.

    2. Choice: How to track event attendance?

    OPTION 1: Simple binary model: Have visited a student on event or no.
    - Ease of implementation;
    - Minimal storage of data;
    - Easy queries for tracking;

    - No information about the time of arrival/departure;
    - Lateness cannot be tracked

    OPTION 2: Extended model with timestamps:

    - Full information about visiting;
    - Possibility to track a duration of visiting;
    - Accounting for lateness and early departures
    - Field for comments and reasons for absence;

    - A more complex data structure;
    - Requires more storage space

    THE SELECTED OPTION: 2;
    For university is very important to track a full visiting event of student


    4) 3 example queries:

    "Find all students who are members of the club "It Shark" and visit an event in Monday";
    "Find all Advisors who work in mathematic clubs";
    "Find all students whose hobby is game on guitar".


