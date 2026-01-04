#### Check the EKS Cluster connectivity
```aws eks describe-cluster \
  --name rapidconnect-eks-cluster \
  --region ap-south-1
```

**Update the kube config**
```aws eks update-kubeconfig \
  --name rapidconnect-eks-cluster \
  --region ap-south-1
```

**Check current context**
`kubectl config current-context`

**Check API server connectivity**
`kubectl cluster-info`
`kubectl get nodes`

**More Sanity checks**
```kubectl run test-pod \
  --image=nginx \
  --restart=Never
```
`kubectl get pods`

`kubectl run ecr-test \
  --image=857565654393.dkr.ecr.ap-south-1.amazonaws.com/flaskapp:latest \
  --restart=Never`

**check outbound traffic**
`kubectl exec -it test-pod -- curl -I https://google.com`
`kubectl delete pod test-pod ecr-test`

**Quick troubleshooting mapping**
| Failure                      | Likely issue         |
| ---------------------------- | -------------------- |
| `kubectl cluster-info` fails | IAM auth / endpoint  |
| Nodes not Ready              | aws-auth / bootstrap |
| Pods Pending                 | Node capacity        |
| ImagePullBackOff             | ECR policy / NAT     |
| No internet from pod         | NAT / route tables   |

