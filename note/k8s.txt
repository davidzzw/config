 nohup java -jar sentinel-dashboard.jar -Xdebug -Xrunjdwp:transport=dt_socket,address=8005,server=y,suspend=y  --server.port=8082 &
 nohup java -jar -Xdebug -Xrunjdwp:transport=dt_socket,address=8005,server=y,suspend=n web-0.0.1-SNAPSHOT.jar --server.port=18080 2>&1 > /dev/null &  
 
https://172.31.1.8:8443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=lzs 
eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLThnNWs5Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJiZGM2ZDlkNC1hZjNmLTExZTgtYWQyOS0wMDE2M2UxM2Q0NTEiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06YWRtaW4tdXNlciJ9.GvMKElIcQoOzCdSixnG2vI-G7yecSTV1WuXCWljH2BEYU4Bhr7eLwJDps2g8ktvcrPxzUSk6BAqYMuRLbT02gLsG35SzPiPj8WfnXiku56plxTaVRXXW1pi0e0ksfli6aiEsUCQiL9DPR3Re06jHFiSnyfrdqkKfTsXkfQoMWh8hR9qWOWrjZwP7dXdGA1mSWnWUjloIb8-qT1VkxAvFVAE6ttnseMsUWqU84m7oLxShCSWZULL3lFvzJCKapaXAEboe686F5ppq6Qf4W_Q10JJGTg79f4qeumkHYHe5PoeUF2A4Ppa7lZX3GJlGtMeBgUScfogqJYHwM4fbRPf-Xw
eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLWRqN3A3Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIxZGI1ZTk3NC1lMGNjLTExZTgtOWZiOS0wMDBjMjlkODM0OGUiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06YWRtaW4tdXNlciJ9.F7mZEaS8z3u4JmQecT1olaiDdi4AyLnIIN0jM8BzGyHxssmK_28Sz3nbrI27P37V5zi0L6_RC3LmoA2dc4a79akIr8k-6K8im9BwjhurlK2p70xZ__Wpr5-etcR_zg8a_kyVvDaQTc5ParCe-e-sNEc06YXtaYMa6uzP7qvcvfY2iyDgoEHfq0-x6sLDAVlmuJNquJLLW-S3ek_uqJLpLOg3Oc9pA-5vtohnkcD2LzbTMYllewDBc0R-ZeQ9DdsF3rWtddd3CggaV2jwzK2s85pxPebq2avF1cqEqf5NATPMmXOrdEeLehdaueCZBvfQdqgB9KciEVefmysgy_3_mg
https://172.16.9.3:8443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy

##csf
172.31.1.14  abm.csf.mychebao.com
172.31.1.14  activemq.csf.mychebao.com
172.31.1.14  api.csf.mychebao.com
172.31.1.14  apinew.csf.mychebao.com
172.31.1.14  aucs.csf.mychebao.com
172.31.1.14  boss.csf.mychebao.com
172.31.1.14  businessms.csf.mychebao.com
172.31.1.14  callcenter.csf.mychebao.com
172.31.1.14  cams.csf.mychebao.com
172.31.1.14  capture.csf.mychebao.com
172.31.1.14  cc.csf.mychebao.com
172.31.1.14  chezhibao.csf.mychebao.com
172.31.1.14  common.csf.mychebao.com
172.31.1.14  coms.csf.mychebao.com
172.31.1.14  corder.csf.mychebao.com
172.31.1.14  crm.csf.mychebao.com
172.31.1.14  crmrule.csf.mychebao.com
172.31.1.14  crms.csf.mychebao.com
172.31.1.14  crmtrack.csf.mychebao.com
172.31.1.14  csfcon.csf.mychebao.com
172.31.1.14  czbapi.csf.mychebao.com
172.31.1.14  czbopens.csf.mychebao.com
172.31.1.14  elasticsearch.csf.mychebao.com
172.31.1.14  fdep.csf.mychebao.com
172.31.1.14  fms.csf.mychebao.com
172.31.1.14  internalapi.csf.mychebao.com
172.31.1.14  luban.csf.mychebao.com
172.31.1.14  m.csf.mychebao.com
172.31.1.14  msg.csf.mychebao.com
172.31.1.14  nebula.csf.mychebao.com
172.31.1.14  nvwa.csf.mychebao.com
172.31.1.14  ocp.csf.mychebao.com
172.31.1.14  openapi.csf.mychebao.com
172.31.1.14  order.csf.mychebao.com
172.31.1.14  org.csf.mychebao.com
172.31.1.14  oss.csf.mychebao.com
172.31.1.14  polaris.csf.mychebao.com
172.31.1.14  realreport.csf.mychebao.com
172.31.1.14  rtcp.csf.mychebao.com
172.31.1.14  schedule.csf.mychebao.com
172.31.1.14  sso.csf.mychebao.com
172.31.1.14  statics.csf.mychebao.com
172.31.1.14  sunwu.csf.mychebao.com
172.31.1.14  udep.csf.mychebao.com
172.31.1.14  usercenter.csf.mychebao.com
172.31.1.14  ves.csf.mychebao.com
172.31.1.14  vis.csf.mychebao.com
172.31.1.14  jenkins.csf.mychebao.com
172.21.9.128 mysql-chezhibao-service

ParallelScavengeHeap [ PSYoungGen [ eden =  [0x000000076b500000,0x000000076bb66810,0x000000076f500000] ,
 from =  [0x000000076ff80000,0x000000076ff80000,0x0000000770a00000] , 
 to =  [0x000000076f500000,0x000000076f500000,0x000000076ff80000]  ] 
PSOldGen [  [0x00000006c1e00000,0x00000006c1e00000,0x00000006cc900000]  ]  ] hsdb> 