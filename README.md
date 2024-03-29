## Before you come
### 1. Have you filled in the [pre-class survey](https://docs.google.com/forms/d/e/1FAIpQLSe7RZQYl7pppgfshM4Hf9he2mEwyWfIu5Zc5jr7_lU74ioZjg/viewform)

### 2. Request an ISAAC account 

2.1. go to [https://oit.utk.edu/hpsc/](https://oit.utk.edu/hpsc/)

2.2. click on `Request an ISAAC Account` from the menu on the left and follow the link from there.

## In-class Tutorial

### 1. Logging into ISSAC-NG

#### 1.1. Open OnDemand
Go to [login.isaac.utk.edu](https://login.isaac.utk.edu) 

Log in with your credentials.
On the top bar click on the "Clusters" dropdown and click on >_ISAAC Shell Access

#### 1.2. SSH through a terminal
Open a terminal and execute the following command
```
ssh <your-NetID>@login.isaac.tennessee.edu 
```

### 2. Navigating the shell environment
#### 2.1. Useful commands
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

#### 2.2. Excercise
Navigate to your scratch space located in 
```
/lustre/isaac/scratch/<your_username>
```
and create a new directory where you'll store what we do here today. 
Try renaming it, deleting it and recreating it.
Remember that anything you delete here is gone forever!

#### 2.3. Checking the available tools
| Command | Description |
| --- | --- |
| `module avail` | check what tools are available |
| `module load <tool>` | load the tool you need |
| `module unload <tool>` | unload a tool you no longer need |


### 3. Conda Environments in ISAAC

Conda environments are useful for managing specific packages used for different projects within a server. This allows users to specify different packages and versions needed for specific projects without interfering with other projects or users. Conda is also designed to handle package installation in a streamlined manner and avoid issues with manual installation. 


#### 3.1. Loading Anaconda

First we need to load the anaconda3 module using what we just learned before. If we used `module avail` we would see several versions of Anaconda available on ISAAC, but for now the default will be fine:
```
module load anaconda3
```

#### 3.2. Creating a Conda Environment

For this tutorial, we will create an environment called gst-env:
```
conda create -n gst-env
```

#### 3.3. Activating Your Environment
```
conda activate gst-env
```
If it's your first time using Open OnDemand, you may get an error message about this shell not being configured to use `conda activate`. To fix this, run the following command:
```
conda init bash
```
Then after closing and restarting the shell we should be able to activate our environment.


#### 3.4. Listing All Environments

You can also get a list of all available environments:
```
conda info --envs
```
The currently active environment is indicated with an asterisk `*`

#### 3.5. Installing Packages in the Active Environment

The general syntax for installing a package:
```
conda install package-name
```
Sometimes you need a specific version of a package:
```
conda install package-name=version
```
Some packages aren’t included in the default conda channels (or you might want to install a nonstandard version), in which case the channel must be specified. You can look up packages on [anaconda.org](https://anaconda.org/) to find their channel. 
```
conda install channel::package-name
```
As an example we will install mamba. Mamba is an optional package that helps conda with package installation with features such as faster dependency solving, multi-thread downloading, and a more visually descriptive installation. This can be especially useful if you have a lot of packages installed in your environment, as each new package increases the complexity of dependency solving. If you expect to have a complex environment, you may want to install mamba as your first package in the new environment, then use it to install other packages. To install mamba:
```
conda install conda-forge::mamba
```
This will also automatically install any dependencies needed for mamba to work. Once mamba is installed, we can use it to install any further packages. Anywhere you see `conda install`, replace with `mamba install`. All other syntax is the same.


#### 3.6. View Packages Installed in the Active Environment
```
conda list
```

#### 3.7. Rolling Back an Environment

Sometimes you may run into issues after installing conflicting packages in a conda environment. This can be solved by rolling back your environment to a previous version. To see versions of your environment:
```
conda list --revisions
```
Then you can select a version to roll back to:
```
conda install --revision N
```
where N is the revision number. This will remove any packages installed after that revision. 

As a test, let's roll our environment back to revision 0:
```
conda install --revision 0
```
Now if we use `conda list`, we will see that no packages are installed because we rolled back to a fresh version of the environment.


#### 3.8. Deactivating an Environment

To return to the base environment, you can deactivate the current environment:
```
conda deactivate
```
This will not entirely delete the environment, but will deactivate it for the current session. This is also recommended before switching to a different environment, as running multiple environments at once can cause conflicts.

#### 3.9. Deleting an Environment

To entirely delete your conda environment:
```
conda env remove -n env_name
```
It is recommended that you deactivate an environment (if it is active) before you remove it. 

Let's remove our environment:
```
conda env remove -n gst-env
```
Now if we check our list of environments again:
```
conda info --envs
```
We will see our environment is gone.

### 4. Transferring Files to ISAAC

There are several methods to transfer files from your local computer or the internet onto ISAAC.

#### 4.1. Secure Copy Protocol (scp)

`scp` is used to take files from your local device and copy them to a server (or vice versa). The general syntax is:
```
scp [source] [destination]
```
Be sure to always denote folders/directories with a forward slash `/` even though your local file system will sometimes list them with a backslash `\`. A linux terminal will not correctly process backslashes.

So, if we want to transfer a local file called "file.txt" onto ISAAC:
```
scp C:/Users/<Local-Account>/Documents/file.txt <ISAAC-username>@dtn1.isaac.utk.edu:/lustre/isaac/scratch/<ISAAC_username>/file.txt
```
Dtn stands for "data transfer node" and OIT prefers you use this node to transfer files, rather than the login node. More information about this can be found [at this link](https://oit.utk.edu/hpsc/isaac-open-enclave-new-kpb/data-transfer-new-cluster-kpb-2/).

`scp` commands must be run from a linux terminal while *not* logged into the server. If you are already on ISAAC, the `scp` command will not be able to use the local path. You can run multiple Linux terminals at once to allow transferring local files from one terminal while being logged into ISAAC on another terminal.

Additionally, this will prompt you for your password, since `scp` needs to log into ISAAC to copy the file. 

You can reverse the synax if you want to copy a file from ISAAC onto your local device:
```
scp <ISAAC-username>@dtn1.isaac.utk.edu:/lustre/isaac/scratch/<ISAAC_username>/file.txt C:/Users/<Local-Account>/Documents/file.txt
```
Again, this will require a terminal session that is *not* logged into the server, and you will have to enter your password.

You can also copy an entire folder using the `-r` flag (recursive):
```
scp -r C:/Users/<Local-Account>/Documents/Folder <ISAAC-username>@dtn1.isaac.utk.edu:/lustre/isaac/scratch/<ISAAC_username>
```

#### 4.2. Local file transfer in Open OnDemand

If you are using ISAAC's OnDemand service, scp won't work because the virtual terminal is automatically logged into ISAAC and cannot access your local file system. Fortunately, there is an even easier way to upload local files to the server.
 
OnDemand has standard file management similar to a regular Windows or MacOS system. You can upload files using the "Upload" button in the top right, then drag or browse for files from your local computer.

Other programs such as MobaXTerm for Windows also have visual file managers that allow uploading and downloading local files without using scp. 


#### 4.3. Internet files (wget)

`wget` allows you to download files from any website. The standard syntax is:
```
wget <file_URL>
```
You can also specify a new name for the file using the `-O` flag:
```
wget -O <new_file_name> <file_URL>
```
By default, `wget` downloads the file to your current working directory. To specify a different directory, use the `-P` flag:
```
wget -P <folder_path> <file_URL>
```
Let's download some FASTQ files from GitHub which we will use later. We'll save them under a "data" folder:
```
wget -P ./data https://github.com/ruwaa-mohamed/UTK-ISAAC-Tutorial/blob/main/sample_5.fastq.gz
wget -P ./data https://github.com/ruwaa-mohamed/UTK-ISAAC-Tutorial/blob/main/sample_12.fastq.gz
wget -P ./data https://github.com/ruwaa-mohamed/UTK-ISAAC-Tutorial/blob/main/sample_27.fastq.gz
wget -P ./data https://github.com/ruwaa-mohamed/UTK-ISAAC-Tutorial/blob/main/sample_47.fastq.gz

```
Now if we navigate to the data directory and use `ls`, we can confirm that our files successfully downloaded


#### 4.4. Github repositories (git clone)

You can also clone an entire Github repository. This is similar to copying every file in that repository, but also has several advantages for certain cases: 
  * Has increased efficiency of file transfer using Github's compression protocols
  * Allows version control and tracking changes of the project 
  * Maintains file and directory trees in the exact order of the original repository
  * If you are working with others on a Github repository, you can easily update files and receive others' updates without manually redownloading files or worrying about conflicts.

The general syntax is:
```
git clone <repository_URL>
```
For example, if we want to clone the repository for this tutorial:
```
git clone https://github.com/ruwaa-mohamed/UTK-ISAAC-Tutorial.git
```
This will create a directory for the repository called "UTK-ISAAC-Tutorial" within our current working directory.

If you want to learn more about using GitHub, you can check out this tutorial on [GitHub Basics](https://docs.github.com/en/get-started/start-your-journey/hello-world).

### 5. File editing nano
Why we can't use microsoft word or other text editing tools
Lets start with creating a txt file named test.txt in your scratch 
note; there is two ways to creat a folder in your scratch  via absolute path or you `cd` their. 

` /lustre/isaac/scratch/<your_username> `

In your terminal type 
``` nano test.txt ```
This comand will invoke nano to open and creat a file called test.txt 

<p align="center">
<img width="548" alt="Screen Shot 2024-03-28 at 6 44 44 PM" src="https://github.com/ruwaa-mohamed/UTK-ISAAC-Tutorial/assets/47094619/15bd8b00-7fa9-4aa4-b31b-8ffdcde4c2ae">
</p>

We will go over the nano interphase and different features

After open nano and creat a file called test.txt  then type `I am learning new skills`. if you want to save  `^O` which is Control + O to write out. 
Now you can exit by `^E` Control + X. 

#### 5.1. Link for a useful Nano Keyboard Commands
https://staffwww.fullcoll.edu/sedwards/Nano/UsefulNanoKeyCommands.html

#### 5.2. Useful Vim tutorial for advance powerfull option 
https://www.openvim.com/

### 6. Slurm introduction
Slurm is an open-source, fault-tolerant, and highly scalable cluster management and job scheduling system for large and small Linux clusters. 
`slurmctld`, to monitor resources and work. Each compute server (node) `slurmd daemon` [fault-tolerant hierarchical communications]; can be compared to a remote shell: it waits for work, executes that work, returns status, and waits for more work `slurmdbd` (Slurm DataBase Daemon) which can be used to record accounting information for multiple Slurm-managed clusters in a single database.

<p align="center">
<img width="548" alt="Screen Shot 2024-03-26 at 12 51 01 PM" src="https://github.com/ruwaa-mohamed/UTK-ISAAC-Tutorial/assets/47094619/909f844f-f08e-4bd5-8fe3-3c8314007b09">
</p>

#### 6.1. Slurm commands
| Command | Description |
| --- | --- |
| `sbatch <Job File Name>` | Batch job submission |
| `salloc` | Interactive job submission |
| `srun` | Run a parallel job |
| `squeue -l` | Job list |
| `squeue -l -u <User Name>` | Job list by users |
| `scancel <Job ID>` | Job deletion |
| `scontrol update job <Job ID>` | Job update |
| `scontrol show job <Job ID>` | Job details |

#### 6.2. Altering batch job
**It will only alter until the job starts running**

`scontrol update JobID=jobid NumTasks=Total_tasks JobName=any_new_name TimeLimit=day-hh:mm:ss`
There are two type of jobs interactivea (batch or non-batch) and non-interactive (batch)
#### 6.3. Interactive job

##### 6.3.1. non-batch 
You will have keep the termail a live until the allocation of resources completed 


`salloc --nodes=1 --ntasks=1 --time=00:10:00 --partition=campus`

##### 6.3.2. batch

You will have to wait for the allocation of resources 

`srun -A <account> -N  <#nodes> -n <#cores> -t <time> -p <partition> -q <quality of service> 'script'`

`srun -A ACF-UTK0011 -N 1 -n 1 -t 00:00:30 -p campus -q campus 'hostname'`
```
srun: job 1383775 queued and waiting for resources
srun: job 1383775 has been allocated resources
clr0821
```
`srun -A ACF-UTK0032 -N 1 -n 1 -t 00:00:30 -p condo-ut-genomics -q genomics 'hostname'`

```
srun: job 1384918 queued and waiting for resources
srun: job 1384918 has been allocated resources
ilm0837
```

#### 6.4. Non-interactive job

##### 6.4.1. Batch

An example of the batch job file should look like.
```
#!/bin/bash
 #This file is a submission script to request the ISAAC resources from Slurm 
 #SBATCH -J jobname		                     # The name of the job
 #SBATCH -account (or -A) ACF-UTK0011     # The project account to be charged
 #SBATCH --time (or -t)=hh:mm:ss          # Wall time (days-hh:mm:ss)
 #SBATCH --nodes (or -N)=1                # Number of nodes
 #SBATCH --ntasks (or -n)= 48.            # Total number of cores requested
 #SBATCH --ntasks-per-node=48             # cpus per node 
 #SBATCH --partition(or -p)=campus        # If not specified then default is "campus"
 #SBATCH --qos=campus		                   # quality of Service (QOS)
 #SBATCH --chdir=directory                # Used to change the working directory. The default working directory is the one from where a job is submitted
 #SBATCH --error=jobname.e%J	             # The file where run time errors will be dumped
 #SBATCH --output=jobname.o%J	            # The file where the output of the terminal will be dumped
 #SBATCH --array (or -a)=<indexes>        # submits an array job with n identical tasks 
 #SBATCH --mail (or -M)                   # send a mail notification  

 # Now list your executable command/commands.
 # Example for code compiled with a software module:
 module load example/test

```
<p align="center">
<img width="891" alt="Screen Shot 2024-03-27 at 11 25 54 AM" src="https://github.com/ruwaa-mohamed/UTK-ISAAC-Tutorial/assets/47094619/e4d330ef-a0f6-41be-acb1-e2088017a4ea">
<img width="835" alt="Screen Shot 2024-03-28 at 12 20 09 PM" src="https://github.com/ruwaa-mohamed/UTK-ISAAC-Tutorial/assets/47094619/e0aeeabf-0036-4985-b9b5-99a6e05e3056">
</p>

##### 6.4.2. Debugging option 
you can go for an interactive job explained below or use the flag 
 
 	'#SBATCH -p=short'  
  The short partition has a max of 3 hours and a total available resources 48 cores.

#### 6.5. Scheduler and notes or partition availability
You can check for partition availability by typing `showpartitions`


<p align="center">
<img width="891" alt="Screen Shot 2024-03-28 at 5 16 15 PM"  src="https://github.com/ruwaa-mohamed/UTK-ISAAC-Tutorial/assets/47094619/84500509-944b-4f00-a881-607c426728c0">
</p>

You can specify a specific partition of interest (I selected 'campus') 
```
showpartitions | grep campus
```

### 6.6. Job priority:
Each Slurm job's priority is computed based on several factors such as:
The job's age (how long it's been queueing).
The job's QOS.
The user's Fairshare

To view the factors that comprise a job's scheduling priority use `Sprio`
This code will display the priority and other factros including users and accounts with a decending order
```
sprio -lS '-Y'
```
you can also list and specifiy a partition

```
sprio -l | grep campus

```
you can also 

```
sprio -lS '-Y' -u <username>
```

### 6.7. Sbatch job
In this tutorial, we will do some text manipulation. there are 4 FASTQ files available to use. Let's explore the files first.
1) let's list the files.
```bash
ls -hl
```
How big are the samples?

2) let's look at the content of the files 
```bash
less sample_12.fastq.gz
```
exit with `q`.
  
