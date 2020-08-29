export ingress=$(kubectl --context $1 -n istio-system get svc $2 -o json | jq -r '.status.loadBalancer')
        while [[ " ${ingress} " == " {} " ]]
            do 
                sleep 5
                echo -e "Waiting for service $2 in cluster $1 to get an ILB IP..."
                export ingress=$(kubectl --context $1 -n istio-system get svc $2 -o json | jq -r '.status.loadBalancer')
            done
        export ingress_ip=$(kubectl --context $1 -n istio-system get svc $2 -o json | jq -r '.status.loadBalancer.ingress[].hostname')
        echo -e "$2 in cluster $1 has an ILB IP of ${ingress_ip}."

