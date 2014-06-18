Abstract
=========
POBICOS [FP7 research project] was a distributed computing platform for wireless
sensor networks that was prototyped on Imote2 nodes and relied on ZigBee short-range modem
for communication. The objective of the thesis was to port the POBICOS middleware on Android
smartphones by re-engineering its lower-level system services. In addition, the network layer of the
middleware was also changed so as to perform message exchanges via an Internet-based server that
maintained a list of registered smartphones and acted as a router/forwarder between them.



This repository hosts the implementation of the system that was developed 
for my thesis (March - September 2011 @Uth.gr), titled "Porting the POBICOS 
middleware to Android mobile phones". 

Contents
=========
* <code>applications/</code> Android demo applications.
* <code>directory/</code> POBICOS Registry & Forwarder service.
* <code>middleware/</code> The extra files for the Android platform (NesC code). Based on
				  SVN Revision 3142 of the POBICOS repository. 
* <code>PoClient/</code> Android application.



