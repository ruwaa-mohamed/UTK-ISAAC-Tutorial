## From the syllabus
Milestones: The tutorials should be of broad interest, deliver an overview over the topic at hand,
and build on students’ prior expertise.
- Define the topic: What skills will be attractive to other students?
- Learning goals: What should participants able to do at the end?
- Define specific tasks and techniques to be taught.
- What computer platform is needed for the tutorial? What software?
- What prior knowledge is needed, and do the participants have it?
- What scientific question can be answered in this tutorial?
- Identify suitable existing datasets to be used (case study).
- Prepare tutorial manual with materials for advance preparation, a script for the tutorial
itself, and troubleshooting tips.
- Practice the tutorial >2 weeks ahead of time.

## Before you come
### 1. Have you filled in the [pre-class survey](https://docs.google.com/forms/d/e/1FAIpQLSe7RZQYl7pppgfshM4Hf9he2mEwyWfIu5Zc5jr7_lU74ioZjg/viewform)

### 2. Request an ISAAC account 

2.1. go to [https://oit.utk.edu/hpsc/](https://oit.utk.edu/hpsc/)

2.2. click on `Request an ISAAC Account` from the menu on the left and follow the link from there.

## 3. In-class Tutorial

### 3.x Logging into ISSAC-NG

#### Open OnDemand
Go to [login.isaac.utk.edu](https://login.isaac.utk.edu) 

Log in with your credentials.
On the top bar click on the "Clusters" dropdown and click on >_ISAAC Shell Access

#### SSH through a terminal
Open a terminal and execute the following command
```
ssh <your-NetID>@login.isaac.tennessee.edu 
```

### 3.x Navigating the shell environment
#### Useful commands
| Command | Description |
| --- | --- |
| `pwd` | print current working directory |
| `ls` | list files in the current working directory |
| `ll` | list files in more detail |
| `cd` | change the working directory |
| `mkdir <name>` | make a new directory <name> |
| `cp <source> <target>` | create a copy of file <source> named <target> |
| `mv <source> <directory>` | move <source> (file or directory) into <directory> |
| `mv <source> <target>` | rename <source> (file or directory) to <target> |
| `rm -i <filename>` | remove (delete) file named <file> |

#### Excercise
Navigate to your scratch space located in 
```
/lustre/isaac/scratch/<your_username>
```
and create a new directory where you'll store what we do here today. 
Try renaming it, deleting it and recreating it.
Remember that anything you delete here is gone forever!

#### Checking the available tools
| Command | Description |
| --- | --- |
| `module avail` | check what tools are available |
| `module load <tool>` | load the tool you need |
| `module unload <tool>` | unload a tool you no longer need |

### 3.1 File editing nano vs Vim
#### Useful Nano Keyboard Commands
https://staffwww.fullcoll.edu/sedwards/Nano/UsefulNanoKeyCommands.html
#### Useful Vim tutorial
https://www.openvim.com/

### 3.2 Slurm introduction

   ##### 3.2.1 Debugging option 
	
  #### 3.2.2 Interactive job
  In this interactive job, we will do some text manipulation. there are 4 FASTQ files available to use. Let's explore the files first.
  ```bash
  ```
  Now, let's convert this FASTQ to FASTA
  #### 3.2.2 Batch job