3) Now, let's convert this FASTQ to FASTA
```bash
nano fastq2fasta.sh
```
inside this new file, paste the following 
```bash
#!/bin/bash
#SBATCH -J fastq2fasta
#SBATCH -N=1
#SBATCH -n=1
#SBATCH -A ACF-UTK0011
#SBATCH -p campus
#SBATCH -q campus
#SBATCH -t 00:10:00
#SBATCH --output=log/slurm_%j_%a.out

zcat sample_12.fastq.gz | paste - - - - | cut -f 1,2 | sed  's/\t/\n/' > sample_12.fasta
```
press `ctrl+S` to save and `ctrl+X` to exit `nano`.
run the job using `sbatch` command
```bash
sbatch fastq2fasta.sh
```
4) To check the currently running jobs:
```bash
squeue -u [netid] ## without the square brackets
```

to make it an iterative process, use flag `-i` to define the intervals in seconds 
```bash
squeue -u [netid] -i 5
```
to exit press `CTRL+C`

5) To cancel a job
```bash
scancel [job_id]
```

let's create an infinte loop to test these commands.
open a new file with this command
```bash
nano infinite_loop.sh 
```
paste the following code in the new file 
```bash
#!/bin/bash
#SBATCH -J infinite
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH -A ACF-UTK0011
#SBATCH -p campus
#SBATCH -q campus
#SBATCH -t 00:10:00
#SBATCH --output=log/slurm_%j_%a.out

while true
do
    echo "This loop will run indefinitely"
done
```
click `CTRL+S` to save and `CTRL+X` to exit.

