apiVersion: v1
kind: Service
metadata:
  name: {APP_NAME}
  labels:
    name: {APP_NAME}
spec:
  type: NodePort
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
    name: http
    nodePort: {NODE_PORT}
  selector:
    name: {APP_NAME}