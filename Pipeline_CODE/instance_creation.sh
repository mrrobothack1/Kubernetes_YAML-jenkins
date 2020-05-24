gcloud compute --project "soju-mobile-lle" instances create "soju-rhel7-mobile-lle-natgw01-usc1b-september-00" --machine-type "n1-standard-2" --network "mobile-lle" --subnet "mobile-lle-non-sens-central-egress01" --zone="us-central1-b" --can-ip-forward --metadata "app-name=natgw,app-cmdb-id=undefined,program-id=11939A,owner-email=Mobile_DevOps@soju.com,environment-type=lle,environment-name=natgw-usc1,patch-window-hour=0,patch-window-week=0,patch-window-day=0,reboot-tier-group=0,reboot-order=0,patching-type=2,backup-retention-days=0,backup-type=0;,block-project-ssh-keys=true" --maintenance-policy "MIGRATE" --service-account mdop-admin@soju-mobile-lle.iam.gserviceaccount.com --tags "egress-instance","nat-gateway" --image-family "soju-rhel7-mobile-nat-gateway" --image-project "soju-mobile-lle" --boot-disk-size "40" --boot-disk-type "pd-standard" --boot-disk-device-name "soju-rhel7-mobile-lle-natgw01-usc1b-disk-september-00"

gcloud compute --project "soju-mobile-lle" instances create "soju-rhel7-mobile-lle-natgw01-usc1c-september-01" --machine-type "n1-standard-2" --network "mobile-lle" --subnet "mobile-lle-non-sens-central-egress01" --zone="us-central1-c" --can-ip-forward --metadata "app-name=natgw,app-cmdb-id=undefined,program-id=11939A,owner-email=Mobile_DevOps@soju.com,environment-type=lle,environment-name=natgw-usc1,patch-window-hour=0,patch-window-week=0,patch-window-day=0,reboot-tier-group=0,reboot-order=0,patching-type=2,backup-retention-days=0,backup-type=0;,block-project-ssh-keys=true" --maintenance-policy "MIGRATE" --service-account mdop-admin@soju-mobile-lle.iam.gserviceaccount.com --tags "egress-instance","nat-gateway" --image-family "soju-rhel7-mobile-nat-gateway" --image-project "soju-mobile-lle" --boot-disk-size "40" --boot-disk-type "pd-standard" --boot-disk-device-name "soju-rhel7-mobile-lle-natgw01-usc1c-disk-september-01"

gcloud compute --project "soju-mobile-lle" instances create "soju-rhel7-mobile-lle-natgw01-usc1a-september-02" --machine-type "n1-standard-2" --network "mobile-lle" --subnet "mobile-lle-non-sens-central-egress01" --zone="us-central1-a" --can-ip-forward --metadata "app-name=natgw,app-cmdb-id=undefined,program-id=11939A,owner-email=Mobile_DevOps@soju.com,environment-type=lle,environment-name=natgw-usc1,patch-window-hour=0,patch-window-week=0,patch-window-day=0,reboot-tier-group=0,reboot-order=0,patching-type=2,backup-retention-days=0,backup-type=0;,block-project-ssh-keys=true" --maintenance-policy "MIGRATE" --service-account mdop-admin@soju-mobile-lle.iam.gserviceaccount.com --tags "egress-instance","nat-gateway" --image-family "soju-rhel7-mobile-nat-gateway" --image-project "soju-mobile-lle" --boot-disk-size "40" --boot-disk-type "pd-standard" --boot-disk-device-name "soju-rhel7-mobile-lle-natgw01-usc1a-disk-september-02"