Submit the job to run using `sbatch` command.
```bash
sbatch infinite_loop.sh 
```

Now let's check the job is running.
```bash
squeue -u [netid] -i 5
```

to stop press `CTRL+C`

to cancel the job use `scancel` command. Note that the job_id will be different for everyone.
```bash
scancel [job_id]
squeue -u [netid]
```

6) Let's explore the new fasta file
```bash
less sample_12.fasta
```

### 6.8. Array batch job
7) You can run an array job to convert all samples from FASTQ to FASTA in parallel

open a new file
```bash
nano array_fastq2fasta.sh
```
paste the following code inside the new file 
```bash
#!/bin/bash
#SBATCH -J fastq2fasta_array
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH -A ACF-UTK0011
#SBATCH -p campus
#SBATCH -q campus
#SBATCH -t 00:10:00
#SBATCH --output=log/slurm_%j_%a.out
#SBATCH --array=5,12,27,27

zcat sample_${SLURM_ARRAY_TASK_ID}.fastq.gz | paste - - - - | cut -f 1,2 | sed  's/\t/\n/' > sample_${SLURM_ARRAY_TASK_ID}.fasta
```
press `ctrl+S` to save and `ctrl+X` to exit `nano`.

run the array job using `sbatch` command
```bash
sbatch array_fastq2fasta.sh
```

