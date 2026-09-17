Question: Sidecar

Task
Update the existing wordpress deployment by adding a sidecar container named sidecar that uses the busybox:stable image
The new sidecar container has to run the following command
"/bin/sh -c tail -f /var/log/wordpress.log"
Use a volume mounted at /var/log to make the log file wordpress.log available to the co-located container

Video link
https://youtu.be/2diUcaV5TXw?si=ftqiW_E-4kswuis1
