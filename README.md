bio-sign-in-web
===============
# Before Installation 
- Download and install [Tomcat][tomcat] 7.x
- Download the external properties file ```bsi_props.zip```  [here]
- Download and compile this project with maven ```mvn clean package``` or download ```bio-sign-in.war```  [here]

# Installation
- Unzip the file ```bsi_props.zip``` to ```/etc/bsi/bsi_props```
- Create the file ```TOMCAT_HOME/bin/setenv.sh```:
```
export CATALINA_OPTS="$CATALINA_OPTS
-Dext_prop_wssign_path=/etc/bsi/bsi_props/ -XX:MaxPermSize=256m"
```
- Copy all .jar files from ```/etc/bsi/bsi_props/lib/``` to ```/TOMCAT_HOME/lib/```
- Copy the compiled project ```bio-sign-in.war``` to ```/TOMCAT_HOME/webapps/```
- Edit the following configuration files:
 -	```/etc/bsi/bsi_props/ieesmanagement.properties```: Configure the certificate path and password.
 -	```/etc/bsi/bsi_props/log4j.properties```: Log4J configuration file.
-	In order to apply all the changes, restart Tomcat:
 - \# ./shutdown.sh
 - \# ./startup.sh

After Tomcat has been restarted, the home BioSignIn page can be found here:
http://localhost:8080/bio-sign-in/signManagement/home


[tomcat]:http://tomcat.apache.org
[here]:http://biosignin.org/bsi/download
