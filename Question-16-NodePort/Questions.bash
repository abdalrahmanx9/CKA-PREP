Question: NodePort

A deployment named nodeport-deployment is running in the namespace relative.

Task:
Create a Service named nodeport-service in the relative namespace to expose the deployment nodeport-deployment, with the following requirements:
- The Service must be of type NodePort
- It must be reachable on node port 30080
- The container port of the deployment is named http, exposed on port 80 with protocol TCP
- All pods of the deployment must be included as endpoints

Verify that the deployment is reachable via curl http://<nodeIP>:30080

Video Link
https://youtu.be/t1FxX3PmYDQ?si=ryASL-G9X2FCVApQ
