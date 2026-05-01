This guide explains how to validate the infrastructure deployment and ensure that the `todoapp` is correctly communicating with the MySQL database.

## 1. Prerequisites
Ensure that the deployment was started using the `bootstrap.sh` script, which configures the Kind cluster and applies all manifests from the `.infrastructure/` directory.

## 2. Cluster and Namespace Validation
Verify that the cluster nodes are ready and namespaces are created:
*   Check nodes: `kubectl get nodes`
*   Check namespaces: `kubectl get ns` (should see `todoapp` and `mysql`)

## 3. Database Validation (StatefulSet)
Confirm the MySQL database is running and initialized:
*   **Pod Status**: Run `kubectl get pods -n mysql`. You should see 3 replicas of the MySQL pod.
*   **Initialization**: Check the logs of the first pod to ensure the `init.sql` script was executed:
    `kubectl logs mysql-0 -n mysql`
*   **Connectivity**: Verify the headless service is active:
    `kubectl get svc -n mysql`

## 4. Application Validation (Deployment)
Verify that the Django application is running with the injected settings:
*   **Pod Status**: Run `kubectl get pods -n todoapp`. Ensure the pods are `Running` and passed health checks.
*   **Environment Variables**: Verify the application has received the correct DB credentials:
    `kubectl exec -it <todoapp-pod-name> -n todoapp -- env | grep DB_`
*   **Settings Patch**: Confirm the `settings.py` was successfully overridden by the ConfigMap:
    `kubectl exec -it <todoapp-pod-name> -n todoapp -- cat /app/todolist/settings.py`

## 5. Connectivity and Access
*   **Probes**: Ensure Liveness and Readiness probes are successful:
    `kubectl describe pod <todoapp-pod-name> -n todoapp`
*   **External Access**: The application is exposed via NodePort `30007`. Since Kind is configured with `extraPortMappings`, you can access the app at:
    `http://localhost:30007/api/health`

## 6. Storage Validation
Verify that the Persistent Volumes are bound:
*   Check PV: `kubectl get pv`
*   Check PVC: `kubectl get pvc -n todoapp`
*   Verify that data persists by checking the host path `/tmp` on your local machine (mapped to `/data` in the cluster).