### 6.9 **2_Protein Dynamics Tutorial** 

1) create a conda environment 
```bash
conda create --name md
```
if asked to proceed, type `y` to accept.

2) activate the `md` conda environment
```bash 
conda activate md
```

3) install the required packages 
```bash
conda config --add channels conda-forge
conda config --set channel_priority strict

conda install gromacs
```
you will be asked `Proceed ([y]/n)?`. type `y` to proceed

4) go to your home directry
```bash
cd
pwd
```
this should print the path to the home directory

5) create a folder for the md_simulation
```bash
mkdir md_tutorial
cd md_tutorial
```

6) Download the protein 3D structure and all required files
```bash
wget https://files.rcsb.org/view/1AKI.pdb
wget http://www.mdtutorials.com/gmx/lysozyme/Files/ions.mdp
wget http://www.mdtutorials.com/gmx/lysozyme/Files/minim.mdp
wget http://www.mdtutorials.com/gmx/lysozyme/Files/nvt.mdp
wget http://www.mdtutorials.com/gmx/lysozyme/Files/npt.mdp
wget http://www.mdtutorials.com/gmx/lysozyme/Files/md.mdp
```
7) confirm all the files are there 
```bash
ls
```
the output should look like this 
```bash
1AKI.pdb  ions.mdp  md.mdp  minim.mdp  npt.mdp  nvt.mdp
```

8) removing water molecules from the protein structure 
```bash
grep -v HOH 1AKI.pdb > 1AKI_clean.pdb
```

9) follow the tutorial from **5.3.1** in the pdf document named `2_Tutorial.pdf`

10) use the command `time` before any command to calculate how much time does it take to run. 
```bash
time grep -v HOH 1AKI.pdb > 1AKI_clean.pdb
```
output will have this at the end showing the time consumed for this job.
```bash

real    0m0.024s
user    0m0.000s
sys     0m0.002s
```
11) run the whole analysis in a script. How much resources should we allocate? 


#### 6.10. Using GPU to run your analysis in NVIDIA:
https://docs.nvidia.com/clara/parabricks/4.3.0/index.html

https://developer.nvidia.com/blog/taking-gpu-based-ngs-data-analysis-to-another-level-with-clara-parabricks-pipelines-3-0/

#### 6.11. OIT started to provide a series workshops on Bioinformatics:

`https://oit.utk.edu/hpsc/spring-2024-bioinformatics-workshop-series/`
