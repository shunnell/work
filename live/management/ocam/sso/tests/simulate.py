from types_boto3_iam import IAMClient
from bespin_tools.lib.testing.iam_simulation import simulate_identity_policy
from types_boto3_iam.type_defs import RoleTypeDef

# NOTE:
#   * All of the ARNs in the resource lists are FAKE
#   * the {account_id} isn't replaced, because it's assumed not to matter
#   * Service Control Policies and Resource policies aren't accounted for

def test_allow_describe_registry(infra_iam_client: IAMClient, devsecops_infra_role: RoleTypeDef):
    simulate_identity_policy(
        client=infra_iam_client,
        iam_role=devsecops_infra_role,
        action_expectations={
            "ecr:DescribeRegistry": "allowed",
        },
        resources=["*"]
    )

def test_allow_pushpull_repository(infra_iam_client: IAMClient, devsecops_infra_role: RoleTypeDef):
    simulate_identity_policy(
        client=infra_iam_client,
        iam_role=devsecops_infra_role,
        action_expectations={
            "ecr:UploadLayerPart": "allowed",
            "ecr:BatchGetImage": "allowed",
        },
        resources=["arn:aws:ecr:*:381492150796:repository/ocam/*"]
    )