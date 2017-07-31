Table of Contents
=================
* [Provisioning the nodes](#provisioning-nodes)
  * [Create the networking infrastructure and the jumpbox](#provision-master)
  * [Provision the compute nodes](#provision-the-compute-nodes)
# Provisioning Nodes
## Create the networking infrastructure and the jumpbox
The template __deploy-master.json__ will provision the networking infrastructure as well as a master VM exposing an SSH endpoint for remote connection.   

You have to provide these parameters to the template :
* _vmPrefix_ : a 8 characters prefix to be used to name your objects. The master VM will be named as **\[prefix\]master**
* _sharedStorage_ : to specify the shared storage to use. Allowed values are : none, beegfs, nfsonmaster.
* _scheduler_ : the job scheduler to be setup. Allowed values are : none, pbspro
* _monitoring_ : the monitoring tools to be setup. Allowed values are : none, ganglia
* _masterImage_ : the OS to be used. Should be CentOS_7.2
* _dataDiskSize_ :  the size of the data disks to attached. Allowed values are : none, P10 (128GB), P20 (512GB), P30 (1023GB)
* _nbDataDisks_ : Number of data disks to attach. Default is **2**, maximum is **16**.
* _VMSku_ : This is to specify the instance size of the master VM. For example Standard_DS3_v2
* _adminUsername_ : This is the name of the administrator account to create on the VM
* _adminPassword_ : Password to associate to the administrator account. It is highly encourage to use SSH authentication and passwordless instead.
* _sshKeyData_ : The public SSH key to associate with the administrator user. Format has to be on a single line 'ssh-rsa key'

[![Click to deploy template on Azure](http://azuredeploy.net/deploybutton.png "Click to deploy template on Azure")](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fbrisbane%2Fazure-hpc%2Fromsa%2FCompute-Grid-Infra%2Fmarine%2Fdeploy-master.json)  

### Check your deployment
Once the deployment succeed, use the output **masterFQDN** to retrieve the master name and SSH on it. The output **GangliaURI** contains the URI of the Ganglia monitoring page, which should display after few minutes graphs of the current load.

To check if PBSPro is installed, run the command **pbsnodes -a** this should return no available nodes, but the command should run successfully.

If **nfsonmaster** is choosen, an NFS mount point named **/data** will be created.

## Provision the compute nodes
Compute nodes are provisioned using VM Scalesets, each set can have up to 100 VMs. You will have to provide the number of VM per scalesets and how many sets you want to create. All scalesets will contains the same VM instances.

You have to provide these parameters to the template :
* _VMsku_ : Instance type to provision. Default is **Standard_H16r**
* _sharedStorage_ : default is **nfsonmaster**. Allowed values are (nfsonmaster, beegfs, none)
* _scheduler_ : default is **pbspro**. Allowed values are (pbspro, none)
* _monitoring_ : default is **ganglia**. Allowed values are (ganglia, none)
* _computeNodeImage_ : OS to use for compute nodes. Default and recommended value is **CentOS-HPC_7.3**
* _vmSSPrefix_ : 8 characters prefix to use to name the compute nodes. The naming pattern will be **prefixAABBBBBB** where _AA_ is two digit number of the scaleset and _BBBBBB_ is the 8 hexadecimal value inside the Scaleset
* _instanceCountPerVMSS_ : number of VMs instance inside a single scaleset. Default is 2 to avoid accidental launches of large clusters, maximum is 100
* _numberOfVMSS_ : number of VM scaleset to create. Default is 1, maximum is 100
* _RGvnetName_ : The name of the Resource Group used to deploy the Master VM and the VNET.
* _adminUsername_ : This is the name of the administrator account to create on the VM. It is recommended to use the same than for the Master VM.
* _adminPassword_ : Password to associate to the administrator account. It is highly encourage to use SSH authentication and passwordless instead.
* _sshKeyData_ : The public SSH key to associate with the administrator user. Format has to be on a single line 'ssh-rsa key'
* _masterName_ : The short name of the Master VM
* _postInstallCommand_ : a post installation command to launch after povisioning. This command needs to be encapsulated in quotes, for example **'bash /data/postinstall.sh'**.
* _imageId_ : Specify the resource ID of the image to be used in the format **/subscriptions/{SubscriptionId}/resourceGroups/{ResourceGroup}/providers/Microsoft.Compute/images/{ImageName}** this value is only used when the _computeNodeImage_ is set to **CustomLinux** or **CustomWindows**


[![Click to deploy template on Azure](http://azuredeploy.net/deploybutton.png "Click to deploy template on Azure")](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fbrisbane%2Fazure-hpc%2Fromsa%2FCompute-Grid-Infra%2Fmarine%2Fdeploy-nodes.json)  

### Check your deployment
After few minutes, once the provision succeed, you should see the new hosts added on the Ganglia monitoring page if setup.

If PBS Pro is used, SSH on the master and run the **pbsnodes -a** command to list all the registered nodes.

If **nfsonmaster** is choosen the NFS mount point **/data** is automatically mounted.

**Your cluster is now ready to host applications and run jobs**

# Running applications

## Validating MPI
Intel MPI and Infiniband are only available for A8/A9 and H16r instances. A default user named **hpcuser** has been created on the compute nodes and on the master node with passwordless access so it can be immediately used to run MPI across nodes.

To begin, you need first to ssh on the master and then switch to the **hpcuser** user. From there, ssh one one of the compute nodes, and configure MPI by following the instructions from [here](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-linux-classic-rdma-cluster#configure-intel-mpi)

To run the 2 node pingpong test, execute the following command

    mpirun -hosts <host1>,<host2> -ppn 1 -n 2 -env I_MPI_FABRICS=dapl -env I_MPI_DAPL_PROVIDER=ofa-v2-ib0 -env I_MPI_DYNAMIC_CONNECTION=0 IMB-MPI1 pingpong

You should expect an output as the one below

    #------------------------------------------------------------
    #    Intel (R) MPI Benchmarks 4.1 Update 1, MPI-1 part
    #------------------------------------------------------------
    # Date                  : Thu Jan 26 02:16:14 2017
    # Machine               : x86_64
    # System                : Linux
    # Release               : 3.10.0-229.20.1.el7.x86_64
    # Version               : #1 SMP Tue Nov 3 19:10:07 UTC 2015
    # MPI Version           : 3.0
    # MPI Thread Environment:

    # New default behavior from Version 3.2 on:

    # the number of iterations per message size is cut down
    # dynamically when a certain run time (per message size sample)
    # is expected to be exceeded. Time limit is defined by variable
    # "SECS_PER_SAMPLE" (=> IMB_settings.h)
    # or through the flag => -time



    # Calling sequence was:

    # IMB-MPI1 pingpong

    # Minimum message length in bytes:   0
    # Maximum message length in bytes:   4194304
    #
    # MPI_Datatype                   :   MPI_BYTE
    # MPI_Datatype for reductions    :   MPI_FLOAT
    # MPI_Op                         :   MPI_SUM
    #
    #

    # List of Benchmarks to run:

    # PingPong

    #---------------------------------------------------
    # Benchmarking PingPong
    # #processes = 2
    #---------------------------------------------------
           #bytes #repetitions      t[usec]   Mbytes/sec
                0         1000         3.37         0.00
                1         1000         3.40         0.28
                2         1000         3.69         0.52
                4         1000         3.39         1.13
                8         1000         3.41         2.24
               16         1000         3.38         4.51
               32         1000         2.78        10.99
               64         1000         2.79        21.90
              128         1000         3.12        39.09
              256         1000         3.34        73.13
              512         1000         3.79       128.87
             1024         1000         4.85       201.48
             2048         1000         5.74       340.21
             4096         1000         7.06       552.98
             8192         1000         8.51       917.87
            16384         1000        10.86      1438.11
            32768         1000        16.55      1888.21
            65536          640        28.15      2220.37
           131072          320        53.47      2337.75
           262144          160        84.07      2973.66
           524288           80       148.77      3360.92
          1048576           40       284.91      3509.84
          2097152           20       546.43      3660.15
          4194304           10      1077.75      3711.45


    # All processes entering MPI_Finalize

## Running a Pallas job with PBS Pro

ssh on the master node and switch to the **hpcuser** user. Then change directory to home

    sudo su hpcuser
    cd

create a shell script named **pingpong.sh** with the content listed below

    #!/bin/bash

    # set the number of nodes and processes per node
    #PBS -l nodes=2:ppn=1

    # set name of job
    #PBS -N mpi-pingpong
    source /opt/intel/impi/5.1.3.181/bin64/mpivars.sh

    mpirun -env I_MPI_FABRICS=dapl -env I_MPI_DAPL_PROVIDER=ofa-v2-ib0 -env I_MPI_DYNAMIC_CONNECTION=0 IMB-MPI1 pingpong

Then submit a job

    qsub pingpong.sh

The job output will be written in the current directory in files named **mpi-pingpong.e*** and **mpi-pingpong.o***

The **mpi-pingpong.o*** file should contains the MPI pingpong output as shown above when doing the manual test.


____

### Reporting bugs

Please report bugs by opening an issue in the [GitHub Issue Tracker](https://github.com/xpillons/azure-hpc/issues)

This project has adopted the [Microsoft Open Source Code of
Conduct](https://opensource.microsoft.com/codeofconduct/). For more information
see the [Code of Conduct
FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact
[opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional
questions or comments.
