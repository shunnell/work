from __future__ import annotations

from copy import deepcopy

from bespin_tools.lib.aws.eks import EksCluster
from bespin_tools.lib.aws.eks.token import get_token_for_cluster

KUBECONFIG_DEFAULT = {
    "apiVersion": "v1",
    "clusters": [
        {
            "cluster": {
                "certificate-authority-data": object(),
                "server": object(),
            },
            "name": object(),
        }
    ],
    "contexts": [
        {
            "context": {
                "cluster": object(),
                "user": object(),
            },
            "name": object(),
        }
    ],
    "current-context": object(),
    "kind": "Config",
    "preferences": {},
    "users": [
        {
            "name": object(),
            "user": {
                "exec": {
                    "apiVersion": "client.authentication.k8s.io/v1beta1",
                    "command": "bespinctl",
                    "args": object(),
                }
            },
        }
    ],
}


def render_kubeconfig(*clusters: EksCluster) -> dict:
    assert len(clusters) > 0
    # https://stackoverflow.com/questions/54953190/amazon-eks-generate-update-kubeconfig-via-python-script
    kubeconfig = deepcopy(KUBECONFIG_DEFAULT)
    cluster_config = kubeconfig["clusters"].pop()
    context_config = kubeconfig["contexts"].pop()
    user_config = kubeconfig["users"].pop()
    kubeconfig["current-context"] = clusters[0].id
    for cluster in clusters:
        # Eagerly cache the tokens for speed and reachability testing:
        get_token_for_cluster(cluster.account, cluster.name)
        cluster_config["cluster"]["certificate-authority-data"] = cluster["certificateAuthority"]["data"]
        cluster_config["cluster"]["server"] = cluster["endpoint"]
        cluster_config["name"] = context_config["name"] = user_config["name"] = cluster.id
        context_config["context"]["cluster"] = cluster.id
        context_config["context"]["user"] = cluster.id
        user_config["user"]["exec"]["args"] = [
            "-l", "error", "aws", "eks", "get-token", "--account", cluster.account.account_id, "--cluster", cluster.id
        ]
        kubeconfig["clusters"].append(deepcopy(cluster_config))
        kubeconfig["contexts"].append(deepcopy(context_config))
        kubeconfig["users"].append(deepcopy(user_config))

    return kubeconfig
