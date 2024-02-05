#include <stdlib.h> 
#include <stdio.h>
#include <string.h>

#define STUDENT_MAX_COUNT 100   

struct Student {
    int id;
    char name[50];
    char surname[50];
    int age;
    int grade;
};

struct Academy {
    struct Student* students;
    int size;
};

int load_from_file(struct Academy* academy);
void write_in_file(struct Academy* academy);

void allocate_students(struct Academy* academy);

void add_student(struct Academy* academy, struct Student* student);
void read_records(struct Academy* academy);
void update_record(struct Academy* academy, struct Student* student);
void delete_record(struct Academy* academy, int delete_id);

void student_record_management(struct Academy* academy);

int main() {
    struct Academy academy;
    allocate_students(&academy);

    student_record_management(&academy);
}

void student_record_management(struct Academy* academy) {
    int choice;
    struct Student new_student;
    int id = 0;

    int records_loaded = load_from_file(academy);

    if (records_loaded == -1) {
        return;
    } else {
        id = records_loaded;
    }

    do {
        printf("1. Add a new student record\n");
        printf("2. Display all records\n");
        printf("3. Update a record\n");
        printf("4. Delete a record\n");
        printf("5. Exit\n");
        printf("Enter your choice: ");
        scanf("%d", &choice);

        switch (choice) {
            case 1:
                printf("Enter student information: \n");
                printf("Name: ");
                scanf("%s", new_student.name);
                printf("Surname: ");
                scanf("%s", new_student.surname);
                printf("Age: ");
                scanf("%d", &new_student.age);
                printf("Grade: ");
                scanf("%d", &new_student.grade);
                new_student.id = ++id;
                // add_student(academy, &new_student);
                break;
            case 2:
                // read_records(academy);
                break;
            case 3:
                printf("Enter the ID of the record to update: ");
                int target_id;
                scanf("%d", &target_id);
                printf("Enter new student information: \n");
                printf("Name: ");
                scanf("%s", new_student.name);
                printf("Surname: ");
                scanf("%s", new_student.surname);
                printf("Age: ");
                scanf("%d", &new_student.age);
                printf("Grade: ");
                scanf("%d", &new_student.grade);
                new_student.id = target_id;
                // update_record(academy, &new_student);
                break;
            case 4:
                if(academy->size <= 0) {
                    printf("We cannot remove it because there is no student");
                } else {
                    printf("Enter the ID of the record to delete: ");
                    int delete_id;
                    
                    do {
                        printf("Enter the ID of the record to delete (0 to %d): ", academy->size - 1);
                        scanf("%d", &delete_id);

                        if (delete_id < 0 || delete_id >= academy->size) {
                            printf("Invalid ID. Please enter a value between 0 and %d.\n", academy->size - 1);
                        }
                    } while (delete_id < 0 || delete_id >= academy->size);
                    
                    delete_record(academy, delete_id);
                }
                
                break;
            case 5:
                break;
            default:
                printf("Invalid choice. Please try again.\n");
        }

    } while (choice != 5);
    write_in_file(academy);
}

void allocate_students(struct Academy* academy) {
    int num_students = STUDENT_MAX_COUNT;

    academy->students = (struct Student*)malloc(num_students * sizeof(struct Student));

    if (academy->students == NULL) {
        perror("Error allocating memory for students");
    }

    academy->size = 0;
}

void add_student(struct Academy* academy, struct Student* student) {
    if(academy->size == STUDENT_MAX_COUNT) {
        printf("We cannot add a student due to lack of spaceշն");
        return;
    }

    academy->students[academy->size].id = student->id;
    strcpy(academy->students[academy->size].name, student->name);
    strcpy(academy->students[academy->size].surname, student->surname);
    academy->students[academy->size].age = student->age;
    academy->students[academy->size].grade = student->grade;

    ++academy->size;
}

int load_from_file(struct Academy* academy) {
    FILE* file = fopen("student_data.txt", "r");

    if (file == NULL) {
        perror("Error opening file");
        return -1;
    }

    // Read the header line (assuming it contains column names)
    char header[256];
    fgets(header, sizeof(header), file);

    int line_cont = 0;

    while (!feof(file)) {
        struct Student student;
        int read_count = fscanf(file, "%d %s %s %d %d",
                                &student.id,
                                student.name,
                                student.surname,
                                &student.age,
                                &student.grade);

        if (read_count == 5) {
            add_student(academy, &student);
        } else if (read_count != EOF) {
            printf("Error reading data from file. Skipping invalid record.\n");
        }
        line_cont = student.id;
    }

    fclose(file);

    return line_cont ;
}

// void write_in_file(struct Academy* academy) {
//     FILE* file = fopen("student_data.txt", "w");

//     if (file == NULL) {
//         perror("Error opening file");
//         return;
//     }

//     int num_students = academy->size;  // Use the actual size of the academy

//     fprintf(file, "%-5s %-15s %-15s %-5s %-5s\n", "ID", "Name", "Surname", "Age", "Grade");
//     for (int i = 0; i < num_students; ++i) {
//         fprintf(file, "%-5d %-15s %-15s %-5d %-5d\n",
//                 academy->students[i].id,
//                 academy->students[i].name,
//                 academy->students[i].surname,
//                 academy->students[i].age,
//                 academy->students[i].grade);
//     }

//     fclose(file);
// }

// void read_records(struct Academy* academy) {
//     printf("%-5s %-15s %-15s %-5s %-5s\n", "ID", "Name", "Surname", "Age", "Grade");
    
//     for(int i = 0; i < academy->size; ++i) {
//         printf("%-5d %-15s %-15s %-5d %-5d\n", 
//                academy->students[i].id, 
//                academy->students[i].name, 
//                academy->students[i].surname,
//                academy->students[i].age, 
//                academy->students[i].grade);
//     }
// }

// void update_record(struct Academy* academy, struct Student* student) {
//     int flag = 0;
//     for(int i = 0; i < academy->size; ++i) {
//         if(academy->students[i].id == student->id) {
//             flag = 1;
//             strcpy(academy->students[i].name, student->name);
//             strcpy(academy->students[i].surname, student->surname);
//             academy->students[i].age = student->age;
//             academy->students[i].grade = student->grade;
//             break;
//         }
//     }

//     if(!flag) {
//         // id-ov mard chka
//     }
// }

// void delete_record(struct Academy* academy, int delete_id) {
//     if (delete_id < 0 || delete_id >= academy->size) {
//         printf("Invalid ID. No record deleted.\n");
//         return;
//     }
    
//     int id = 0;
//     for(int i = 0; i < academy->size; ++i) {
//         if(academy->students[i].id == delete_id) {
//             id = i;
//             break;
//         }
//     }

//     for (int i = id; i < academy->size - 1; ++i) {
//         academy->students[i].id = academy->students[i + 1].id;
//         strcpy(academy->students[i].name, academy->students[i + 1].name);
//         strcpy(academy->students[i].surname, academy->students[i + 1].surname);
//         academy->students[i].age = academy->students[i + 1].age;
//         academy->students[i].grade = academy->students[i + 1].grade;
//     }

//     // Decrement size after shifting records
//     academy->size--;
// }