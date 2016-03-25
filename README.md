#Distributed HashCracker
This projcets aims a proof-of-concept of using a distributed system to crack an user-entered password. The Distributed HashCracker is developed with Swift 2.1 on Xcode 7.2 and uses an asynchronous message-oriented communication with a Node-Server and Grand Central Dispatch (GCD).  
To realise the pasword cracking, the Hash of the user-given password is being computed. The Hash is the reference value to find the given password. The distributed system will compute all possible password combinations (Brute Force-Attack) and the belonging hashes. If a computed hash will match the target hash, the target password is identified. 

##Function
To use the Distributed HashCracker, you need at least a cluster of two or more Mac computers which are located in one network. After starting the application, the user can identify a MasterComputer with help of the user interface. The MasterComputer will provide the communication and working delegation in the distributed system. In detail, it provides an Node-Server to realise the message-oriented communication. Also the MasterComputer produces the WorkerQueue. The WorkerQueue contains WorkingBlocks with possible password patterns, for example a[xxx]-A[xxx]. 

The other computers in the distributed system are the WorkerComputers. After setting the name of the MasterComputer, the WorkerComputers pulling their work from the WorkerQueue. The WorkerComputers compute all passwords and hashes from their actual WorkBlog. 

###Cracking strategy
For an efficient password cracking, a dictionary attack is carried out before execute the Brute Force-attack. The dictionary concatins about 50.000 of the most choosen passwords.  


##Usage
To use the Distributed HashCracker, the application just needs to be compiled with Xcode.  
After starting the application on the participating computers the GUI provides the following options:  

* Choosing, whether the computer is a Master or a Worker.
* Name of the MasterComputer.
* Target password in plain text.
* Hash algorithm, which should be used (MD5, SHA128 or SHA256).

If the computer is setting up as MasterComputer, the field *Server adress* shows the name of the computer. 

![Screenshot MasterComputer](https://github.com/pixelskull/AVS-Project/blob/master/Documentation/images/WindowMaster.png)  
Now the password must be entered. The default choosen Hash algorithm is *MD5*.
After starting the communication manager, the nessecary communication services are provided.

On the WorkerComputers, the name of the Communication must be entered in the user interface. After that, the computing can be started. 

![Screenshot WorkerComputer](https://github.com/pixelskull/AVS-Project/blob/master/Documentation/images/WindowWorker.png)

