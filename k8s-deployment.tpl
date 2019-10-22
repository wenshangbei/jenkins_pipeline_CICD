apiVersion: v1
kind: ReplicationController
metadata:
  name: {APP_NAME}
  labels:
    name: {APP_NAME}
spec:
  replicas: 2
  selector:
    name: {APP_NAME}
  template:
    metadata:
     labels:
       name: {APP_NAME}
    spec:
     containers:
     - name: {APP_NAME}
       image:  {IMAGE_URL}:{IMAGE_TAG}
       imagePullPolicy: IfNotPresent
       ports:
       - containerPort: 8080  
